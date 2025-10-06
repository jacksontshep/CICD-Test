# PowerShell script to run load tests on Windows

param(
    [string]$TestType = "k6",
    [int]$Duration = 60,
    [int]$VirtualUsers = 20
)

Write-Host "🚀 Starting Vue SSR Load Test" -ForegroundColor Green
Write-Host "Test Type: $TestType" -ForegroundColor Cyan
Write-Host "Duration: $Duration seconds" -ForegroundColor Cyan
Write-Host "Virtual Users: $VirtualUsers" -ForegroundColor Cyan
Write-Host ""

# Check if server is running
$serverRunning = $false
try {
    $response = Invoke-WebRequest -Uri "http://localhost:3000/api/health" -UseBasicParsing -TimeoutSec 2
    if ($response.StatusCode -eq 200) {
        $serverRunning = $true
        Write-Host "✓ Server is already running" -ForegroundColor Green
    }
} catch {
    Write-Host "⚠ Server is not running. Starting server..." -ForegroundColor Yellow
}

# Start server if not running
$serverProcess = $null
if (-not $serverRunning) {
    # Check if build exists
    if (-not (Test-Path "dist/server/index.js")) {
        Write-Host "Building application..." -ForegroundColor Yellow
        npm run build
    }
    
    Write-Host "Starting production server..." -ForegroundColor Yellow
    $env:NODE_ENV = "production"
    $serverProcess = Start-Process -FilePath "node" -ArgumentList "dist/server/index.js" -PassThru -NoNewWindow
    
    # Wait for server to start
    $retries = 0
    $maxRetries = 10
    while ($retries -lt $maxRetries) {
        Start-Sleep -Seconds 1
        try {
            $response = Invoke-WebRequest -Uri "http://localhost:3000/api/health" -UseBasicParsing -TimeoutSec 2
            if ($response.StatusCode -eq 200) {
                Write-Host "✓ Server started successfully" -ForegroundColor Green
                break
            }
        } catch {
            $retries++
            Write-Host "Waiting for server... ($retries/$maxRetries)" -ForegroundColor Yellow
        }
    }
    
    if ($retries -eq $maxRetries) {
        Write-Host "✗ Failed to start server" -ForegroundColor Red
        exit 1
    }
}

Write-Host ""
Write-Host "📊 Running load test..." -ForegroundColor Cyan
Write-Host ""

# Run the appropriate load test
switch ($TestType.ToLower()) {
    "k6" {
        # Check if k6 is installed
        $k6Installed = Get-Command k6 -ErrorAction SilentlyContinue
        if (-not $k6Installed) {
            Write-Host "✗ k6 is not installed" -ForegroundColor Red
            Write-Host "Install k6 from: https://k6.io/docs/getting-started/installation/" -ForegroundColor Yellow
            if ($serverProcess) { Stop-Process -Id $serverProcess.Id -Force }
            exit 1
        }
        
        k6 run --duration "$($Duration)s" --vus $VirtualUsers loadtest/k6-test.js
    }
    
    "artillery" {
        # Check if artillery is installed
        $artilleryInstalled = Get-Command artillery -ErrorAction SilentlyContinue
        if (-not $artilleryInstalled) {
            Write-Host "Installing Artillery..." -ForegroundColor Yellow
            npm install -g artillery
        }
        
        artillery run loadtest/artillery.yml --output loadtest-results.json
        
        Write-Host ""
        Write-Host "Generating report..." -ForegroundColor Cyan
        artillery report loadtest-results.json --output loadtest-report.html
        Write-Host "✓ Report saved to loadtest-report.html" -ForegroundColor Green
    }
    
    "simple" {
        # Simple curl-based test
        Write-Host "Running simple HTTP test..." -ForegroundColor Cyan
        $requests = $Duration * $VirtualUsers
        $successCount = 0
        $errorCount = 0
        $totalTime = 0
        
        $endpoints = @(
            "http://localhost:3000/",
            "http://localhost:3000/api/cpu-load?n=35",
            "http://localhost:3000/api/memory-load?size=10",
            "http://localhost:3000/api/async-load?delay=100"
        )
        
        for ($i = 0; $i -lt $requests; $i++) {
            $endpoint = $endpoints[$i % $endpoints.Length]
            $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
            
            try {
                $response = Invoke-WebRequest -Uri $endpoint -UseBasicParsing -TimeoutSec 5
                if ($response.StatusCode -eq 200) {
                    $successCount++
                }
            } catch {
                $errorCount++
            }
            
            $stopwatch.Stop()
            $totalTime += $stopwatch.ElapsedMilliseconds
            
            if (($i + 1) % 10 -eq 0) {
                Write-Host "Progress: $($i + 1)/$requests requests" -ForegroundColor Gray
            }
        }
        
        $avgTime = $totalTime / $requests
        $successRate = ($successCount / $requests) * 100
        
        Write-Host ""
        Write-Host "Results:" -ForegroundColor Green
        Write-Host "  Total Requests: $requests"
        Write-Host "  Successful: $successCount"
        Write-Host "  Errors: $errorCount"
        Write-Host "  Success Rate: $([math]::Round($successRate, 2))%"
        Write-Host "  Avg Response Time: $([math]::Round($avgTime, 2))ms"
    }
    
    default {
        Write-Host "✗ Unknown test type: $TestType" -ForegroundColor Red
        Write-Host "Available types: k6, artillery, simple" -ForegroundColor Yellow
        if ($serverProcess) { Stop-Process -Id $serverProcess.Id -Force }
        exit 1
    }
}

Write-Host ""
Write-Host "📈 Fetching final metrics..." -ForegroundColor Cyan
try {
    $metricsResponse = Invoke-RestMethod -Uri "http://localhost:3000/api/metrics" -Method Get
    Write-Host ""
    Write-Host "Server Metrics:" -ForegroundColor Green
    Write-Host "  Request Count: $($metricsResponse.requestCount)"
    Write-Host "  Errors: $($metricsResponse.errors)"
    Write-Host "  Uptime: $([math]::Round($metricsResponse.uptime, 2))s"
    Write-Host "  Requests/Second: $([math]::Round($metricsResponse.requestsPerSecond, 2))"
    Write-Host "  Memory (RSS): $([math]::Round($metricsResponse.memory.rss / 1024 / 1024, 2))MB"
    Write-Host "  Memory (Heap Used): $([math]::Round($metricsResponse.memory.heapUsed / 1024 / 1024, 2))MB"
} catch {
    Write-Host "⚠ Could not fetch metrics" -ForegroundColor Yellow
}

# Cleanup
if ($serverProcess) {
    Write-Host ""
    Write-Host "Stopping server..." -ForegroundColor Yellow
    Stop-Process -Id $serverProcess.Id -Force
    Write-Host "✓ Server stopped" -ForegroundColor Green
}

Write-Host ""
Write-Host "✓ Load test completed!" -ForegroundColor Green
