package main

import (
	"sync"
	"encoding/json"
	"flag"
	"fmt"
	"log"
	"os"
	"os/signal"
	"syscall"
	"time"

	"github.com/nats-io/nats.go"
)

/* ============================================================
                        ESTRUCTURAS
============================================================ */

type Operation struct {
	Op     string `json:"op"`
	Bucket string `json:"bucket"`
	Key    string `json:"key"`
	Value  string `json:"value,omitempty"`
	TS     int64  `json:"ts"`
	NodeID string `json:"node_id"`
}

type Meta struct {
	TS        int64  `json:"ts"`
	NodeID    string `json:"node_id"`
	Tombstone bool   `json:"tombstone"`
}

type Config struct {
	NatsURL    string
	Bucket     string
	NodeID     string
	RepSubject string
}

/* ============================================================
                    VARIABLES GLOBALES
============================================================ */
var logicalTS int64 = 0

var (
	kvs      = make(map[string]nats.KeyValue)
	metas    = make(map[string]nats.KeyValue)
	watchers = make(map[string]nats.KeyWatcher)

	lastSeen   = make(map[string]Operation)
	ignoreNext = make(map[string]bool)

	mu sync.Mutex
)

var sub *nats.Subscription
var js nats.JetStreamContext

/* ============================================================
                         MAIN
============================================================ */

func main() {
	natsURL := flag.String("nats-url", "nats://localhost:4222", "NATS server URL")
	bucket := flag.String("bucket", "config", "KV bucket inicial")
	nodeID := flag.String("node-id", "site-a", "Node identifier")
	repSubject := flag.String("rep-subj", "rep.kv.ops", "Replication subject base")
	flag.Parse()

	cfg := Config{
		NatsURL:    *natsURL,
		Bucket:     *bucket,
		NodeID:     *nodeID,
		RepSubject: *repSubject,
	}

	log.Printf("Iniciando Agente Orquestador [%s] en %s", cfg.NodeID, cfg.NatsURL)

	nc, err := nats.Connect(cfg.NatsURL,
		nats.MaxReconnects(-1),
		nats.ReconnectWait(5*time.Second),
	)
	if err != nil {
		log.Fatalf("Error conectando a NATS: %v", err)
	}
	defer nc.Close()

	js, _ = nc.JetStream()

	// Configuración del Stream con Wildcards
	streamName := "KV_OPS_STREAM"
	subjectWildcard := cfg.RepSubject + ".>"
	
	_, err = js.StreamInfo(streamName)
	if err != nil {
		js.AddStream(&nats.StreamConfig{
			Name:     streamName,
			Subjects: []string{cfg.RepSubject, subjectWildcard},
			Storage:  nats.FileStorage,
		})
	}

	// 1. Suscripción Global (Escucha .system y todos los buckets)
	startGlobalSubscription(cfg)

	// 2. Iniciar el Registro Maestro (Descubrimiento automático)
	startMasterRegistryWatcher(js, cfg)

	// 3. Registrar nuestro propio bucket inicial en el sistema
	registerBucketInMaster(cfg.Bucket, js, cfg)

	// 4. Loop de Sincronización (Canal .system)
	go startSyncLoop(cfg)

	log.Println("Sistema Multi-Bucket con Auto-Descubrimiento Activo.")
	sig := make(chan os.Signal, 1)
	signal.Notify(sig, syscall.SIGINT, syscall.SIGTERM)
	<-sig
}

/* ============================================================
          PASO 2: REGISTRO MAESTRO (ORQUESTADOR)
============================================================ */

func startMasterRegistryWatcher(js nats.JetStreamContext, cfg Config) {
	registry, err := js.KeyValue("SYSTEM_REGISTRY")
	if err != nil {
		js.CreateKeyValue(&nats.KeyValueConfig{Bucket: "SYSTEM_REGISTRY"})
		registry, _ = js.KeyValue("SYSTEM_REGISTRY")
	}

	w, _ := registry.WatchAll()
	go func() {
		for update := range w.Updates() {
			if update == nil || update.Operation() == nats.KeyValueDelete {
				continue
			}
			bucketName := update.Key()
			if _, activo := kvs[bucketName]; !activo {
				log.Printf("[%s] [MASTER] Nuevo bucket descubierto: %s", cfg.NodeID, bucketName)
				initAndStartBucket(bucketName, js, cfg)
			}
		}
	}()
}

