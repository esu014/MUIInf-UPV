import express from "express";
import type { Database } from "better-sqlite3";
import { open } from "./db.js";
import { applySchema } from "./schema.js";
import { dbVersion, siteId, startNatsSync } from "./natsSync.js";

const app = express();
app.use(express.json());

export async function runPeer(opts: {
  dbFile: string;
  name: string;
  natsUrl?: string; // por ejemplo: nats://localhost:4222
  room?: string;    // canal de sincronización (ej. "demo")
}) {
  const { dbFile, name, natsUrl = "nats://127.0.0.1:4222", room = "demo" } = opts;

  const db = open(dbFile);
  applySchema(db);

  console.log(`[${name}] site: ${siteId(db)}`);
  console.log(`[${name}] conectado a NATS ${natsUrl}, room=${room}`);

  // --- ENDPOINTS FUNCIONALES (CRUD sobre los TODOs) ---
  app.post("/add", (req, res) => {
    const id = crypto.randomUUID();
    const text = (req.body?.text as string) ?? `[${name}] item ${new Date().toISOString()}`;
    db.prepare(`INSERT INTO todos (id, text, done) VALUES (?, ?, 0)`).run(id, text);
    res.json({ ok: true, id, dbVersion: dbVersion(db) });
  });

  app.post("/toggle/:id", (req, res) => {
    const id = req.params.id;
    const row = db.prepare(`SELECT done FROM todos WHERE id = ?`).get(id) as any;
    if (!row) return res.status(404).json({ error: "not found" });
    const newDone = row.done ? 0 : 1;
    db.prepare(`UPDATE todos SET done = ? WHERE id = ?`).run(newDone, id);
    res.json({ ok: true, id, done: newDone, dbVersion: dbVersion(db) });
  });

  app.get("/todos", (_req, res) => {
    const rows = db.prepare(`SELECT * FROM todos ORDER BY id`).all();
    res.json(rows);
  });

  // --- ARRANQUE DE SINCRONIZACIÓN POR NATS ---
  await startNatsSync(db, { url: natsUrl, room, peerName: name });

  const port = name === "peerA" ? 3001 : 3002;
  app.listen(port, () => console.log(`[${name}] escuchando en http://localhost:${port}`));
}
