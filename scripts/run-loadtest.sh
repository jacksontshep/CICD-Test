#!/bin/bash

# Bash script to run load tests on Unix-based systems

TEST_TYPE="${1:-k6}"
DURATION="${2:-60}"
VIRTUAL_USERS="${3:-20}"

echo "🚀 Starting Vue SSR Load Test"
echo "Test Type: $TEST_TYPE"
echo "Duration: $DURATION seconds"
echo "Virtual Users: $VIRTUAL_USERS"
echo ""

# Check if server is running
SERVER_RUNNING=false
if curl -s http://localhost:3000/api/health > /dev/null 2>&1; then
    SERVER_RUNNING=true
    echo "✓ Server is already running"
else
    echo "⚠ Server is not running. Starting server..."
fi

# Start server if not running
SERVER_PID=""
if [ "$SERVER_RUNNING" = false ]; then
    # Check if build exists
    if [ ! -f "dist/server/index.js" ]; then
        echo "Building application..."
        npm run build
    fi
    
    echo "Starting production server..."
    NODE_ENV=production node dist/server/index.js &
    SERVER_PID=$!
    
    # Wait for server to start
    RETRIES=0
    MAX_RETRIES=10
    while [ $RETRIES -lt $MAX_RETRIES ]; do
        sleep 1
        if curl -s http://localhost:3000/api/health > /dev/null 2>&1; then
            echo "✓ Server started successfully"
            break
        fi
        RETRIES=$((RETRIES + 1))
        echo "Waiting for server... ($RETRIES/$MAX_RETRIES)"
    done
    
    if [ $RETRIES -eq $MAX_RETRIES ]; then
        echo "✗ Failed to start server"
        exit 1
    fi
fi

echo ""
echo "📊 Running load test..."
echo ""

# Run the appropriate load test
case "$TEST_TYPE" in
    k6)
        if ! command -v k6 &> /dev/null; then
            echo "✗ k6 is not installed"
            echo "Install k6 from: https://k6.io/docs/getting-started/installation/"
            [ -n "$SERVER_PID" ] && kill $SERVER_PID
            exit 1
        fi
        
        k6 run --duration "${DURATION}s" --vus $VIRTUAL_USERS loadtest/k6-test.js
        ;;
    
    artillery)
        if ! command -v artillery &> /dev/null; then
            echo "Installing Artillery..."
            npm install -g artillery
        fi
        
        artillery run loadtest/artillery.yml --output loadtest-results.json
        
        echo ""
        echo "Generating report..."
        artillery report loadtest-results.json --output loadtest-report.html
        echo "✓ Report saved to loadtest-report.html"
        ;;
    
    simple)
        echo "Running simple HTTP test..."
        REQUESTS=$((DURATION * VIRTUAL_USERS))
        SUCCESS_COUNT=0
        ERROR_COUNT=0
        TOTAL_TIME=0
        
        ENDPOINTS=(
            "http://localhost:3000/"
            "http://localhost:3000/api/cpu-load?n=35"
            "http://localhost:3000/api/memory-load?size=10"
            "http://localhost:3000/api/async-load?delay=100"
        )
        
        for ((i=0; i<REQUESTS; i++)); do
            ENDPOINT=${ENDPOINTS[$((i % ${#ENDPOINTS[@]}))]}
            START=$(date +%s%N)
            
            if curl -s -o /dev/null -w "%{http_code}" "$ENDPOINT" | grep -q "200"; then
                SUCCESS_COUNT=$((SUCCESS_COUNT + 1))
            else
                ERROR_COUNT=$((ERROR_COUNT + 1))
            fi
            
            END=$(date +%s%N)
            ELAPSED=$(((END - START) / 1000000))
            TOTAL_TIME=$((TOTAL_TIME + ELAPSED))
            
            if [ $((i % 10)) -eq 0 ]; then
                echo "Progress: $((i + 1))/$REQUESTS requests"
            fi
        done
        
        AVG_TIME=$((TOTAL_TIME / REQUESTS))
        SUCCESS_RATE=$((SUCCESS_COUNT * 100 / REQUESTS))
        
        echo ""
        echo "Results:"
        echo "  Total Requests: $REQUESTS"
        echo "  Successful: $SUCCESS_COUNT"
        echo "  Errors: $ERROR_COUNT"
        echo "  Success Rate: ${SUCCESS_RATE}%"
        echo "  Avg Response Time: ${AVG_TIME}ms"
        ;;
    
    *)
        echo "✗ Unknown test type: $TEST_TYPE"
        echo "Available types: k6, artillery, simple"
        [ -n "$SERVER_PID" ] && kill $SERVER_PID
        exit 1
        ;;
esac

echo ""
echo "📈 Fetching final metrics..."
curl -s http://localhost:3000/api/metrics | jq '.' || curl -s http://localhost:3000/api/metrics

# Cleanup
if [ -n "$SERVER_PID" ]; then
    echo ""
    echo "Stopping server..."
    kill $SERVER_PID
    echo "✓ Server stopped"
fi

echo ""
echo "✓ Load test completed!"