func registerBucketInMaster(name string, js nats.JetStreamContext, cfg Config) {
    registry, _ := js.KeyValue("SYSTEM_REGISTRY")
    registry.Put(name, []byte("active"))
    op := Operation{
        Op:     "discovery",
        Bucket: name,
        NodeID: cfg.NodeID,
        TS:     logicalTS,
    }
    data, _ := json.Marshal(op)
    js.Publish(cfg.RepSubject+".system", data)
}

/* ============================================================
          INICIALIZACIÓN DINÁMICA DE BUCKETS
============================================================ */

func initAndStartBucket(name string, js nats.JetStreamContext, cfg Config) {
	var err error
	kvs[name], err = js.KeyValue(name)
	if err != nil {
		js.CreateKeyValue(&nats.KeyValueConfig{Bucket: name})
		kvs[name], _ = js.KeyValue(name)
	}

	metaName := name + "_meta"
	metas[name], err = js.KeyValue(metaName)
	if err != nil {
		js.CreateKeyValue(&nats.KeyValueConfig{Bucket: metaName})
		metas[name], _ = js.KeyValue(metaName)
	}

	// Cargar Metadata
	keys, _ := metas[name].Keys()
	for _, k := range keys {
		entry, _ := metas[name].Get(k)
		var m Meta
		json.Unmarshal(entry.Value(), &m)
		compositeKey := name + ":" + k
		lastSeen[compositeKey] = Operation{
			Bucket: name, Key: k, TS: m.TS, NodeID: m.NodeID,
		}
		if m.TS > logicalTS { logicalTS = m.TS }
	}

	syncChan := make(chan struct{})
	w, _ := kvs[name].WatchAll()
	watchers[name] = w

	go handleLocalWatcher(name, w, js, cfg, syncChan)

	go func() {
		time.Sleep(5 * time.Second)
		close(syncChan)
	}()
}

/* ============================================================
                MANEJAR CAMBIOS LOCALES
============================================================ */

func handleLocalWatcher(bucketName string, w nats.KeyWatcher, js nats.JetStreamContext, cfg Config, ready <-chan struct{}) {
    <-ready
    for update := range w.Updates() {
        if update == nil { continue }
        key := update.Key()
        compositeKey := bucketName + ":" + key

        // --- SECCIÓN CRÍTICA: Comprobar y limpiar ignoreNext ---
        mu.Lock()
        if ignoreNext[compositeKey] {
            delete(ignoreNext, compositeKey)
            mu.Unlock()
            continue
        }
        mu.Unlock()

        opType := "put"
        val := string(update.Value())
        if update.Operation() == nats.KeyValueDelete {
            opType = "delete"
            val = ""
        }

        logicalTS++
        ts := logicalTS
        op := Operation{
            Op: opType, Bucket: bucketName, Key: key, Value: val, TS: ts, NodeID: cfg.NodeID,
        }

        subject := fmt.Sprintf("%s.%s", cfg.RepSubject, bucketName)
        data, _ := json.Marshal(op)
        js.Publish(subject, data)

        metas[bucketName].Put(key, mustJSON(Meta{
            TS: ts, NodeID: cfg.NodeID, Tombstone: (opType == "delete"),
        }))

        // --- SECCIÓN CRÍTICA: Actualizar lastSeen ---
        mu.Lock()
        lastSeen[compositeKey] = op
        mu.Unlock()

        accionLocal := "ACTUALIZADO"
        if opType == "delete" {
                accionLocal = "BORRADO (Tombstone)"
        }

        log.Printf("[%s] [%s] LOCAL %s: %s (TS:%d)", cfg.NodeID, bucketName, accionLocal, key, ts)
    }
}

/* ============================================================
                MANEJAR OPERACIONES REMOTAS
============================================================ */

func startGlobalSubscription(cfg Config) {
	durable := "monitor-" + cfg.NodeID
	sub, _ = js.Subscribe(
		cfg.RepSubject+".>",
		func(msg *nats.Msg) { handleRemoteOp(msg, cfg) },
		nats.Durable(durable),
		nats.ManualAck(),
		nats.ReplayOriginal(),
	)
}

