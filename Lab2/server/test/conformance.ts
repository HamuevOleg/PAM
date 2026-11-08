import { checkContract } from "./checks.js";
await checkContract(process.env.API_BASE_URL ?? "http://127.0.0.1:8080");
