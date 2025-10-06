<script setup lang="ts">
import { ref } from 'vue'

const response = ref<any>(null)
const loading = ref(false)
const error = ref<string | null>(null)

async function callEndpoint(url: string, label: string) {
  loading.value = true
  error.value = null
  response.value = null
  
  try {
    const res = await fetch(url)
    const data = await res.json()
    response.value = { label, data }
  } catch (e) {
    error.value = `Error calling ${label}: ${e}`
  } finally {
    loading.value = false
  }
}

function healthCheck() {
  callEndpoint('/api/health', 'Health Check')
}

function getMetrics() {
  callEndpoint('/api/metrics', 'Metrics')
}

function cpuLoad() {
  callEndpoint('/api/cpu-load?n=35', 'CPU Load (Fibonacci 35)')
}

function memoryLoad() {
  callEndpoint('/api/memory-load?size=10', 'Memory Load (10MB)')
}

function asyncLoad() {
  callEndpoint('/api/async-load?delay=100', 'Async Load (100ms)')
}

function combinedLoad() {
  callEndpoint('/api/combined-load?cpu=30&memory=5&delay=50', 'Combined Load')
}
</script>

<template>
  <div class="app">
    <header>
      <img alt="NSolid Logo" class="logo" src="./assets/logo.png" />
      <h1>Vue SSR Load Testing Demo</h1>
      <p class="subtitle">NSolid Profiling & Performance Testing</p>
    </header>

    <main>
      <section class="controls">
        <h2>Load Testing Endpoints</h2>
        <div class="button-grid">
          <button @click="healthCheck" :disabled="loading" class="btn btn-primary">
            🏥 Health Check
          </button>
          <button @click="getMetrics" :disabled="loading" class="btn btn-info">
            📊 Metrics
          </button>
          <button @click="cpuLoad" :disabled="loading" class="btn btn-warning">
            🔥 CPU Load
          </button>
          <button @click="memoryLoad" :disabled="loading" class="btn btn-danger">
            💾 Memory Load
          </button>
          <button @click="asyncLoad" :disabled="loading" class="btn btn-success">
            ⏱️ Async Load
          </button>
          <button @click="combinedLoad" :disabled="loading" class="btn btn-secondary">
            🚀 Combined Load
          </button>
        </div>
      </section>

      <section v-if="loading" class="loading">
        <div class="spinner"></div>
        <p>Loading...</p>
      </section>

      <section v-if="error" class="error">
        <h3>❌ Error</h3>
        <pre>{{ error }}</pre>
      </section>

      <section v-if="response" class="response">
        <h3>✅ {{ response.label }}</h3>
        <pre>{{ JSON.stringify(response.data, null, 2) }}</pre>
      </section>

      <section class="info">
        <h2>About This Demo</h2>
        <p>
          This application demonstrates Vue 3 SSR with NSolid profiling capabilities.
          Click the buttons above to test different load scenarios and monitor the results
          in the NSolid Console.
        </p>
        <div class="features">
          <div class="feature">
            <h3>🔬 CPU Profiling</h3>
            <p>Test CPU-intensive operations with Fibonacci calculations</p>
          </div>
          <div class="feature">
            <h3>💾 Memory Analysis</h3>
            <p>Monitor memory allocation and garbage collection</p>
          </div>
          <div class="feature">
            <h3>⚡ Performance Metrics</h3>
            <p>Track request rates, response times, and system resources</p>
          </div>
        </div>
      </section>
    </main>

    <footer>
      <p>Powered by NSolid | Vue 3 SSR | TypeScript</p>
    </footer>
  </div>
</template>

<style scoped>
.app {
  max-width: 1200px;
  margin: 0 auto;
  padding: 2rem;
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, sans-serif;
}

header {
  text-align: center;
  margin-bottom: 3rem;
}

.logo {
  width: 150px;
  height: auto;
  margin-bottom: 1rem;
  border-radius: 10px;
}

h1 {
  font-size: 2.5rem;
  margin: 0.5rem 0;
  color: #2c3e50;
}

.subtitle {
  font-size: 1.2rem;
  color: #7f8c8d;
  margin: 0;
}

.controls {
  background: #f8f9fa;
  padding: 2rem;
  border-radius: 10px;
  margin-bottom: 2rem;
}

.controls h2 {
  margin-top: 0;
  color: #2c3e50;
}

.button-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: 1rem;
  margin-top: 1.5rem;
}

.btn {
  padding: 1rem 1.5rem;
  font-size: 1rem;
  font-weight: 600;
  border: none;
  border-radius: 8px;
  cursor: pointer;
  transition: all 0.3s ease;
  color: white;
}

.btn:hover:not(:disabled) {
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
}

.btn:disabled {
  opacity: 0.6;
  cursor: not-allowed;
}

.btn-primary {
  background: #3498db;
}

.btn-info {
  background: #9b59b6;
}

.btn-warning {
  background: #e74c3c;
}

.btn-danger {
  background: #c0392b;
}

.btn-success {
  background: #27ae60;
}

.btn-secondary {
  background: #34495e;
}

.loading {
  text-align: center;
  padding: 2rem;
}

.spinner {
  border: 4px solid #f3f3f3;
  border-top: 4px solid #3498db;
  border-radius: 50%;
  width: 40px;
  height: 40px;
  animation: spin 1s linear infinite;
  margin: 0 auto 1rem;
}

@keyframes spin {
  0% { transform: rotate(0deg); }
  100% { transform: rotate(360deg); }
}

.error {
  background: #fee;
  border: 2px solid #e74c3c;
  border-radius: 8px;
  padding: 1.5rem;
  margin-bottom: 2rem;
}

.error h3 {
  margin-top: 0;
  color: #c0392b;
}

.response {
  background: #e8f8f5;
  border: 2px solid #27ae60;
  border-radius: 8px;
  padding: 1.5rem;
  margin-bottom: 2rem;
}

.response h3 {
  margin-top: 0;
  color: #27ae60;
}

pre {
  background: #2c3e50;
  color: #ecf0f1;
  padding: 1rem;
  border-radius: 6px;
  overflow-x: auto;
  font-size: 0.9rem;
  line-height: 1.5;
}

.info {
  margin-top: 3rem;
  padding: 2rem;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  border-radius: 10px;
}

.info h2 {
  margin-top: 0;
}

.features {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
  gap: 1.5rem;
  margin-top: 2rem;
}

.feature {
  background: rgba(255, 255, 255, 0.1);
  padding: 1.5rem;
  border-radius: 8px;
  backdrop-filter: blur(10px);
}

.feature h3 {
  margin-top: 0;
  font-size: 1.2rem;
}

.feature p {
  margin-bottom: 0;
  opacity: 0.9;
}

footer {
  text-align: center;
  margin-top: 3rem;
  padding-top: 2rem;
  border-top: 2px solid #ecf0f1;
  color: #7f8c8d;
}

@media (max-width: 768px) {
  .app {
    padding: 1rem;
  }

  h1 {
    font-size: 2rem;
  }

  .button-grid {
    grid-template-columns: 1fr;
  }

  .features {
    grid-template-columns: 1fr;
  }
}
</style>
