import express from "express";
import { open } from "./db.js";
import { applySchema } from "./schema.js";

const app = express();
app.use(express.json());

const dbs = new Map<string, ReturnType<typeof open>>();

function dbFor(room: string) {
  if (!dbs.has(room)) {
    const db = open(`./server_${room}.sqlite`);
    applySchema(db);
    dbs.set(room, db);
  }
  return dbs.get(room)!;
}

// GET: pull server changes since ?since
app.get("/changes/:room", (req, res) => {
  const since = Number(req.query.since ?? 0);
  const db = dbFor(req.params.room);
  const rows = db.prepare(`
    SELECT "table","pk","cid","val","col_version","db_version","site_id","cl","seq"
    FROM crsql_changes
    WHERE db_version > ?
    ORDER BY db_version ASC
  `).all(since);
  res.json(rows);
});

// POST: apply client changes
app.post("/changes/:room", (req, res) => {
  const db = dbFor(req.params.room);
  const rows = req.body as any[];
  const stmt = db.prepare(`
    INSERT INTO crsql_changes
      ("table","pk","cid","val","col_version","db_version","site_id","cl","seq")
    VALUES (?,?,?,?,?,?,?,?,?)
  `);
  const trx = db.transaction(() => {
    for (const r of rows) stmt.run(r.table, r.pk, r.cid, r.val, r.col_version, r.db_version, r.site_id, r.cl, r.seq);
  });
  trx();
  res.json({ applied: rows.length });
});

const PORT = 4000;
app.listen(PORT, () => console.log(`REST sync on http://localhost:${PORT}`));