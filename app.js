const express = require("express");
const app = express();

const PORT = process.env.PORT || 3000;
const APP_NAME = process.env.APP_NAME || "sample-app";

// Main route
app.get("/", (req, res) => {
  res.json({
    message: `Hello from ${APP_NAME}!`,
    status: "running",
    timestamp: new Date().toISOString()
  });
});

// Health check endpoint - used by Docker/Kubernetes/monitoring
app.get("/health", (req, res) => {
  res.status(200).json({ status: "healthy" });
});

// Basic metrics endpoint - useful for Prometheus scraping later
app.get("/metrics", (req, res) => {
  const mem = process.memoryUsage();
  res.set("Content-Type", "text/plain");
  res.send(
    `app_uptime_seconds ${process.uptime()}\n` +
    `app_memory_rss_bytes ${mem.rss}\n` +
    `app_memory_heap_used_bytes ${mem.heapUsed}\n`
  );
});

app.listen(PORT, () => {
  console.log(`${APP_NAME} listening on port ${PORT}`);
});

module.exports = app;
