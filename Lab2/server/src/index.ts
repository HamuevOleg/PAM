import { serve } from "@hono/node-server";
import { openDatabase } from "./database.js";
import { createApp } from "./app.js";
const port = Number(process.env.PORT ?? 8080);
const db = openDatabase(process.env.DB_PATH ?? "data/app.db");
const app = createApp(
  db,
  process.env.JWT_SECRET ?? "runbaza-local-lab5-secret-change-for-production",
);
const server = serve(
  { fetch: app.fetch, port, hostname: process.env.HOST ?? "127.0.0.1" },
  () => console.log(`RunBaza API http://127.0.0.1:${port}`),
);
for (const signal of ["SIGINT", "SIGTERM"])
  process.on(signal, () =>
    server.close(() => {
      db.close();
      process.exit(0);
    }),
  );
