#!/bin/bash

# Bash script to build and manage Docker containers with NSolid v6

ACTION="${1:-build}"
TAG="${2:-latest}"
REGISTRY="${3:-}"

IMAGE_NAME="vue-ssr-app"

echo "🐳 Docker Management Script (NSolid v6)"
echo "Action: $ACTION"
echo ""

case "$ACTION" in
    build)
        echo "Building NSolid v6 Docker image..."
        docker build -t "${IMAGE_NAME}:${TAG}" .
        
        if [ $? -eq 0 ]; then
            echo "✓ Build completed successfully!"
        else
            echo "✗ Build failed!"
            exit 1
        fi
        ;;
    
    run)
        echo "Running NSolid v6 container..."
        docker run -d \
            --name vue-ssr-app \
            -p 3000:3000 \
            -p 9001:9001 \
            -p 9002:9002 \
            -p 9003:9003 \
            -p 6753:6753 \
            -e NSOLID_SAAS="$NSOLID_SAAS" \
            "${IMAGE_NAME}:${TAG}"
        
        echo ""
        echo "✓ Container started!"
        echo "App: http://localhost:3000"
        echo "NSolid Console: http://localhost:6753"
        ;;
    
    stop)
        echo "Stopping container..."
        docker stop vue-ssr-app 2>/dev/null
        echo "✓ Container stopped"
        ;;
    
    clean)
        echo "Cleaning up container and image..."
        docker stop vue-ssr-app 2>/dev/null
        docker rm vue-ssr-app 2>/dev/null
        docker rmi "${IMAGE_NAME}:${TAG}" 2>/dev/null
        echo "✓ Cleanup complete"
        ;;
    
    compose-up)
        echo "Starting services with Docker Compose..."
        docker-compose up -d
        
        echo ""
        echo "✓ Services started!"
        echo "App: http://localhost:3000"
        echo "NSolid Console: http://localhost:6753"
        ;;
    
    compose-down)
        echo "Stopping Docker Compose services..."
        docker-compose down
        echo "✓ Services stopped"
        ;;
    
    logs)
        echo "Showing container logs..."
        docker logs -f vue-ssr-app
        ;;
    
    push)
        if [ -z "$REGISTRY" ]; then
            echo "✗ Registry not specified"
            exit 1
        fi
        
        echo "Pushing to registry: $REGISTRY"
        
        FULL_IMAGE_NAME="${REGISTRY}/${IMAGE_NAME}:${TAG}"
        docker tag "${IMAGE_NAME}:${TAG}" "$FULL_IMAGE_NAME"
        docker push "$FULL_IMAGE_NAME"
        
        echo "✓ Push complete!"
        ;;
    
    *)
        echo "Unknown action: $ACTION"
        echo ""
        echo "Available actions:"
        echo "  build         - Build Docker image"
        echo "  run           - Run container"
        echo "  stop          - Stop containers"
        echo "  clean         - Remove containers and images"
        echo "  compose-up    - Start with Docker Compose"
        echo "  compose-down  - Stop Docker Compose"
        echo "  logs          - Show container logs"
        echo "  push          - Push to registry"
        echo ""
        echo ""
        echo "Examples:"
        echo "  ./scripts/docker-build.sh build"
        echo "  ./scripts/docker-build.sh run"
        echo "  ./scripts/docker-build.sh compose-up"
        echo "  ./scripts/docker-build.sh push yourusername"
        exit 1
        ;;
esac
