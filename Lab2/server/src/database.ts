import { DatabaseSync } from "node:sqlite";
import { readFileSync, mkdirSync } from "node:fs";
import { dirname, resolve } from "node:path";
import { schemas } from "./schema.js";

export function openDatabase(path: string, seed = true) {
  if (path !== ":memory:")
    mkdirSync(dirname(resolve(path)), { recursive: true });
  const db = new DatabaseSync(path);
  db.exec(`PRAGMA foreign_keys=ON; PRAGMA journal_mode=WAL;
    CREATE TABLE IF NOT EXISTS users(id INTEGER PRIMARY KEY AUTOINCREMENT,email TEXT NOT NULL UNIQUE,name TEXT NOT NULL,password_hash TEXT NOT NULL);
    CREATE TABLE IF NOT EXISTS races(id TEXT PRIMARY KEY,user_id INTEGER REFERENCES users(id),race_id TEXT,data TEXT NOT NULL,search_text TEXT NOT NULL);
    CREATE TABLE IF NOT EXISTS files(id INTEGER PRIMARY KEY AUTOINCREMENT,user_id INTEGER NOT NULL REFERENCES users(id),name TEXT NOT NULL,type TEXT NOT NULL,bytes BLOB NOT NULL);`);
  for (const resource of Object.keys(schemas).filter((v) => v !== "races")) {
    db.exec(`CREATE TABLE IF NOT EXISTS ${resource}(id TEXT PRIMARY KEY,user_id INTEGER NOT NULL REFERENCES users(id),race_id TEXT REFERENCES races(id),data TEXT NOT NULL,search_text TEXT NOT NULL);
      CREATE INDEX IF NOT EXISTS ${resource}_owner ON ${resource}(user_id);`);
  }
  db.exec(
    "CREATE UNIQUE INDEX IF NOT EXISTS plans_unique_race ON plans(user_id,race_id); CREATE UNIQUE INDEX IF NOT EXISTS profiles_unique_user ON profiles(user_id);",
  );
  if (seed) {
    const original = JSON.parse(
      readFileSync(new URL("./races.json", import.meta.url), "utf8"),
    ) as Record<string, unknown>[];
    const events = [...original];
    for (let i = 0; i < 20; i++) {
      const base = original[i % original.length];
      events.push({
        ...base,
        id: `demo-${i + 1}`,
        code: `RB ${500 + i}`,
        title: `${base.title} · ${2027 + Math.floor(i / 8)}`,
        season: `Сезон ${2027 + Math.floor(i / 8)}`,
        date: `${String(1 + i).padStart(2, "0")}.06.${2027 + Math.floor(i / 8)}`,
        status: "On time",
      });
    }
    const insert = db.prepare(
      "INSERT OR IGNORE INTO races(id,user_id,data,search_text) VALUES(?,NULL,?,?)",
    );
    for (const event of events) {
      const { id, ...data } = event;
      insert.run(String(id), JSON.stringify(data), searchText(data));
    }
  }
  return db;
}
export function searchText(data: Record<string, unknown>): string {
  return Object.values(data)
    .map((v) => (Array.isArray(v) ? v.join(" ") : String(v ?? "")))
    .join(" ")
    .toLocaleLowerCase();
}
