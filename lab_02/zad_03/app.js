const express = require("express");
const mongoose = require("mongoose");

const app = express();
const PORT = 8080;

const mongoURI = "mongodb://host.docker.internal:27017/mydb";
mongoose.connect(mongoURI, { useNewUrlParser: true, useUnifiedTopology: true });
const Item = mongoose.model(
  "Item",
  new mongoose.Schema({ name: String, value: Number }),
  "entries"
);

app.get("/", async (req, res) => res.json(await Item.find()));

app.listen(PORT, () => {
  console.log(`Server działa`);
});
