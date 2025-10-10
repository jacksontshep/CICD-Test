import http from 'k6/http';
import { check, sleep } from 'k6';
import { Rate, Trend, Counter } from 'k6/metrics';

// Custom metrics
const errorRate = new Rate('errors');
const ssrTrend = new Trend('ssr_duration');
const cpuTrend = new Trend('cpu_duration');
const memoryTrend = new Trend('memory_duration');
const requestCounter = new Counter('total_requests');

// Load test configuration
export const options = {
  // Simplified for CI - use constant VUs
  vus: 20,
  duration: '60s',
  thresholds: {
    'http_req_duration': ['p(95)<1000', 'p(99)<2000'],
    'errors': ['rate<0.2'],
    'http_req_failed': ['rate<0.1'],
  },
};

const BASE_URL = 'http://localhost:3000';

export default function () {
  requestCounter.add(1);

  // Randomly select a scenario
  const rand = Math.random();
  
  if (rand < 0.4) {
    // SSR Page Load (40%)
    const res = http.get(`${BASE_URL}/`);
    const success = check(res, {
      'SSR status is 200': (r) => r.status === 200,
      'SSR has content': (r) => r.body && r.body.includes('app'),
    });
    errorRate.add(!success);
    ssrTrend.add(res.timings.duration);
    
  } else if (rand < 0.6) {
    // CPU Load Test (20%)
    const n = Math.floor(Math.random() * 8) + 30; // 30-38
    const res = http.get(`${BASE_URL}/api/cpu-load?n=${n}`);
    const success = check(res, {
      'CPU status is 200': (r) => r.status === 200,
      'CPU has result': (r) => r.json('result') !== undefined,
    });
    errorRate.add(!success);
    cpuTrend.add(res.timings.duration);
    
  } else if (rand < 0.8) {
    // Memory Load Test (20%)
    const size = Math.floor(Math.random() * 10) + 5; // 5-15 MB
    const res = http.get(`${BASE_URL}/api/memory-load?size=${size}`);
    const success = check(res, {
      'Memory status is 200': (r) => r.status === 200,
      'Memory allocated': (r) => r.json('allocatedMB') !== undefined,
    });
    errorRate.add(!success);
    memoryTrend.add(res.timings.duration);
    
  } else if (rand < 0.9) {
    // Async Load Test (10%)
    const delay = Math.floor(Math.random() * 150) + 50; // 50-200ms
    const res = http.get(`${BASE_URL}/api/async-load?delay=${delay}`);
    check(res, {
      'Async status is 200': (r) => r.status === 200,
    });
    
  } else {
    // Combined Load Test (10%)
    const cpu = Math.floor(Math.random() * 7) + 28; // 28-35
    const memory = Math.floor(Math.random() * 7) + 3; // 3-10
    const delay = Math.floor(Math.random() * 100) + 50; // 50-150
    const res = http.get(`${BASE_URL}/api/combined-load?cpu=${cpu}&memory=${memory}&delay=${delay}`);
    check(res, {
      'Combined status is 200': (r) => r.status === 200,
    });
  }

  sleep(Math.random() * 2 + 0.5); // Random sleep between 0.5-2.5s
}

// Setup function - runs once at the beginning
export function setup() {
  const res = http.get(`${BASE_URL}/api/health`);
  if (res.status === 200 && res.body) {
    console.log('Server health check:', res.json());
  } else {
    console.log('Server health check failed:', res.status);
  }
  return { startTime: new Date() };
}

// Teardown function - runs once at the end
export function teardown(data) {
  const res = http.get(`${BASE_URL}/api/metrics`);
  if (res.status === 200 && res.body) {
    console.log('Final metrics:', res.json());
  } else {
    console.log('Failed to get final metrics:', res.status);
  }
  console.log('Test duration:', (new Date() - data.startTime) / 1000, 'seconds');
}
