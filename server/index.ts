import type { Request, Response } from 'express'

const fs = require('node:fs')
const path = require('node:path')
const express = require('express')
const compression = require('compression')
const serveStatic = require('serve-static')

// Optional NSolid support (only available when running with NSolid runtime)
let nsolid: any = null
try {
  nsolid = require('nsolid')
} catch (e) {
  // NSolid not available, running with regular Node.js
}

const port = process.env.PORT || 3000
const base = process.env.BASE || '/'

// Create Express app
const app = express()

// Add compression middleware
app.use(compression())

// Template HTML (production only)
const templateHtml = fs.readFileSync(path.resolve(__dirname, '../dist/client/index.html'), 'utf-8')

// SSR manifest for production
const ssrManifest = fs.readFileSync(path.resolve(__dirname, '../dist/client/.vite/ssr-manifest.json'), 'utf-8')

async function initializeServer() {
  // Serve static files from dist/client
  app.use(base, serveStatic(path.resolve(__dirname, '../dist/client'), { index: false }))

// Load testing utilities
interface LoadTestMetrics {
  requestCount: number
  startTime: number
  errors: number
}

const metrics: LoadTestMetrics = {
  requestCount: 0,
  startTime: Date.now(),
  errors: 0
}

// Global error handlers to prevent crashes
process.on('uncaughtException', (err) => {
  console.error('Uncaught Exception:', err)
  metrics.errors++
})

process.on('unhandledRejection', (reason, promise) => {
  console.error('Unhandled Rejection at:', promise, 'reason:', reason)
  metrics.errors++
})

// CPU-intensive function for load testing
function fibonacci(n: number): number {
  if (n <= 1) return n
  return fibonacci(n - 1) + fibonacci(n - 2)
}

// Memory-intensive function for load testing
function allocateMemory(sizeMB: number): Buffer[] {
  const buffers: Buffer[] = []
  const iterations = Math.floor(sizeMB)
  for (let i = 0; i < iterations; i++) {
    buffers.push(Buffer.alloc(1024 * 1024)) // 1MB buffer
  }
  return buffers
}

// API endpoints for load testing
app.get('/api/health', (req: Request, res: Response) => {
  res.json({ 
    status: 'ok', 
    uptime: process.uptime(),
    memory: process.memoryUsage(),
    timestamp: new Date().toISOString()
  })
})

app.get('/api/metrics', (req: Request, res: Response) => {
  const uptime = (Date.now() - metrics.startTime) / 1000
  res.json({
    requestCount: metrics.requestCount,
    errors: metrics.errors,
    uptime,
    requestsPerSecond: metrics.requestCount / uptime,
    memory: process.memoryUsage(),
    cpu: process.cpuUsage()
  })
})

// CPU load endpoint with NSolid profiling
app.get('/api/cpu-load', async (req: Request, res: Response) => {
  // Start profiling if NSolid is available
  if (nsolid) {
    nsolid.profile(4000, (err: any) => {
      if (err) {
        console.error('NSolid profiling error:', err)
      }
    })
  }
  const n = parseInt(req.query.n as string) || 40
  const start = Date.now()
  const result = fibonacci(n)
  const duration = Date.now() - start
  
  res.json({
    result,
    duration,
    input: n,
    timestamp: new Date().toISOString()
  })
})

// Memory load endpoint
app.get('/api/memory-load', (req: Request, res: Response) => {
  const sizeMB = parseInt(req.query.size as string) || 10
  const start = Date.now()
  const buffers = allocateMemory(sizeMB)
  const duration = Date.now() - start
  
  // Keep buffers in memory briefly
  setTimeout(() => {
    buffers.length = 0
  }, 1000)
  
  res.json({
    allocatedMB: sizeMB,
    duration,
    memory: process.memoryUsage(),
    timestamp: new Date().toISOString()
  })
})

// Async load endpoint (simulates DB queries)
app.get('/api/async-load', async (req: Request, res: Response) => {
  const delay = parseInt(req.query.delay as string) || 100
  const start = Date.now()
  
  await new Promise(resolve => setTimeout(resolve, delay))
  
  const duration = Date.now() - start
  res.json({
    delay,
    actualDuration: duration,
    timestamp: new Date().toISOString()
  })
})

// Combined load endpoint
app.get('/api/combined-load', async (req: Request, res: Response) => {
  const cpuWork = parseInt(req.query.cpu as string) || 30
  const memoryMB = parseInt(req.query.memory as string) || 5
  const asyncDelay = parseInt(req.query.delay as string) || 50
  
  const start = Date.now()
  
  // CPU work
  const fibResult = fibonacci(cpuWork)
  
  // Memory allocation
  const buffers = allocateMemory(memoryMB)
  
  // Async work
  await new Promise(resolve => setTimeout(resolve, asyncDelay))
  
  // Cleanup
  setTimeout(() => {
    buffers.length = 0
  }, 1000)
  
  const duration = Date.now() - start
  
  res.json({
    fibResult,
    allocatedMB: memoryMB,
    asyncDelay,
    totalDuration: duration,
    memory: process.memoryUsage(),
    timestamp: new Date().toISOString()
  })
})

// SSR handler
app.use('*', async (req: Request, res: Response) => {
  try {
    metrics.requestCount++
    
    // Load production build
    const template = templateHtml
    const entryServer = await import('../dist/server/entry-server.mjs')
    const render = entryServer.render

    const appHtml = await render()

    const html = template
      .replace(`<!--app-html-->`, appHtml)
      .replace(`<!--app-head-->`, '')

    res.status(200).set({ 'Content-Type': 'text/html' }).send(html)
  } catch (e: any) {
    metrics.errors++
    console.error(e.stack)
    res.status(500).end(e.stack)
  }
})

  // Start server
  app.listen(port, () => {
    console.log(`🚀 Server running at http://localhost:${port}`)
    console.log(`📊 Metrics available at http://localhost:${port}/api/metrics`)
    console.log(`🏥 Health check at http://localhost:${port}/api/health`)
    console.log(`\n🔧 Load Testing Endpoints:`)
    console.log(`   - CPU Load: http://localhost:${port}/api/cpu-load?n=35`)
    console.log(`   - Memory Load: http://localhost:${port}/api/memory-load?size=10`)
    console.log(`   - Async Load: http://localhost:${port}/api/async-load?delay=100`)
    console.log(`   - Combined: http://localhost:${port}/api/combined-load?cpu=30&memory=5&delay=50`)
  })
}

// Initialize and start the server
initializeServer().catch(err => {
  console.error('Failed to start server:', err)
  process.exit(1)
})
