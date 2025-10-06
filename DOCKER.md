# Docker Guide - NSolid SaaS

Complete guide for building, running, and managing Docker containers with NSolid v6 for SaaS monitoring.

## Quick Start

### Using Docker Compose (Recommended)

```bash
# Set your NSolid SaaS token
echo "NSOLID_SAAS=your-token-here" > .env

# Start application with NSolid v6
docker-compose up -d

# View logs
docker-compose logs -f

# Stop services
docker-compose down
```

**Access Points:**
- **Application:** http://localhost:3000
- **NSolid Console:** https://console.nodesource.com (SaaS)

### Using NPM Scripts

```bash
npm run docker:build   # Build NSolid v6 image
npm run docker:up      # Start with Docker Compose
npm run docker:down    # Stop Docker Compose
npm run docker:logs    # View logs
```

## Docker Image

**Single NSolid Image:**
- **Base:** `nodesource/nsolid:latest`
- **Size:** ~200MB
- **Ports:** 3000 (app only)
- **Runtime:** NSolid v6 with SaaS profiling
- **Monitoring:** Cloud-based via NSolid SaaS

## Building the Image

### Using Docker CLI

```bash
# Build NSolid image
docker build -t vue-ssr-app:latest .

# Build with specific tag
docker build -t vue-ssr-app:v1.0.0 .
```

### Using NPM

```bash
npm run docker:build
```

## Running the Container

### Using Docker Run

```bash
docker run -d \
  --name vue-ssr-app \
  -p 3000:3000 \
  -e NSOLID_SAAS="your-token" \
  -e NSOLID_APPNAME=vue-ssr-app \
  -e NSOLID_TAGS=ssr,vue,typescript,docker \
  -e NSOLID_TRACING_ENABLED=1 \
  vue-ssr-app:latest
```

### Using Docker Compose

The `docker-compose.yml` includes:
- **vue-ssr-app** - NSolid application on port 3000

```bash
# Set your token in .env
echo "NSOLID_SAAS=your-token-here" > .env

# Start application
docker-compose up -d

# View logs
docker-compose logs -f

# Stop
docker-compose down
```

## Environment Variables

### Required Configuration

```bash
# Application
PORT=3000

# NSolid SaaS (Required)
NSOLID_SAAS=your-saas-token-here

# NSolid Settings
NSOLID_APPNAME=vue-ssr-app
NSOLID_TAGS=ssr,vue,typescript,docker
NSOLID_TRACING_ENABLED=1
```

### Setting Variables

**Docker Compose (Recommended):**
Create `.env` file in project root:
```bash
NSOLID_SAAS=your-token-here
```

**Docker Run:**
```bash
docker run -e NSOLID_SAAS="your-token" vue-ssr-app:latest
```

## Testing the Container

### Health Check

```bash
curl http://localhost:3000/api/health
```

### Load Testing

```bash
# Start container
docker-compose up -d

# Run k6 from host
k6 run --duration 60s --vus 20 loadtest/k6-test.js

# Run Artillery from host
artillery run loadtest/artillery.yml

# Check metrics
curl http://localhost:3000/api/metrics
```

### Monitor Container

```bash
# Real-time stats
docker stats vue-ssr-app

# Container info
docker inspect vue-ssr-app

# Process list
docker top vue-ssr-app
```

## NSolid v6 Profiling

### Using NSolid SaaS

1. **Set token in `.env`:**
   ```bash
   NSOLID_SAAS=your-token-here
   ```

2. **Start container:**
   ```bash
   docker-compose up -d
   ```

3. **Access NSolid Cloud Console:**
   https://console.nodesource.com

4. **Generate load:**
   ```bash
   curl "http://localhost:3000/api/cpu-load?n=35"
   curl "http://localhost:3000/api/memory-load?size=10"
   curl "http://localhost:3000/api/combined-load?cpu=35&memory=10&delay=100"
   ```

5. **Profile in console:**
   - Start CPU profiling
   - Generate sustained load
   - Stop profiling and analyze


## Pushing to Registry

### Docker Hub

```bash
# Login
docker login

# Tag
docker tag vue-ssr-app:latest yourusername/vue-ssr-app:latest

# Push
docker push yourusername/vue-ssr-app:latest
```

