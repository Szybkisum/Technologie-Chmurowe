const express = require("express");
const Redis = require("ioredis");

const app = express();
const PORT = 3000;
const redis = new Redis({ host: "redis", port: 6379 });

app.get("/", async (req, res) => {
  await redis.set("foo", "bar");
  const value = await redis.get("foo");
  res.send(`Value from Redis: ${value}`);
});

app.listen(PORT, () => {
  console.log(`Server listening on http://localhost:${PORT}`);
});
