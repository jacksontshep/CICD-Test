# Setup Summary - Vue SSR with NSolid v6

## ✅ What You Have

A production-ready Vue 3 SSR application with:

- **Runtime:** NSolid v6 (hydrogen-alpine)
- **Framework:** Vue 3 + TypeScript + Vite
- **Server:** Express with compression
- **Profiling:** Full NSolid capabilities
- **Load Testing:** k6 and Artillery ready
- **CI/CD:** GitHub Actions workflow
- **Docker:** Single NSolid v6 image

## 📁 Project Structure

```
CICD Test/
├── server/
│   └── index.ts              # Express SSR server with load endpoints
├── src/
│   ├── App.vue               # Main Vue component
│   ├── main.ts               # App factory
│   ├── entry-client.ts       # Client entry
│   └── entry-server.ts       # Server entry
├── loadtest/
│   ├── artillery.yml         # Artillery config
│   ├── k6-test.js           # k6 test script
│   └── processor.js         # Artillery processor
├── scripts/
│   ├── run-loadtest.ps1     # Load test runner (Windows)
│   ├── run-loadtest.sh      # Load test runner (Unix)
│   ├── docker-build.ps1     # Docker manager (Windows)
│   └── docker-build.sh      # Docker manager (Unix)
├── .github/workflows/
│   └── load-test.yml        # CI/CD pipeline
├── Dockerfile                # NSolid v6 multi-stage build
├── docker-compose.yml        # Docker orchestration
├── .env                      # Environment variables (with NSOLID_SAAS)
├── package.json              # Dependencies and scripts
├── README.md                 # Main documentation
└── DOCKER.md                 # Docker guide
```

## 🚀 Quick Start

### 1. Local Development

```bash
npm install
npm run dev
```

Visit: http://localhost:3000

### 2. Production Build

```bash
npm run build
npm start
```

### 3. Docker (NSolid v6)

```bash
docker-compose up -d
```

**Access:**
- App: http://localhost:3000
- NSolid Console: http://localhost:6753

## 📊 Load Testing Endpoints

| Endpoint | Purpose | Example |
|----------|---------|---------|
| `/api/health` | Health check | `curl http://localhost:3000/api/health` |
| `/api/metrics` | Performance metrics | `curl http://localhost:3000/api/metrics` |
| `/api/cpu-load` | CPU stress | `curl http://localhost:3000/api/cpu-load?n=35` |
| `/api/memory-load` | Memory stress | `curl http://localhost:3000/api/memory-load?size=10` |
| `/api/async-load` | Async operations | `curl http://localhost:3000/api/async-load?delay=100` |
| `/api/combined-load` | Combined stress | `curl "http://localhost:3000/api/combined-load?cpu=30&memory=5&delay=50"` |

## 🧪 Running Load Tests

### PowerShell (Windows)

```powershell
# k6 load test
.\scripts\run-loadtest.ps1 -TestType k6 -Duration 60 -VirtualUsers 20

# Artillery load test
.\scripts\run-loadtest.ps1 -TestType artillery

# Simple HTTP test
.\scripts\run-loadtest.ps1 -TestType simple
```

### Bash (Linux/Mac)

```bash
chmod +x scripts/run-loadtest.sh

# k6 load test
./scripts/run-loadtest.sh k6 60 20

# Artillery load test
./scripts/run-loadtest.sh artillery
```

## 🔬 NSolid v6 Profiling

### Setup

1. **Your NSOLID_SAAS token is already in `.env`**

2. **Start with Docker:**
   ```bash
   docker-compose up -d
   ```

3. **Access NSolid Console:**
   - Cloud: https://console.nodesource.com
   - Local: http://localhost:6753

### Profiling Workflow

1. Start application (local or Docker)
2. Generate load on endpoints
3. Start CPU/Memory profiling in NSolid Console
4. Analyze flame graphs and memory snapshots

### Key Functions to Profile

