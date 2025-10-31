import { connect, JSONCodec, type NatsConnection, type Subscription } from "nats";
import type { Database } from "better-sqlite3";

type ChangeRow = {
  table: string; pk: string; cid: string; val: any;
  col_version: number; db_version: number; site_id: string; cl: number; seq: number;
};

const jc = JSONCodec<ChangeRow[]>();

export function dbVersion(db: Database): number {
  return (db.prepare(`SELECT crsql_db_version() AS v`).get() as any).v as number;
}

export function siteId(db: Database): string {
  return (db.prepare(`SELECT hex(crsql_site_id()) AS id`).get() as any).id as string;
}

// Solo los cambios locales (originados en este peer)
function selectLocalChanges(db: Database, since = 0): ChangeRow[] {
  return db.prepare(`
    SELECT "table","pk","cid","val","col_version","db_version","site_id","cl","seq"
    FROM crsql_changes
    WHERE db_version > ? AND site_id = crsql_site_id()
    ORDER BY db_version ASC
  `).all(since) as ChangeRow[];
}

// Aplica un lote de cambios remotos
function applyChanges(db: Database, rows: ChangeRow[]) {
  if (!rows.length) return;

  const stmt = db.prepare(`
    INSERT INTO crsql_changes
      ("table","pk","cid","val","col_version","db_version","site_id","cl","seq")
    VALUES (?,?,?,?,?,?,?,?,?)
  `);

  const trx = db.transaction((batch: ChangeRow[]) => {
    for (const r of batch) {
      let safeVal: any = r.val;

      // 🔒 Convertimos cualquier valor a algo aceptado por SQLite
      switch (typeof safeVal) {
        case "undefined":
          safeVal = null;
          break;
        case "boolean":
          safeVal = safeVal ? 1 : 0;
          break;
        case "bigint":
          safeVal = Number(safeVal);
          break;
        case "object":
          if (safeVal === null) break;
          try {
            // Convertimos cualquier objeto o array en JSON legible
            safeVal = JSON.stringify(safeVal);
          } catch {
            safeVal = String(safeVal);
          }
          break;
        case "symbol":
        case "function":
          safeVal = String(safeVal);
          break;
        default:
          // number / string ya válidos
          break;
      }

      // Ejecutar el insert con parámetros posicionales
      stmt.run([
        r.table,
        r.pk,
        r.cid,
        safeVal,
        r.col_version,
        r.db_version,
        r.site_id,
        r.cl,
        r.seq
      ]);
    }
  });

  trx(rows);
}

export type NatsSync = { nc: NatsConnection; sub: Subscription; stop: () => Promise<void> };

/**
 * Sincronización reactiva por Core NATS (pub/sub best-effort)
 */
export async function startNatsSync(db: Database, opts: {
  url: string;
  room: string;
  peerName: string;
  publishIntervalMs?: number;
}): Promise<NatsSync> {
  const { url, room, peerName, publishIntervalMs = 200 } = opts;
  const nc = await connect({ servers: url, name: `crsqlite-${peerName}` });
  const subject = `crsql.${room}.changes`;

  let lastSent = 0;
  const mySite = siteId(db);

  // Enviar cambios locales cada X ms
  const timer = setInterval(() => {
    try {
      const rows = selectLocalChanges(db, lastSent);
      if (rows.length) {
        const max = Math.max(...rows.map(r => r.db_version));
        nc.publish(subject, jc.encode(rows));
        lastSent = max;
        console.log(`[${peerName}] publicó ${rows.length} cambios`);
      }
    } catch (e) {
      console.error(`[${peerName}] error al publicar`, e);
    }
  }, publishIntervalMs);

  // Escuchar cambios de otros peers
  const sub = nc.subscribe(subject);
  (async () => {
    for await (const m of sub) {
      try {
        const rows = jc.decode(m.data);
        if (rows.length && rows[0].site_id === mySite) continue; // evita eco
        applyChanges(db, rows);
        console.log(`[${peerName}] aplicó ${rows.length} cambios remotos`);
      } catch (e) {
        console.error(`[${peerName}] error al suscribirse`, e);
      }
    }
  })();

  async function stop() {
    clearInterval(timer);
    sub.unsubscribe();
    await nc.drain();
  }

  return { nc, sub, stop };
}
