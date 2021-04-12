import * as functions from "firebase-functions";
import express from "express";
import helmet from "helmet";
import url from "url";

export const app = express();

// Allowed domains.
const domains = ["localhost:5000", "flybis.net"];
// Base URL to redirect.
const baseUrl = "https://flybis.net/";

app.use(helmet());

// Redirect middleware.
app.use((req, res, next) => {
  if (!domains.includes(req.headers.host)) {
    console.log("Redirecting");

    res
      .status(301)
      .redirect(url.resolve(baseUrl, req.path.replace(/^\/+/, "")));
    return;
  }

  console.log("Not Redirecting");

  next();
  return;
});

// Dynamically route static html files.
app.get("/", (req, res) => {
  res.sendFile("index.html", { root: "./html" });
  return;
});

app.get("/app/*", (req, res) => {
  res.sendFile("/app/index.html", { root: "./html" });
  return;
});

// 404 middleware.
app.use((req, res) => {
  res.status(404).sendFile("404.html", { root: "./html" });
  return;
});
