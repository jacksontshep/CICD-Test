# PowerShell script to build and manage Docker containers

param(
    [string]$Action = "build",
    [switch]$Push = $false,
    [string]$Registry = "",
    [string]$Tag = "latest"
)

$ImageName = "vue-ssr-app"

Write-Host "🐳 Docker Management Script (NSolid v6)" -ForegroundColor Cyan
Write-Host "Action: $Action" -ForegroundColor Yellow
Write-Host ""

switch ($Action.ToLower()) {
    "build" {
        Write-Host "Building NSolid v6 Docker image..." -ForegroundColor Green
        docker build -t "${ImageName}:${Tag}" .
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✓ Build completed successfully!" -ForegroundColor Green
        } else {
            Write-Host "✗ Build failed!" -ForegroundColor Red
            exit 1
        }
    }
    
    "run" {
        Write-Host "Running NSolid v6 container..." -ForegroundColor Green
        docker run -d `
            --name vue-ssr-app `
            -p 3000:3000 `
            -p 9001:9001 `
            -p 9002:9002 `
            -p 9003:9003 `
            -p 6753:6753 `
            -e NSOLID_SAAS="$env:NSOLID_SAAS" `
            "${ImageName}:${Tag}"
        
        Write-Host ""
        Write-Host "✓ Container started!" -ForegroundColor Green
        Write-Host "App: http://localhost:3000" -ForegroundColor Cyan
        Write-Host "NSolid Console: http://localhost:6753" -ForegroundColor Cyan
    }
    
    "stop" {
        Write-Host "Stopping container..." -ForegroundColor Yellow
        docker stop vue-ssr-app 2>$null
        Write-Host "✓ Container stopped" -ForegroundColor Green
    }
    
    "clean" {
        Write-Host "Cleaning up container and image..." -ForegroundColor Yellow
        docker stop vue-ssr-app 2>$null
        docker rm vue-ssr-app 2>$null
        docker rmi "${ImageName}:${Tag}" 2>$null
        Write-Host "✓ Cleanup complete" -ForegroundColor Green
    }
    
    "compose-up" {
        Write-Host "Starting services with Docker Compose..." -ForegroundColor Green
        docker-compose up -d
        
        Write-Host ""
        Write-Host "✓ Services started!" -ForegroundColor Green
        Write-Host "App: http://localhost:3000" -ForegroundColor Cyan
        Write-Host "NSolid Console: http://localhost:6753" -ForegroundColor Cyan
    }
    
    "compose-down" {
        Write-Host "Stopping Docker Compose services..." -ForegroundColor Yellow
        docker-compose down
        Write-Host "✓ Services stopped" -ForegroundColor Green
    }
    
    "logs" {
        Write-Host "Showing container logs..." -ForegroundColor Cyan
        docker logs -f vue-ssr-app
    }
    
    "push" {
        if ($Registry -eq "") {
            Write-Host "✗ Registry not specified. Use -Registry parameter" -ForegroundColor Red
            exit 1
        }
        
        Write-Host "Pushing to registry: $Registry" -ForegroundColor Green
        
        $fullImageName = "${Registry}/${ImageName}:${Tag}"
        docker tag "${ImageName}:${Tag}" $fullImageName
        docker push $fullImageName
        
        Write-Host "✓ Push complete!" -ForegroundColor Green
    }
    
    default {
        Write-Host "Unknown action: $Action" -ForegroundColor Red
        Write-Host ""
        Write-Host "Available actions:" -ForegroundColor Yellow
        Write-Host "  build         - Build Docker image"
        Write-Host "  run           - Run container"
        Write-Host "  stop          - Stop containers"
        Write-Host "  clean         - Remove containers and images"
        Write-Host "  compose-up    - Start with Docker Compose"
        Write-Host "  compose-down  - Stop Docker Compose"
        Write-Host "  logs          - Show container logs"
        Write-Host "  push          - Push to registry"
        Write-Host ""
        Write-Host ""
        Write-Host "Examples:" -ForegroundColor Cyan
        Write-Host "  .\scripts\docker-build.ps1 -Action build"
        Write-Host "  .\scripts\docker-build.ps1 -Action run"
        Write-Host "  .\scripts\docker-build.ps1 -Action compose-up"
        Write-Host "  .\scripts\docker-build.ps1 -Action push -Registry yourusername"
        exit 1
    }
}
