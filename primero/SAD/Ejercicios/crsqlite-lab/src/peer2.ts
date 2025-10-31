import { open } from "./db.js";
import { applySchema } from "./schema.js";
import type { Database } from "better-sqlite3";
import express from "express";
import fetch from "node-fetch"; // if using Node<20, npm i node-fetch
// @ts-ignore – or add types if you like
const app = express();
app.use(express.json());

// Simple in-memory cursors (per remote "room")
const lastSent: Record<string, number> = {};
const lastSeen: Record<string, number> = {};

function dbVersion(db: Database): number {
  return (db.prepare(⁠ SELECT crsql_db_version() AS v ⁠).get() as any).v as number;
}

function siteId(db: Database): string {
  return (db.prepare(⁠ SELECT hex(crsql_site_id()) AS id ⁠).get() as any).id as string;
}

// Select only local changes since lastSent[room]
function selectChanges(db: Database, since = 0) {
  return db.prepare(`
    SELECT "table","pk","cid","val","col_version","db_version","site_id","cl","seq"
    FROM crsql_changes
    WHERE db_version > ? AND site_id = crsql_site_id()
    ORDER BY db_version ASC
  `).all(since);
}



function normalizeValue(v: any) {
  if (v === null || v === undefined) return null;
  if (typeof v === "object" && v.type === "Buffer" && Array.isArray(v.data)) {
    // Restaurar buffer binario real
    return Buffer.from(v.data);
  }
  return v;
}

// Apply a changeset from remote
function applyChanges(db: Database, rows: any[]) {
  const stmt = db.prepare(`
    INSERT INTO crsql_changes
      ("table","pk","cid","val","col_version","db_version","site_id","cl","seq")
    VALUES (?,?,?,?,?,?,?,?,?)
  `);
  const trx = db.transaction((batch: any[]) => {
    for (const r of batch) {

      const values = [
          String(r.table ?? ""),
          normalizeValue(r.pk),
          String(r.cid ?? ""),
          r.val === null || r.val === undefined ? null : String(r.val),
          Number(r.col_version ?? 0),
          Number(r.db_version ?? 0),
          normalizeValue(r.site_id),
          r.cl === null || r.cl === undefined ? null : String(r.cl),
          Number(r.seq ?? 0)
        ]
      stmt.run(values);
    }
  });
  trx(rows);
}

export async function runPeer(opts: {
  dbFile: string;
  name: string;
  restServer?: string; // e.g., http://localhost:4000
  room?: string;       // e.g., "demo"
}) {
  const { dbFile, name, restServer = "http://localhost:4000", room = "demo" } = opts;
  const db = open(dbFile);
  applySchema(db);

  console.log(⁠ [${name}] site: ${siteId(db)} ⁠);

  // A helper endpoint so you can poke the peer to create data
  app.post("/add", (req, res) => {
    const id = crypto.randomUUID();
    db.prepare(⁠ INSERT INTO todos (id, text, done) VALUES (?, ?, 0) ⁠)
      .run(id, ⁠ [${name}] item ${new Date().toISOString()} ⁠);
    res.json({ ok: true, id, dbVersion: dbVersion(db) });
  });

  // Pull changes from server (since lastSeen)
  app.post("/pull", async (_req, res) => {
    const since = lastSeen[room] ?? 0;
    const r = await fetch(⁠ ${restServer}/changes/${room}?since=${since} ⁠);
    const rows = await r.json() as any[];
    applyChanges(db, rows);
    if (rows.length) {
      // Track the highest db_version we've seen from server
      const max = Math.max(...rows.map((r: any) => r.db_version));
      lastSeen[room] = max;
    }
    res.json({ pulled: rows.length, lastSeen: lastSeen[room] ?? 0 });
  });

  // Push local changes to server (since lastSent)
  app.post("/push", async (_req, res) => {
    const since = lastSent[room] ?? 0;
    const rows = selectChanges(db, since);
    if (rows.length) {
      const max = Math.max(...rows.map((r: any) => r.db_version));
      await fetch(⁠ ${restServer}/changes/${room} ⁠, {
        method: "POST",
        headers: { "content-type": "application/json" },
        body: JSON.stringify(rows),
      });
      lastSent[room] = max;
    }
    res.json({ pushed: rows.length, lastSent: lastSent[room] ?? 0 });
  });

  app.get("/todos", (_req, res) => {
    const rows = db.prepare(⁠ SELECT * FROM todos ORDER BY id ⁠).all();
    res.json(rows);
  });

  const port = name === "peerA" ? 3001 : 3002;
  app.listen(port, () => console.log(⁠ [${name}] up on http://localhost:${port} ⁠));
}
