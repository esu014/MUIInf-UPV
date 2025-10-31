import SQLiteDB, {type Database} from "better-sqlite3";
import { extensionPath } from "@vlcn.io/crsqlite";

export function open(dbFile: string): Database {
  const db = new SQLiteDB(dbFile);
  // recommended pragmas from docs
  db.pragma("journal_mode = WAL");
  db.pragma("synchronous = NORMAL");
  db.loadExtension(extensionPath); // <- load cr-sqlite
  return db;
}