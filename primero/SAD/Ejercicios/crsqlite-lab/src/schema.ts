import type { Database } from "better-sqlite3";

export function applySchema(db: Database) {
  db.exec(`
    CREATE TABLE IF NOT EXISTS todos (
      id TEXT PRIMARY KEY NOT NULL,
      text TEXT NOT NULL DEFAULT '',
      done INTEGER NOT NULL DEFAULT 0
    );
    -- Turn table into a CRR so it can merge across peers:
    SELECT crsql_as_crr('todos');
  `);
}
