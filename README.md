# Vue SSR Application with Load Testing & NSolid v6 Profiling

Production-ready Vue 3 SSR application built with TypeScript, Express, and Vite. Runs on NSolid v6 for advanced profiling and monitoring.

## Features

- ✅ Server-Side Rendering (SSR) with Vue 3 + TypeScript
- ✅ Express server with compression and load testing endpoints
- ✅ NSolid v6 runtime for CPU and memory profiling
- ✅ Docker containerization with NSolid v6
- ✅ CI/CD pipeline with GitHub Actions
- ✅ Load testing with k6 and Artillery

## Quick Start

### 1. Install Dependencies

```bash
npm install
```

### 2. Build and Run Application

```bash
npm run build
npm start
```

Visit: **http://localhost:3000**

## Load Testing Endpoints

| Endpoint | Purpose | Example |
|----------|---------|---------|
| `/api/health` | Server health check | `curl http://localhost:3000/api/health` |
| `/api/metrics` | Performance metrics | `curl http://localhost:3000/api/metrics` |
| `/api/cpu-load` | CPU stress test | `curl http://localhost:3000/api/cpu-load?n=35` |
| `/api/memory-load` | Memory allocation | `curl http://localhost:3000/api/memory-load?size=10` |
| `/api/async-load` | Async operations | `curl http://localhost:3000/api/async-load?delay=100` |
| `/api/combined-load` | Combined stress | `curl "http://localhost:3000/api/combined-load?cpu=30&memory=5&delay=50"` |

## Running Load Tests

### Using PowerShell (Windows)

```powershell
# k6 load test
.\scripts\run-loadtest.ps1 -TestType k6 -Duration 60 -VirtualUsers 20

# Artillery load test
.\scripts\run-loadtest.ps1 -TestType artillery

# Simple HTTP test
.\scripts\run-loadtest.ps1 -TestType simple
```

### Using Bash (Linux/Mac)

```bash
chmod +x scripts/run-loadtest.sh

# k6 load test
./scripts/run-loadtest.sh k6 60 20

# Artillery load test
./scripts/run-loadtest.sh artillery

# Simple HTTP test
./scripts/run-loadtest.sh simple
```

### Manual Load Testing

```bash
# Install k6
# Windows: choco install k6
# Mac: brew install k6
# Linux: See https://k6.io/docs/getting-started/installation/

# Run k6 test
k6 run loadtest/k6-test.js

# Install Artillery
npm install -g artillery

# Run Artillery test
artillery run loadtest/artillery.yml
```

## NSolid Profiling

### Quick Start with NSolid SaaS

1. **Set your NSolid SaaS token** in `.env`:
   ```bash
   NSOLID_SAAS=your-token-here
   ```

2. **Run with Docker** (easiest):
   ```bash
   docker-compose up -d
   ```

3. **Or install NSolid locally** from https://nodesource.com/products/nsolid
   ```bash
   # Build first
   npm run build
   
   # Run with NSolid
   nsolid node_modules/tsx/dist/cli.mjs server/index.ts
   ```

### Profiling Workflow

1. Start app with NSolid
2. Generate load on endpoints
3. Start CPU/Memory profiling in NSolid Console
4. Analyze flame graphs and memory snapshots

### Key Functions to Profile

- `fibonacci(n)` - CPU-intensive recursive calculation
- `allocateMemory(sizeMB)` - Memory allocation patterns
- `render()` - SSR rendering performance
- Express middleware chain - Request handling

## Docker Support

See **[DOCKER.md](./DOCKER.md)** for complete Docker documentation.

### Quick Docker Start

```bash
# Set your NSolid SaaS token in .env
echo "NSOLID_SAAS=your-token-here" > .env

# Start with Docker Compose (NSolid v6)
docker-compose up -d

# Access application
# App: http://localhost:3000
# NSolid Console: https://console.nodesource.com

# Stop services
docker-compose down
```

### Docker NPM Scripts

```bash
npm run docker:build   # Build NSolid v6 image
npm run docker:up      # Start with Docker Compose
npm run docker:down    # Stop Docker Compose
npm run docker:logs    # View logs
```

## Project Structure

```
├── server/
│   └── index.ts              # Express SSR server with load endpoints
├── src/
│   ├── App.vue               # Main Vue component
│   ├── main.ts               # App factory (SSR compatible)
│   ├── entry-client.ts       # Client hydration entry
│   └── entry-server.ts       # Server rendering entry
├── loadtest/
│   ├── artillery.yml         # Artillery configuration
│   ├── k6-test.js           # k6 test script
│   └── processor.js         # Artillery processor
├── scripts/
│   ├── run-loadtest.ps1     # Windows load test runner
│   ├── run-loadtest.sh      # Unix load test runner
│   ├── docker-build.ps1     # Windows Docker management
│   └── docker-build.sh      # Unix Docker management
├── .github/workflows/
│   └── load-test.yml        # CI/CD pipeline
├── Dockerfile                # Multi-stage production build
├── docker-compose.yml        # Docker orchestration
├── package.json              # Dependencies and scripts
└── vite.config.ts           # Vite SSR configuration
```

## Available Scripts

| Script | Description |
|--------|-------------|
| `npm run build` | Build client and server for production |
| `npm start` | Run production build |
| `npm run type-check` | Type check TypeScript |
| `npm run docker:build` | Build NSolid v6 Docker image |
| `npm run docker:up` | Start Docker containers |
| `npm run docker:down` | Stop Docker containers |
| `npm run docker:logs` | View Docker logs |

## CI/CD Pipeline

The GitHub Actions workflow automatically:
- Builds on Node.js 20.x and 22.x
- Runs type checking
- Executes k6 and Artillery load tests
- Uploads test results as artifacts

**Trigger:** Push to `main`/`develop` or create PR

## Environment Variables

Create a `.env` file (see `.env.example`):

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

## Monitoring Metrics

Access real-time metrics at `/api/metrics`:

- Request count and error rate
- Uptime and requests/second
- Memory usage (RSS, Heap)
- CPU usage

## Troubleshooting

### Port Already in Use

```bash
# Windows
netstat -ano | findstr :3000
taskkill /PID <PID> /F

# Linux/Mac
lsof -ti:3000 | xargs kill -9
```

### Dependencies Issues

```bash
rm -rf node_modules package-lock.json
npm install
```

### Build Errors

```bash
npm run type-check  # Check TypeScript errors
npm run build       # See detailed build errors
```

## Production Deployment

1. **Build the application:**
   ```bash
   npm run build
   ```

2. **Deploy with Docker:**
   ```bash
   docker-compose up -d
   ```

3. **Or deploy to cloud platforms:**
   - AWS ECS/Fargate
   - Google Cloud Run
   - Azure Container Instances
   - Kubernetes

## Performance Tips

- Use NSolid to identify bottlenecks
- Monitor `/api/metrics` during load tests
- Adjust `NODE_OPTIONS` for memory limits
- Use Docker for consistent deployments
- Enable compression (already configured)

## Documentation

- **[DOCKER.md](./DOCKER.md)** - Complete Docker guide
- **[.env.example](./.env.example)** - Environment variables template

## License

MIT
