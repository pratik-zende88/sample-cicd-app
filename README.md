# Sample App — CI/CD Pipeline Demo

A minimal Node.js/Express app used to demonstrate a full CI/CD pipeline:
GitHub → Jenkins → Docker → Container Registry → Server/Kubernetes → Monitoring.

## Endpoints
- `GET /` — basic hello response
- `GET /health` — health check (used by Docker/K8s probes and Jenkins test stage)
- `GET /metrics` — basic uptime/memory metrics (for Prometheus scraping)

## Run locally
```bash
npm install
cp .env.example .env
npm start
```
Visit http://localhost:3000

## Run tests
```bash
npm test
```

## Build & run with Docker
```bash
docker build -t sample-app .
docker run -p 3000:3000 sample-app
```

## Project structure
```
app/
├── Dockerfile
├── package.json
├── app.js
├── test.js
├── .env.example
├── .gitignore
└── README.md
```
