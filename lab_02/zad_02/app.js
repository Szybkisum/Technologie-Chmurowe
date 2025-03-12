const express = require("express");

const app = express();
const PORT = 8080;

app.get("/", (req, res) => {
  res.json({ date: new Date().toISOString() });
});

app.listen(PORT, () => {
  console.log(`Server działa`);
});
