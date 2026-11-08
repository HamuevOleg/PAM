// Local integration-test fixture. Never imported by the production server.
import { createServer } from "node:http";
import { serve } from "@hono/node-server";
import { openDatabase } from "../src/database.js";
import { createApp } from "../src/app.js";
let db: ReturnType<typeof openDatabase>;
let server: ReturnType<typeof serve> | undefined;
let secret = "ios-test-secret";
function start() {
  if (server) return;
  db = openDatabase("data/ios-demo.db");
  server = serve({
    fetch: createApp(db, secret).fetch,
    port: 8090,
    hostname: "127.0.0.1",
  });
}
async function stop() {
  if (!server) return;
  await new Promise<void>((resolve) => server!.close(() => resolve()));
  server = undefined;
  db.close();
}
start();
const controller = createServer(async (req, res) => {
  if (req.method !== "POST") {
    res.writeHead(405);
    res.end();
    return;
  }
  if (req.url === "/stop") await stop();
  else if (req.url === "/start") start();
  else if (req.url === "/rotate") {
    await stop();
    secret += "-rotated";
    start();
  } else {
    res.writeHead(404);
    res.end();
    return;
  }
  res.writeHead(200, { "Content-Type": "application/json" });
  res.end('{"ok":true}');
}).listen(8091, "127.0.0.1", () =>
  console.log("iOS test API :8090, controller :8091"),
);
process.on("SIGTERM", async () => {
  await stop();
  controller.close();
  process.exit(0);
});