- `fibonacci(n)` - CPU-intensive recursive calculation
- `allocateMemory(sizeMB)` - Memory allocation patterns
- `render()` - SSR rendering performance
- Express middleware - Request handling

## 🐳 Docker Commands

### Using NPM Scripts

```bash
npm run docker:build   # Build NSolid v6 image
npm run docker:up      # Start containers
npm run docker:down    # Stop containers
npm run docker:logs    # View logs
```

### Using Management Scripts

**PowerShell:**
```powershell
.\scripts\docker-build.ps1 -Action build
.\scripts\docker-build.ps1 -Action compose-up
.\scripts\docker-build.ps1 -Action logs
```

**Bash:**
```bash
./scripts/docker-build.sh build
./scripts/docker-build.sh compose-up
./scripts/docker-build.sh logs
```

## 📦 Docker Image Details

**Image:** `vue-ssr-app:latest`
- **Base:** nodesource/nsolid:latest
- **Size:** ~200MB
- **Runtime:** NSolid v6
- **Monitoring:** NSolid SaaS (cloud-based)

**Exposed Ports:**
- `3000` - Application only

## 🔄 CI/CD Pipeline

**GitHub Actions** (`.github/workflows/load-test.yml`):
- Builds on Node.js 20.x and 22.x
- Runs type checking
- Executes k6 and Artillery load tests
- Uploads test results as artifacts

**Trigger:** Push to `main`/`develop` or create PR

## 📝 Available Scripts

| Script | Description |
|--------|-------------|
| `npm run dev` | Start in development mode |
| `npm run build` | Build for production |
| `npm start` | Run production build |
| `npm run type-check` | Type check TypeScript |
| `npm run docker:build` | Build NSolid v6 Docker image |
| `npm run docker:up` | Start Docker containers |
| `npm run docker:down` | Stop Docker containers |
| `npm run docker:logs` | View Docker logs |

## 🌍 Environment Variables

**`.env` file (already configured):**

```bash
# Server
PORT=3000
NODE_ENV=development

# NSolid
NSOLID_APPNAME=vue-ssr-app
NSOLID_SAAS=your-token-here

# Performance
NODE_OPTIONS=--max-old-space-size=4096
```

## 🎯 Next Steps

### For Development
1. Run `npm run dev`
2. Make changes to Vue components
3. Test at http://localhost:3000

### For Load Testing
1. Start app: `npm run dev` or `docker-compose up -d`
2. Run tests: `.\scripts\run-loadtest.ps1 -TestType k6`
3. Monitor: `curl http://localhost:3000/api/metrics`

### For NSolid Profiling
1. Start with Docker: `docker-compose up -d`
2. Access NSolid Console: https://console.nodesource.com
3. Generate load: `curl "http://localhost:3000/api/combined-load?cpu=35&memory=10&delay=100"`
4. Profile and analyze in NSolid Console

### For Production Deployment
1. Build: `npm run docker:build`
2. Test locally: `docker-compose up -d`
3. Push to registry: `docker push yourusername/vue-ssr-app:latest`
4. Deploy to cloud (AWS ECS, GCP Cloud Run, Azure, K8s)

## 📚 Documentation

- **[README.md](./README.md)** - Main application documentation
- **[DOCKER.md](./DOCKER.md)** - Complete Docker guide with NSolid v6
- **[.env.example](./.env.example)** - Environment variables template

## ✨ Key Features

- ✅ Vue 3 SSR with TypeScript
- ✅ NSolid v6 runtime for profiling
- ✅ Express server with load testing endpoints
- ✅ Docker containerization
- ✅ Load testing with k6 and Artillery
- ✅ CI/CD pipeline with GitHub Actions
- ✅ Production-ready configuration

## 🎉 You're Ready!

Your Vue SSR application is fully configured and ready for:
- Development and testing
- Load testing and performance analysis
- NSolid v6 profiling and optimization
- Production deployment

**Start developing:** `npm run dev`

**Start profiling:** `docker-compose up -d` → https://console.nodesource.com
