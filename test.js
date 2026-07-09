// Basic smoke test - no extra test framework needed.
// Jenkins "Test" stage will run: npm test

const http = require("http");
const { spawn } = require("child_process");

const PORT = 3999;
process.env.PORT = PORT;

console.log("Starting app for smoke test...");
const server = spawn("node", ["app.js"], {
  env: { ...process.env, PORT },
  stdio: "inherit"
});

setTimeout(() => {
  http.get(`http://localhost:${PORT}/health`, (res) => {
    if (res.statusCode === 200) {
      console.log("✅ Test passed: /health returned 200");
      server.kill();
      process.exit(0);
    } else {
      console.error(`❌ Test failed: /health returned ${res.statusCode}`);
      server.kill();
      process.exit(1);
    }
  }).on("error", (err) => {
    console.error("❌ Test failed:", err.message);
    server.kill();
    process.exit(1);
  });
}, 1500);
