>[!NOTE]
> Proyecto desarrollado por Pau Amoros, Pablo Raga y Enrique Sopeña, en la asignatura de SAD del curso 2025-2026

# Sincronización de almacenes KV de NATS mediante CRDT

## Índice

* [1. Introducción](#1-introducción)
* [2. Estructura del proyecto](#2-estructura-del-proyecto)
  * [2.1. Infraestructura de Red y Servidores](#21-infraestructura-de-red-y-servidores)
  * [2.2. Flexibilidad de Despliegue del Agente](#22-flexibilidad-de-despliegue-del-agente)
  * [2.3. Organización del Código y Estructura del Proyecto](#23-organización-del-código-y-estructura-del-proyecto)
    * [Estructura de Directorios](#estructura-de-directorios)
    * [Responsabilidades del Agente (`main.go`)](#responsabilidades-del-agente-maingo)
* [3. Arquitectura y Tecnologías](#3-arquitectura-y-tecnologías)
  * [3.1. JetStream y Almacenamiento KV](#31-jetstream-y-almacenamiento-kv)
  * [3.2. Topología de Interconexión mediante Leafnodes](#32-topología-de-interconexión-mediante-leafnodes)
* [4. Lógica de Sincronización y CRDT](#4-lógica-de-sincronización-y-crdt)
  * [4.1. Protocolo de Difusión `[REQ-6.1]`](#41-protocolo-de-difusión-req-61)
  * [4.2. Análisis de Estrategias de Replicación `[REQ-9.1, 9.2, 9.3]`](#42-análisis-de-estrategias-de-replicación-req-91-92-93)
  * [4.3. Resolución de Conflictos y Desempate Determinista](#43-resolución-de-conflictos-y-desempate-determinista)
  * [4.4. Control de Concurrencia y Autosanación (JIT)](#44-control-de-concurrencia-y-autosanación-jit)
    * [Control de Concurrencia y Filtrado de Eco (`ignoreNext`)](#control-de-concurrencia-y-filtrado-de-eco-ignorenext)
    * [Creación Just-In-Time (JIT)](#creación-just-in-time-jit)
  * [4.5. Persistencia de Estado y Metadatos](#45-persistencia-de-estado-y-metadatos)
* [5. Orquestación Multi-bucket y Auto-descubrimiento](#5-orquestación-multi-bucket-y-auto-descubrimiento)
  * [5.1. Registro Maestro y Anuncio Proactivo](#51-registro-maestro-y-anuncio-proactivo)
  * [5.2. Inicialización Dinámica de Infraestructura](#52-inicialización-dinámica-de-infraestructura)
  * [5.3. Bucle de Sincronización y Anti-Entropía (5 min)](#53-bucle-de-sincronización-y-anti-entropía-5-min)
* [6. Validación y Pruebas de Sistema](#6-validación-y-pruebas-de-sistema)
  * [6.1. Test de Resiliencia y Recuperación de Conexión `[REQ-7]`](#61-test-de-resiliencia-y-recuperación-de-conexión)
  * [6.2. Test de Descubrimiento Dinámico y Creación JIT](#62-test-de-descubrimiento-dinámico-y-creación-jit)
  * [6.3. Test de Resolución de Conflictos (LWW)](#63-test-de-resolución-de-conflictos-lww)
  * [6.4. Análisis de Tiempos y Garantías de Sincronización](#64-análisis-de-tiempos-y-garantías-de-sincronización)
* [7. Resultados de las Pruebas](#7-resultados-de-las-pruebas)
  * [7.1. Tabla de Resultados](#71-tabla-de-resultados)
  * [7.2. Evidencia de Ejecución](#72-evidencia-de-ejecución)
* [8. Conclusiones Finales](#8-conclusiones-finales)


## Introducción

Este proyecto presenta el diseño e implementación de un sistema de replicación distribuida de estado basado en **NATS** y **JetStream**, cuyo objetivo es garantizar la convergencia de un conjunto de datos *key-value* entre múltiples nodos, incluso en presencia de desconexiones temporales o caídas parciales del sistema.

La solución propuesta adopta una arquitectura descentralizada, sin nodo maestro, en la que cada participante mantiene una copia local del estado y colabora en su sincronización mediante el intercambio de operaciones y estados. Para la resolución de conflictos se emplea un enfoque **Last-Writer-Wins (LWW)**, apoyado en metadatos persistentes que permiten determinar de forma determinista la versión válida de cada clave.

La replicación se realiza sobre JetStream mediante consumidores *durable*, lo que asegura la recuperación de mensajes tras reconexiones y la persistencia de los cambios. Adicionalmente, el sistema implementa un mecanismo explícito de sincronización entre nodos que permite intercambiar el estado actual cuando un nodo se reincorpora tras un periodo de inactividad, garantizando la convergencia eventual del sistema.

El desarrollo se ha llevado a cabo en **Go**, utilizando las bibliotecas oficiales de NATS, y se ha estructurado siguiendo un enfoque incremental, validando progresivamente la comunicación, la persistencia y la convergencia del estado distribuido.

## 2. Estructura del proyecto

El sistema se organiza en dos componentes principales: una infraestructura de red distribuida y persistente basada en NATS con JetStream, y un agente de software encargado de implementar la lógica de sincronización, reconciliación de estado y resolución de conflictos. Esta separación permite aislar claramente las responsabilidades de infraestructura y de lógica distribuida, facilitando tanto el despliegue como el análisis del comportamiento del sistema.

### 2.1. Infraestructura de red y servidores

La arquitectura del sistema se apoya en una infraestructura de red distribuida y persistente, definida y orquestada mediante el archivo [`docker-compose.yml`](./nats-kv-syncd/docker-compose.yml). Esta infraestructura está diseñada para simular entornos de sedes independientes, cumpliendo los requisitos de tolerancia a fallos y persistencia establecidos en el enunciado del proyecto.

Los elementos principales de esta infraestructura son los siguientes:

* **Servidores NATS con JetStream**  
  Se despliegan instancias de NATS utilizando la imagen oficial, habilitando explícitamente JetStream para proporcionar persistencia tanto a los almacenes *Key-Value* como a los mensajes de replicación. La configuración personalizada de cada nodo se carga mediante un fichero específico (`nats.conf`), permitiendo ajustar puertos, almacenamiento y topología.

  ```yaml
  nats-a:
    image: nats:latest
    command: ["-js", "-c", "/etc/nats/nats.conf"] # Habilita JetStream y carga nats.conf
  ```

* **Red virtual dedicada (`nats-net`)**
  El despliegue utiliza una red Docker de tipo `bridge`, que aísla el tráfico interno del sistema y permite el descubrimiento de servicios mediante nombres de host internos (`nats-a`, `nats-b`). Esta configuración simplifica la comunicación entre nodos y evita dependencias de direcciones IP fijas.

  ```yaml
  networks:
    nats-net:
      driver: bridge
  ```

* **Configuración de persistencia**
  Cada servidor NATS dispone de un directorio de almacenamiento dedicado, enlazado a volúmenes persistentes de Docker. Esta decisión garantiza que los datos almacenados en JetStream (buckets KV y mensajes de replicación) sobrevivan a reinicios o paradas de los contenedores, permitiendo simular escenarios reales de recuperación tras fallo.

  ```yaml
  volumes:
    - ./nats-a.conf:/etc/nats/nats.conf
    - nats_a_data:/data  # Persistencia real en volumen de Docker
  ```

* **Topología de interconexión mediante Leafnodes**
  Para cumplir con el requisito de interconexión entre nodos sin dependencia de un servidor central, se ha implementado una topología basada en *Leafnodes*. En esta configuración, el Nodo B actúa como una hoja que se conecta de forma proactiva al Nodo A, permitiendo el intercambio de tráfico de replicación sin necesidad de una jerarquía rígida.

  ```yaml
  ports:
    - "4223:5222"   # Puerto expuesto para clientes (Agentes)
    - "7423:7422"   # Puerto para conexión de Leafnodes (Nodo A)
  ```

Esta infraestructura permite reproducir de forma controlada escenarios de desconexión, reconexión y partición de red, fundamentales para validar el comportamiento del sistema distribuido.

### 2.2. Flexibilidad de despliegue del agente

El agente de sincronización ha sido diseñado para ser independiente del entorno de ejecución, permitiendo su despliegue tanto en el sistema anfitrión como en contenedores independientes. Esta flexibilidad se logra mediante el uso de parámetros de configuración pasados en tiempo de ejecución a través de *flags*.

* **Ejecución en máquina anfitriona (host)**
  Cuando el agente se ejecuta directamente sobre el sistema operativo local, la conexión a los servidores NATS se realiza mediante los puertos expuestos por Docker. En este caso, el agente se conecta a `localhost` utilizando los puertos mapeados externamente.

  ```bash
  # Ejecución para el Nodo A desde el Host
  CGO_ENABLED=0 go run main.go --nats-url nats://localhost:4223 --node-id site-a --bucket config
  ```

* **Ejecución en contenedor independiente (entorno híbrido)**
  Si el agente se despliega dentro de un contenedor, este debe integrarse en la red `nats-net`. Esta configuración permite aprovechar el DNS interno de Docker, localizando los servidores NATS mediante sus nombres de servicio (`nats-a`, `nats-b`) y utilizando el puerto interno estándar.

  ```bash
  # Ejecución para el Nodo B desde un contenedor en la red nats-net
  CGO_ENABLED=0 go run main.go --nats-url nats://nats-b:5222 --node-id site-b --bucket config
  ```

* **Portabilidad y compilación estática**
  El uso de la variable de entorno `CGO_ENABLED=0` es un aspecto clave del proyecto. Al desactivar CGO, el compilador de Go genera un binario completamente estático, eliminando dependencias de librerías dinámicas del sistema anfitrión. Esta decisión garantiza la portabilidad del agente entre diferentes arquitecturas y entornos, incluyendo contenedores Docker ejecutados sobre sistemas macOS con procesadores ARM.

### 2.3. Organización del código y estructura del proyecto

El proyecto se organiza de forma que la lógica de sincronización, la configuración de la infraestructura y las herramientas de validación queden claramente separadas, facilitando tanto el desarrollo como el análisis del sistema.

#### Estructura de directorios

La siguiente jerarquía refleja la organización actual del repositorio:

```text
.
└── nats-kv-syncd/               # Directorio raíz del proyecto
    ├── main.go                  # Lógica principal del agente (Watchers, CRDT, sincronización)
    ├── nats-a.conf              # Configuración del Nodo A 
    ├── nats-b.conf              # Configuración del Nodo B 
    ├── docker-compose.yml       # Orquestador de servicios NATS y volúmenes persistentes
    ├── go.mod / go.sum          # Gestión de dependencias del agente
    ├── nats-kv-syncd            # Binario compilado del agente
    └── test/                    # Suite de validación
        ├── resilience_test.sh   # Pruebas de tolerancia a fallos
        ├── conflict_test.sh     # Pruebas de resolución de conflictos
        └── discovery_test.sh    # Pruebas de descubrimiento y reconexión
```

#### Responsabilidades del agente ([`main.go`](./nats-kv-syncd/main.go))

Aunque el detalle de la implementación se abordará en secciones posteriores, el agente ha sido diseñado de forma modular para asumir las siguientes responsabilidades principales:

* **Vigilancia de estado (Watchers)**: Monitorización continua de los cambios locales en los buckets *Key-Value*.
* **Gestión de metadatos**: Creación y mantenimiento de buckets de metadatos (`_meta`) necesarios para la resolución de conflictos.
* **Control de concurrencia**: Prevención de condiciones de carrera durante la aplicación de cambios locales y remotos.
* **Orquestación dinámica**: Coordinación de la sincronización y reconciliación de estado entre nodos de forma descentralizada.

## 3. Arquitectura y tecnologías

El sistema se apoya en el ecosistema de **NATS** y su extensión **JetStream** para construir una solución de almacenamiento distribuido y replicado, capaz de superar las limitaciones de la mensajería efímera tradicional. La arquitectura ha sido diseñada para garantizar persistencia, tolerancia a fallos y convergencia eventual del estado sin depender de un nodo maestro centralizado.

### 3.1. JetStream y almacenamiento Key-Value

A diferencia del núcleo de NATS (*Core NATS*), que proporciona mensajería efímera orientada a eventos, **JetStream** introduce capacidades de persistencia, control de consumo y recuperación tras fallos. Sobre esta capa se utilizan los almacenes **Key-Value (KV)** como mecanismo principal de almacenamiento distribuido del estado.

Las características más relevantes de esta aproximación son las siguientes:

* **Persistencia de estado**  
  Cada bucket *Key-Value* se implementa internamente sobre un *stream* de JetStream con una política de retención basada en el último valor por clave. Esta configuración permite que el estado más reciente de cada clave se almacene de forma persistente en disco. Como consecuencia, un nodo que se reinicia puede recuperar automáticamente el estado actual sin necesidad de reconstruirlo a partir de eventos históricos.

* **Aislamiento entre estado y replicación**  
  El uso de buckets KV permite separar conceptualmente el almacenamiento del estado local de la lógica de replicación. El estado se mantiene de forma estable en JetStream, mientras que las operaciones de sincronización se gestionan a través de *subjects* específicos, lo que facilita el control y la depuración del sistema.

* **Consumidores durables**  
  Para la replicación de operaciones entre nodos, el agente utiliza consumidores *durable*. Esta elección permite que el servidor NATS mantenga el progreso de cada agente, recordando qué mensajes han sido entregados y confirmados. De este modo, si un agente o un servidor se desconecta temporalmente, los mensajes pendientes se entregan automáticamente tras la reconexión, evitando pérdidas de información y garantizando la consistencia eventual.

### 3.2. Topología de interconexión mediante Leafnodes

Para cumplir el objetivo de interconectar sedes de forma descentralizada, se ha optado por una arquitectura basada en **Leafnodes**, que constituye uno de los elementos clave del diseño del sistema.

Esta aproximación presenta las siguientes ventajas:

* **Independencia de nodos**  
  A diferencia de un clúster tradicional de NATS, en el que todos los servidores deben estar permanentemente conectados y compartir configuración, los *Leafnodes* permiten que cada servidor funcione como una entidad independiente. Cada nodo decide explícitamente a qué otros servidores se conecta, manteniendo su autonomía operativa.

* **Comunicación transparente entre sedes**  
  En la arquitectura implementada, el Nodo B se conecta al Nodo A como una hoja (*Leafnode*). Una vez establecida esta conexión, los *subjects* de replicación se propagan de forma bidireccional entre ambos servidores. Esto permite que los agentes desplegados en distintas sedes intercambien información sin necesidad de conocer direcciones IP remotas ni establecer conexiones directas entre ellos.

* **Resiliencia ante fallos de red**  
  Si la conexión entre servidores NATS se interrumpe, cada nodo continúa funcionando de manera local para sus clientes, aceptando y procesando operaciones sin bloqueo. Cuando la conexión se restablece, JetStream y los *Leafnodes* se encargan de propagar automáticamente el tráfico pendiente, permitiendo que el sistema recupere la coherencia global sin intervención manual.

## 4. Lógica de sincronización y CRDT

El agente implementa un modelo de **consistencia eventual** basado en un CRDT de tipo **Last-Writer-Wins (LWW)**. Esta sección describe la lógica de sincronización entre nodos, el protocolo de difusión empleado, las estrategias de replicación evaluadas y los mecanismos utilizados para garantizar la convergencia del estado distribuido de forma determinista.

### 4.1. Protocolo de difusión `[REQ-6.1]`

La comunicación entre nodos se articula mediante un *subject* raíz común, `rep.kv.ops`, utilizado para difundir tanto operaciones de datos como mensajes de control.

* **Implementación**  
  Cada operación se publica dentro de una jerarquía de *subjects* basada en el bucket afectado (por ejemplo, `rep.kv.ops.usuarios`). Esta estructura permite segmentar lógicamente el tráfico sin necesidad de múltiples suscripciones.

* **Captura y procesamiento**  
  El agente se suscribe utilizando un *wildcard* (`rep.kv.ops.>`), lo que le permite procesar con una única suscripción todo el tráfico del sistema, incluyendo tanto operaciones de datos como mensajes de control internos (por ejemplo, sincronización o intercambio de estado).

Este enfoque simplifica la arquitectura de comunicación y reduce la complejidad de gestión de suscripciones, manteniendo al mismo tiempo la extensibilidad del sistema.

### 4.2. Análisis de estrategias de replicación `[REQ-9.1, REQ-9.2, REQ-9.3]`

Durante el desarrollo se evaluaron distintas estrategias de replicación para equilibrar inmediatez, robustez y complejidad. Finalmente, se optó por una **estrategia híbrida**, cuyas características se resumen en la siguiente tabla:

| Estrategia | Ventaja | Inconveniente |
|-----------|---------|---------------|
| **Mensajería (JetStream)** | Replicación inmediata en tiempo real. | Riesgo de pérdida de cambios ante fallos prolongados. |
| **Estado (Anti-Entropy)** | Garantía de convergencia absoluta. | Mayor latencia y consumo de ancho de banda. |
| **Híbrida (implementada)** | Combina inmediatez y recuperación robusta. | Mayor complejidad en la lógica de control. |

**Justificación**  
La estrategia híbrida permite utilizar JetStream como canal principal de replicación en tiempo real, mientras que un mecanismo periódico de *anti-entropy* garantiza la convergencia del estado ante particiones de red, reinicios o fallos prolongados. De este modo, el sistema mantiene un equilibrio entre rendimiento y fiabilidad, cumpliendo los requisitos funcionales del proyecto.

### 4.3. Resolución de conflictos y desempate determinista

La resolución de conflictos se basa en el algoritmo **Last-Writer-Wins (LWW)**. La función `handleRemoteOp` actúa como árbitro central, decidiendo de forma determinista si una actualización remota debe aplicarse o descartarse.

El criterio de decisión es el siguiente:

1. **Comparación de `LogicalTS`**  
   Prevalece la versión con el marcador de tiempo lógico más alto.

2. **Desempate por `NodeID`**  
   Si los valores de `TS` coinciden, se utiliza el identificador del nodo para garantizar una decisión determinista común a todos los participantes.

```go
// --- Fragmento de handleRemoteOp ---
mu.Lock()
prev, exists := lastSeen[compositeKey]
mu.Unlock()

// Lógica de resolución:
// 1. Si la clave no existe.
// 2. Si el TS entrante es mayor.
// 3. Si el TS es igual, gana el NodeID alfabéticamente mayor.
apply := !exists || op.TS > prev.TS || (op.TS == prev.TS && op.NodeID > prev.NodeID)

if !apply {
    return // Se descarta la actualización perdedora
}
```

Este mecanismo garantiza que todos los nodos del sistema converjan hacia el mismo estado final, incluso en presencia de actualizaciones concurrentes.

### 4.4. Control de concurrencia y autosanación (JIT)

#### Control de concurrencia y filtrado de eco (`ignoreNext`)

Para evitar condiciones de carrera en las estructuras internas (`lastSeen`, `ignoreNext`) y prevenir bucles de replicación infinita, el agente implementa un control explícito de concurrencia mediante **mutexes** y un mapa de exclusión temporal.

Cuando el agente aplica una operación remota en su KV local, se marca la clave correspondiente para evitar que el *watcher* local replique nuevamente ese mismo cambio.

```go
// --- Fragmento de handleLocalWatcher ---
mu.Lock()
if ignoreNext[compositeKey] {
    delete(ignoreNext, compositeKey) // Se consume el aviso de eco
    mu.Unlock()
    continue
}
mu.Unlock()
```

Este mecanismo garantiza que cada cambio se propague exactamente una vez por nodo, evitando tormentas de mensajes.

#### Creación Just-In-Time (JIT)

El sistema incorpora un mecanismo de **autosanación Just-In-Time (JIT)**. Si el agente recibe una operación asociada a un bucket no inicializado localmente, este se crea dinámicamente en lugar de descartar el mensaje.

```go
// --- Lógica de autosanación JIT ---
if _, ok := kvs[op.Bucket]; !ok {
    log.Printf("[%s] [SYSTEM] Creación JIT: Inicializando bucket '%s'...", cfg.NodeID, op.Bucket)
    initAndStartBucket(op.Bucket, js, cfg)
    time.Sleep(100 * time.Millisecond) // Estabilización de watchers
}
```

Esta capacidad permite al sistema adaptarse dinámicamente a nuevos buckets sin intervención manual, reforzando su carácter descentralizado.

### 4.5. Persistencia de estado y metadatos `[REQ-6.3]`

Para garantizar la resiliencia del sistema ante reinicios del agente, se ha optado por persistir los metadatos de sincronización en un bucket independiente (`_meta`), en lugar de mantener esta información únicamente en memoria.

Esta decisión responde a dos razones principales:

1. **Persistencia tras fallo**
   En caso de reinicio del agente, el estado en memoria se pierde. El bucket `_meta` permite reconstruir inmediatamente el estado lógico del sistema, incluyendo el valor del reloj lógico (`logicalTS`).

2. **Auditoría y trazabilidad**
   La separación entre datos y metadatos permite identificar de forma independiente qué nodo realizó la última actualización de cada clave, sin interferir con el valor funcional del dato.

Durante el arranque del agente, se reconstruye el estado lógico a partir del bucket de metadatos:

```go
// --- Fragmento de initAndStartBucket ---
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
```

Este proceso garantiza que el reloj lógico continúe siempre desde el valor más alto conocido, evitando solapamientos de versiones y asegurando la coherencia del sistema tras cualquier reinicio.

## 5. Orquestación multi-bucket y auto-descubrimiento

Esta sección describe la capacidad del agente para gestionar de forma dinámica múltiples almacenes *Key-Value* (KV), permitiendo que el sistema escale horizontalmente sin requerir intervenciones manuales ni reconfiguraciones explícitas de la infraestructura. El objetivo es que los nodos puedan descubrir, inicializar y sincronizar nuevos buckets de manera autónoma, incluso en escenarios de conexión tardía o partición de red.

### 5.1. Registro maestro y anuncio proactivo

Debido a la naturaleza descentralizada de la topología basada en **Leafnodes**, no se puede asumir que todos los nodos conozcan de antemano la existencia de todos los buckets activos. Para resolver este problema, el sistema implementa un modelo de descubrimiento híbrido que combina persistencia y notificación proactiva.

Este modelo se basa en los siguientes mecanismos:

* **Persistencia en `SYSTEM_REGISTRY`**  
  Cuando se crea o detecta un nuevo bucket, el agente lo registra en un almacén KV global denominado `SYSTEM_REGISTRY`. Este registro actúa como fuente de verdad persistente, permitiendo que los nodos que se incorporan posteriormente al sistema reconstruyan la topología completa de buckets activos durante su arranque.

* **Anuncio global proactivo**  
  De forma complementaria, el agente emite un mensaje de tipo `discovery` a través de un canal de sistema específico. Este anuncio permite que los nodos ya activos reaccionen de manera inmediata ante la aparición de un nuevo bucket, sin necesidad de esperar a un ciclo de sincronización periódica.

```go
func registerBucketInMaster(name string, js nats.JetStreamContext, cfg Config) {
    // 1. Registro persistente en el bucket maestro
    registry, _ := js.KeyValue("SYSTEM_REGISTRY")
    registry.Put(name, []byte("active"))
    
    // 2. Anuncio proactivo para descubrimiento instantáneo en otros nodos
    op := Operation{
        Op:     "discovery",
        Bucket: name,
        NodeID: cfg.NodeID,
        TS:     logicalTS,
    }
    data, _ := json.Marshal(op)
    js.Publish(cfg.RepSubject+".system", data)
}
```

Este enfoque garantiza tanto la consistencia a largo plazo (mediante persistencia) como la reactividad inmediata del sistema ante cambios dinámicos en la topología.

### 5.2. Inicialización dinámica de infraestructura

Cuando el agente detecta la existencia de un nuevo bucket —ya sea a través del registro maestro, de un anuncio proactivo o de tráfico de datos entrante— ejecuta automáticamente la función `initAndStartBucket`. Este proceso encapsula toda la lógica necesaria para preparar la infraestructura local asociada a dicho bucket.

Las acciones realizadas durante esta inicialización son las siguientes:

1. **Creación o conexión dinámica de buckets de datos y metadatos**
   El agente establece la conexión con el bucket de datos y con su bucket de metadatos asociado (`_meta`). Si alguno de ellos no existe localmente, se crea de forma automática.

2. **Reconstrucción del estado de sincronización**
   A partir del bucket de metadatos, el agente reconstruye el estado lógico local (`lastSeen` y `logicalTS`), garantizando que las futuras decisiones de resolución de conflictos se basen en información coherente.

3. **Activación de la vigilancia en tiempo real**
   Finalmente, se inicia un *watcher* sobre el bucket para capturar cambios locales en tiempo real y habilitar su posterior replicación.

```go
func initAndStartBucket(name string, js nats.JetStreamContext, cfg Config) {
    // 1. Conexión/Creación dinámica de buckets de Datos y Metadatos (_meta)
    kvs[name], _ = js.KeyValue(name)
    metas[name], _ = js.KeyValue(name + "_meta")

    // 2. Carga de metadatos para reconstruir el estado de sincronización local
    keys, _ := metas[name].Keys()
    for _, k := range keys {
        entry, _ := metas[name].Get(k)
        var m Meta
        json.Unmarshal(entry.Value(), &m)
        compositeKey := name + ":" + k
        lastSeen[compositeKey] = Operation{ Bucket: name, Key: k, TS: m.TS, NodeID: m.NodeID }
        if m.TS > logicalTS { logicalTS = m.TS }
    }

    // 3. Inicio del Watcher local para captura de cambios en tiempo real
    w, _ := kvs[name].WatchAll()
    go handleLocalWatcher(name, w, js, cfg, make(chan struct{}))
}
```

Este mecanismo permite que el sistema se adapte dinámicamente a cambios en la topología de datos sin interrupciones del servicio.

### 5.3. Bucle de sincronización y anti-entropía (5 minutos)

Para reforzar la robustez del sistema y cumplir los requisitos de tolerancia a fallos, se ha implementado un bucle periódico de sincronización que actúa como una capa adicional de *anti-entropía*.

Las características principales de este mecanismo son:

* **Heartbeat de sincronización**
  Cada cinco minutos, el agente emite una señal de control global (`sync`) a través del canal de sistema. Este intervalo actúa como una red de seguridad ante escenarios de desconexión prolongada o incorporación tardía de nodos.

* **Convergencia mediante JIT**
  Al recibir esta señal, los nodos activos responden enviando su estado actual (`state`). Este intercambio de información puede, a su vez, desencadenar la creación Just-In-Time (JIT) de buckets desconocidos en el nodo receptor, cerrando cualquier brecha de información existente.

```go
func startSyncLoop(cfg Config) {
    for {
        // Intervalo de seguridad de 5 minutos (Requisito de diseño)
        time.Sleep(5 * time.Minute) 
        
        op := Operation{Op: "sync", NodeID: cfg.NodeID}
        data, _ := json.Marshal(op)
        
        // Difusión del mensaje de sincronización global por el subject de sistema
        js.Publish(cfg.RepSubject+".system", data)
    }
}
```

Este bucle garantiza que, incluso en presencia de fallos complejos o desconexiones prolongadas, el sistema termine convergiendo hacia un estado consistente de forma automática y sin intervención externa.

## 6. Validación y pruebas del sistema

Con el objetivo de verificar la fiabilidad del agente y su comportamiento ante escenarios adversos, se ha diseñado una batería de pruebas orientada a validar la resiliencia del sistema, la capacidad de auto-descubrimiento y la correcta resolución de conflictos. Estas pruebas reproducen situaciones realistas de fallo y reconexión, alineadas con los requisitos del enunciado.

### 6.1. Test de resiliencia y recuperación de conexión `[REQ-7]`
>[!WARNING]
>Para las pruebas, se ha utilizado un periodo de reconexion de 5 segundos, en vez de 5 minutos. Para poder replicarlas, hay que cambiar el valor de `time.Sleep(5 * time.Minute)` -> 	**`time.Sleep(5 * time.Second)`** ([main.go > *func startSyncLoop(cfg Config)* > linea 396](./nats-kv-syncd/main.go#L396))

Mediante el script [`resilience_test.sh`](./nats-kv-syncd/test/resilience_test.sh) se simula la caída de uno de los servidores de mensajería para evaluar el comportamiento del sistema ante la pérdida de infraestructura.

* **Escenario**  
  Se fuerza la parada del contenedor `nats-a-1` mientras el agente de sincronización asociado permanece en ejecución.

* **Comportamiento esperado del agente**  
  - El agente detecta automáticamente la pérdida de conectividad con el servidor NATS.
  - Se activa el mecanismo de **reconexión automática**, con reintentos periódicos cada cinco segundos.
  - Durante la interrupción, el Nodo B continúa aceptando y registrando cambios locales sin bloqueo.

* **Mecanismo de recuperación**  
  Una vez restaurado el contenedor NATS, el agente recupera la comunicación con el servidor. La convergencia final del estado distribuido se garantiza mediante el **bucle de anti-entropía**, que emite un mensaje de sincronización (`sync`) y provoca el intercambio de estados (`state`) para recuperar cualquier actualización producida durante la desconexión.

Este test valida que el sistema es capaz de tolerar caídas de infraestructura sin pérdida de datos y recuperar la coherencia global de forma automática.

### 6.2. Test de descubrimiento dinámico y creación Just-In-Time

El script [`discovery_test.sh`](./nats-kv-syncd/test/discovery_test.sh) verifica la capacidad del sistema para gestionar nuevos almacenes de datos de forma dinámica, sin configuración previa.

* **Escenario**  
  Se crea un bucket de datos que no estaba definido inicialmente en ninguno de los nodos.

* **Validación**  
  El agente remoto detecta la llegada de tráfico asociado a un bucket inexistente localmente. En lugar de descartar la información, activa la lógica de **Creación Just-In-Time (JIT)**, inicializando automáticamente la infraestructura necesaria y persistiendo los datos recibidos.

Este comportamiento demuestra la capacidad de autosanación del sistema y su aptitud para escalar dinámicamente sin intervención manual.

### 6.3. Test de resolución de conflictos (LWW)

Mediante el script [`conflict_test.sh`](./nats-kv-syncd/test/conflict_test.sh) se fuerzan condiciones de carrera para validar el carácter determinista del algoritmo de resolución de conflictos.

* **Escenario**  
  Se realizan escrituras concurrentes sobre la misma clave en distintos nodos del sistema.

* **Lógica validada**  
  El sistema aplica el algoritmo **Last-Writer-Wins (LWW)**, comparando los relojes lógicos (`LogicalTS`) y resolviendo empates mediante el identificador del nodo (`NodeID`). El resultado es que todos los nodos convergen hacia el mismo valor final, independientemente del orden de recepción de las operaciones.

Este test confirma que el sistema garantiza consistencia eventual y convergencia determinista ante actualizaciones concurrentes.

### 6.4. Análisis de tiempos y garantías de sincronización

El motor de sincronización implementado ofrece dos niveles complementarios de garantía para adaptarse a distintos escenarios de fallo:

1. **Sincronización basada en eventos (tiempo real)**  
   Mientras la infraestructura de red y los servidores NATS permanecen operativos, las actualizaciones se replican de forma inmediata mediante JetStream.

2. **Sincronización mediante ciclo de control (5 minutos)**  
   En escenarios de desconexión o recuperación parcial, el bucle periódico de anti-entropía actúa como mecanismo de seguridad. Este ciclo garantiza que, tras restablecer la conectividad, los nodos intercambien su estado y converjan automáticamente, incluso si el proceso del agente no se ha reiniciado.

Este enfoque híbrido permite combinar eficiencia en condiciones normales con robustez ante fallos, cumpliendo los requisitos de fiabilidad establecidos para el sistema.

## 7. Resultados de las pruebas

Tras la ejecución completa de la suite de validación en el entorno de desarrollo (Docker Compose y scripts Bash automatizados), se han obtenido resultados satisfactorios en todos los escenarios críticos definidos. El sistema demuestra una convergencia consistente del estado distribuido, así como una gestión robusta de la infraestructura dinámica ante fallos y cambios topológicos.

Las pruebas confirman que el agente es capaz de mantener consistencia eventual, tolerar desconexiones parciales y adaptarse dinámicamente a la aparición de nuevos almacenes de datos.

### 7.1. Tabla de resultados

| Prueba | Objetivo | Resultado | Observación técnica |
| --- | --- | --- | --- |
| **Resiliencia (Red)** | Recuperación tras caída de NATS | **ÉXITO** | El agente detecta la desconexión, reintenta la conexión automáticamente y recupera el estado global mediante el ciclo de anti-entropía. |
| **Creación JIT** | Auto-instanciación de buckets | **ÉXITO** | El nodo remoto inicializa dinámicamente el bucket `inventario` al recibir tráfico desconocido, sin configuración previa. |
| **Resolución LWW** | Consistencia ante conflictos | **ÉXITO** | Escrituras concurrentes convergen de forma determinista usando `LogicalTS` y desempate por `NodeID`. |
| **Tombstones** | Propagación de borrados | **ÉXITO** | Las eliminaciones realizadas en aislamiento se replican correctamente tras la reconexión del nodo. |

### 7.2. Evidencia de ejecución y observaciones

Durante la ejecución de las pruebas, los logs del sistema permiten observar de forma explícita la activación de los mecanismos de control y autosanación implementados. En particular, se identifican los siguientes eventos relevantes:

* Inicialización dinámica de infraestructura ante tráfico desconocido:
```
[SYSTEM] Creación JIT: Inicializando bucket 'inventario' por mensaje entrante
```

* Activación del protocolo de sincronización tras recuperación de conectividad:
```
[SYSTEM] Recibido PING de site-b. Iniciando transferencia de estado...
```

Estas trazas confirman que el sistema no solo detecta correctamente los eventos de control (`sync`, `state`), sino que reacciona de forma autónoma aplicando la lógica de convergencia definida, sin requerir intervención manual ni reinicio de procesos.

En conjunto, los resultados validan que la arquitectura propuesta cumple los objetivos de robustez, escalabilidad y consistencia eventual establecidos para el proyecto.


## 8. Conclusiones finales

El desarrollo del agente sincronizador multi-bucket, basado en una arquitectura descentralizada mediante **Leafnodes**, permite extraer conclusiones relevantes en el ámbito del diseño y la validación de sistemas distribuidos con consistencia eventual.

* **Descentralización real y tolerancia a fallos**:  
  La arquitectura implementada demuestra que es posible mantener nodos completamente autónomos, capaces de operar de forma aislada ante fallos de red o caídas de servidores remotos. La sincronización posterior, una vez restaurada la conectividad, se produce sin pérdida de información ni intervención manual, validando el enfoque descentralizado propuesto.

* **Consistencia eventual reforzada mediante anti-entropía**:  
  Los resultados obtenidos confirman que la replicación basada únicamente en eventos no es suficiente en entornos no fiables. La incorporación de un ciclo periódico de anti-entropía actúa como un mecanismo de seguridad que garantiza la convergencia global del estado incluso ante desconexiones prolongadas o fallos parciales de infraestructura.

* **Escalabilidad y adaptabilidad operativa (Just-In-Time)**:  
  La creación dinámica de infraestructura KV y de metadatos permite que el sistema escale horizontalmente sin requerir reconfiguración previa. Este enfoque reduce la complejidad operativa y facilita la incorporación de nuevos dominios de datos de forma transparente para el resto de nodos.

* **Determinismo en la resolución de conflictos**:  
  El uso combinado de relojes lógicos y la estrategia **Last Writer Wins (LWW)** con desempate determinista por identificador de nodo garantiza que todos los nodos converjan al mismo estado final, independientemente del orden de recepción de los eventos o de la latencia de red.

El proyecto desarrollado evidencia que la correcta combinación de mecanismos de mensajería persistente, sincronización híbrida y resolución determinista de conflictos permite construir sistemas distribuidos capaces de mantener la consistencia eventual sin sacrificar autonomía ni tolerancia a fallos. 