func handleRemoteOp(msg *nats.Msg, cfg Config) {
    msg.Ack()
    var op Operation
    if err := json.Unmarshal(msg.Data, &op); err != nil {
        return
    }

    if op.NodeID == cfg.NodeID {
        return
    }

	if op.Op == "discovery" {
        if _, activo := kvs[op.Bucket]; !activo {
            log.Printf("[%s] [REMOTE] Descubierto nuevo bucket: %s", cfg.NodeID, op.Bucket)
            initAndStartBucket(op.Bucket, js, cfg)
        }
        return
    }

    if op.Op == "sync" {
        log.Printf("[%s] [SYSTEM] Recibido PING de %s. Iniciando transferencia de estado...", cfg.NodeID, op.NodeID)
        // Bloqueamos para leer las claves de forma segura
        for bName := range kvs {
            responderEstadoDeBucket(bName, cfg)
        }
        return
    }

    if _, ok := kvs[op.Bucket]; !ok {
        if op.Bucket == "" { return } 
        
        log.Printf("[%s] [SYSTEM] Creación JIT: Inicializando bucket '%s' por mensaje entrante", cfg.NodeID, op.Bucket)
        initAndStartBucket(op.Bucket, js, cfg)
        
        // Pausa para que los watchers internos de NATS se estabilicen
        time.Sleep(100 * time.Millisecond)
    }

    compositeKey := op.Bucket + ":" + op.Key
    
    // --- SECCIÓN CRÍTICA: Lectura de lastSeen ---
    mu.Lock()
    prev, exists := lastSeen[compositeKey]
    mu.Unlock()

    apply := !exists || op.TS > prev.TS || (op.TS == prev.TS && op.NodeID > prev.NodeID)
    
    if op.TS > logicalTS {
        logicalTS = op.TS
    }

    if !apply {
        return
    }

    // --- SECCIÓN CRÍTICA: Escritura en mapas ---
    mu.Lock()
    lastSeen[compositeKey] = op
    ignoreNext[compositeKey] = true
    mu.Unlock()

    isTombstone := (op.Value == "" || op.Op == "delete")
    metas[op.Bucket].Put(op.Key, mustJSON(Meta{
        TS:        op.TS,
        NodeID:    op.NodeID,
        Tombstone: isTombstone,
    }))

    if isTombstone {
        kvs[op.Bucket].Delete(op.Key)
    } else {
        kvs[op.Bucket].Put(op.Key, []byte(op.Value))
    }

    tipoMsg := "REMOTO"
    if op.Op == "state" {
        tipoMsg = "STATE-SYNC"
    }
    accion := "ACTUALIZADO"
    if isTombstone {
        accion = "BORRADO (Tombstone)"
    }

    log.Printf("[%s] [%s] %s %s: %s (de %s, TS:%d)", 
        cfg.NodeID, op.Bucket, tipoMsg, accion, op.Key, op.NodeID, op.TS)
}

/* ============================================================
                     SINCRONIZACIÓN
============================================================ */

func responderEstadoDeBucket(name string, cfg Config) {
	// Bloqueamos el mapa mientras lo recorremos para evitar errores de lectura/escritura concurrente
	mu.Lock()
	defer mu.Unlock() // El defer asegura que el candado se suelte al terminar la función automáticamente

	count := 0
	for compositeKey, op := range lastSeen {
		// Comprobamos si la clave pertenece a este bucket (ej: "usuarios:admin")
		// Comparamos el prefijo de la compositeKey con el nombre del bucket + ":"
		prefix := name + ":"
		if len(compositeKey) > len(prefix) && compositeKey[:len(prefix)] == prefix {
			stateOp := op
			stateOp.Op = "state"
			data, _ := json.Marshal(stateOp)
			
			// Publicamos el estado. Usamos js.Publish directamente.
			js.Publish(fmt.Sprintf("%s.%s", cfg.RepSubject, name), data)
			count++
		}
	}
	
	if count > 0 {
		log.Printf("[%s] [SYSTEM] Enviados %d estados del bucket [%s]", cfg.NodeID, count, name)
	}
}

func startSyncLoop(cfg Config) {
	for {
		time.Sleep(5 * time.Minute) // Para pruebas: time.Sleep(5 * time.Second)
		op := Operation{Op: "sync", NodeID: cfg.NodeID}
		data, _ := json.Marshal(op)
		// Publicamos en .system para que todos los nodos lo vean
		js.Publish(cfg.RepSubject+".system", data)
	}
}

func mustGet(bucket, key string) []byte {
	entry, err := kvs[bucket].Get(key)
	if err != nil { return []byte{} }
	return entry.Value()
}

func mustJSON(v interface{}) []byte {
	b, _ := json.Marshal(v)
	return b
}