### Private Registry

```bash
# Tag
docker tag vue-ssr-app:latest registry.example.com/vue-ssr-app:latest

# Push
docker push registry.example.com/vue-ssr-app:latest
```

## Troubleshooting

### Container Won't Start

```bash
# Check logs
docker logs vue-ssr-app

# Check if port is in use
netstat -ano | findstr :3000  # Windows
lsof -i :3000                 # Linux/Mac

# Restart container
docker restart vue-ssr-app
```

### Build Fails

```bash
# Clean Docker cache
docker builder prune

# Rebuild without cache
docker build --no-cache -t vue-ssr-app:latest .
```

### NSolid Not Connecting

```bash
# Check environment variables
docker exec vue-ssr-app env | grep NSOLID

# Check exposed ports
docker port vue-ssr-app

# Check NSolid logs
docker logs vue-ssr-app
```

## Multi-Stage Build

The Dockerfile uses multi-stage builds with NSolid v6:

```
Stage 1: Builder (NSolid v6)
├── Install all dependencies
├── Build client (Vite)
└── Build server (Vite SSR)
    │
    └─> Stage 2: Production (NSolid v6)
        ├── Production dependencies only
        ├── Built assets from builder
        ├── tsx runtime
        └── NSolid v6 runtime with profiling
```

## Production Deployment

### AWS ECS/Fargate

1. Push image to ECR
2. Create task definition
3. Create service with load balancer
4. Configure NSolid environment variables

### Google Cloud Run

```bash
# Build and push
gcloud builds submit --tag gcr.io/PROJECT_ID/vue-ssr-app

# Deploy
gcloud run deploy vue-ssr-app \
  --image gcr.io/PROJECT_ID/vue-ssr-app \
  --platform managed \
  --port 3000 \
  --set-env-vars NSOLID_SAAS=your-token
```

### Azure Container Instances

```bash
# Push to ACR
az acr build --registry myregistry --image vue-ssr-app:latest .

# Deploy
az container create \
  --resource-group mygroup \
  --name vue-ssr-app \
  --image myregistry.azurecr.io/vue-ssr-app:latest \
  --ports 3000 9001 9002 9003 6753 \
  --environment-variables NSOLID_SAAS=your-token
```

### Kubernetes

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: vue-ssr-app
spec:
  replicas: 3
  selector:
    matchLabels:
      app: vue-ssr-app
  template:
    metadata:
      labels:
        app: vue-ssr-app
    spec:
      containers:
      - name: vue-ssr-app
        image: vue-ssr-app:latest
        ports:
        - containerPort: 3000
        - containerPort: 9001
        - containerPort: 9002
        - containerPort: 9003
        env:
        - name: NODE_ENV
          value: "production"
        - name: NSOLID_SAAS
          valueFrom:
            secretKeyRef:
              name: nsolid-secret
              key: saas-token
```

## Best Practices

- ✅ Use NSolid v6 for production profiling
- ✅ Set resource limits (CPU/Memory)
- ✅ Enable health checks
- ✅ Use environment variables for configuration
- ✅ Keep images updated
- ✅ Use specific image tags in production
- ✅ Monitor with NSolid Console
- ✅ Set up auto-restart policies

## Quick Reference

```bash
# Build
docker build -t vue-ssr-app:latest .
npm run docker:build

# Run
docker-compose up -d
npm run docker:up

# Logs
docker-compose logs -f
npm run docker:logs

# Stop
docker-compose down
npm run docker:down

# Clean
docker system prune -a

# Stats
docker stats vue-ssr-app

# Health
curl http://localhost:3000/api/health

# Metrics
curl http://localhost:3000/api/metrics
```

## Summary

Your Docker setup with NSolid v6 SaaS includes:

- ✅ Simple two-stage Dockerfile with NSolid v6
- ✅ Docker Compose orchestration
- ✅ NPM scripts for common tasks
- ✅ Health checks and monitoring
- ✅ NSolid SaaS profiling (cloud-based)
- ✅ Production-ready configuration
- ✅ Single port exposure (3000)

**Key Points:**
- Uses NSolid v6 latest image
- Connects to NSolid SaaS for monitoring
- No local console ports needed
- Simple `.env` configuration

For application documentation, see [README.md](./README.md)
