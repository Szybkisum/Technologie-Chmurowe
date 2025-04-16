const express = require("express");
const { MongoClient } = require("mongodb");

const app = express();
const PORT = 3000;
const MONGO_URL = "mongodb://db:27017/mydb";

let db;

MongoClient.connect(MONGO_URL)
  .then((client) => {
    db = client.db();
    console.log("Connected to MongoDB");
  })
  .catch((err) => {
    console.error("Failed to connect to MongoDB", err);
  });

app.get("/users", async (req, res) => {
  try {
    const users = await db.collection("users").find().toArray();
    res.json(users);
  } catch (err) {
    res.status(500).json({ error: "Failed to fetch users" });
  }
});

app.listen(PORT, () => {
  console.log(`Server listening on http://localhost:${PORT}`);
});
