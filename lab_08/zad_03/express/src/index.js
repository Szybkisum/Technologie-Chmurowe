const express = require("express");
const bodyParser = require("body-parser");
const Redis = require("ioredis");
const { Pool } = require("pg");

const app = express();
app.use(bodyParser.json());
const PORT = 3000;
const redis = new Redis({ host: "redis", port: 6379 });
const postgres = new Pool({
  user: "user",
  host: "postgres",
  database: "db",
  password: "password",
  port: 5432,
});

const wait = (ms) => new Promise((res) => setTimeout(res, ms));

async function waitForPostgres(client, maxRetries = 10, delay = 2000) {
  for (let i = 0; i < maxRetries; i++) {
    try {
      await client.query("SELECT 1");
      console.log("Postgres is ready");
      return;
    } catch (err) {
      console.log(`Waiting for Postgres... (${i + 1}/${maxRetries})`);
      await wait(delay);
    }
  }
  throw new Error("Postgres failed to be ready after retries");
}

(async () => {
  try {
    await waitForPostgres(postgres);

    await postgres.query(`
      CREATE TABLE IF NOT EXISTS data (
        key TEXT PRIMARY KEY,
        value JSONB
      );
    `);
    console.log("Postgres table is ready");
  } catch (err) {
    console.error("Postgres setup failed:", err);
    process.exit(1);
  }
})();

postgres
  .connect()
  .then(() => {
    console.log("Connected to Postgres");
    return postgres.query(`
    CREATE TABLE IF NOT EXISTS data (
      key TEXT PRIMARY KEY,
      value JSONB
    );
  `);
  })
  .then(() => console.log("Table initialized"))
  .catch((err) => console.error("Postgres error:", err));

app.get("/:key", async (req, res) => {
  const { key } = req.params;
  const value = await redis.get(key);
  if (!value) return res.status(404).send("Not found in Redis");
  await postgres.query(
    "INSERT INTO data (key, value) VALUES ($1, $2) ON CONFLICT (key) DO NOTHING",
    [key, value]
  );

  res.json(JSON.parse(value));
});

app.post("/", async (req, res) => {
  const { key, value } = req.body;
  if (!key || value === undefined)
    return res.status(400).send("Missing key or value");
  res.status(201).send("Saved to Redis");
  await redis.set(key, JSON.stringify(value));
});

app.get("/postgres/:key", async (req, res) => {
  const { key } = req.params;
  const result = await postgres.query("SELECT value FROM data WHERE key = $1", [
    key,
  ]);
  if (result.rows.length) {
    res.json(result.rows[0].value);
  } else {
    res.status(404).send("Not found in Postgres");
  }
});

app.listen(PORT, () => {
  console.log(`Server listening on http://localhost:${PORT}`);
});
