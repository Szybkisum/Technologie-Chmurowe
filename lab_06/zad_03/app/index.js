const express = require("express");
const mysql = require("mysql2");
const app = express();
const port = 3000;

app.get("/", (req, res) => {
  const con = mysql.createConnection({
    host: "database",
    user: "root",
    password: "secret",
    database: "database",
    port: 3306,
  });

  con.connect(function (err) {
    if (err) {
      res.json({ err });
    } else {
      res.json({ message: "Connected!" });
    }
  });
});

app.listen(port, () => {
  console.log(`Example app listening on port ${port}`);
});
