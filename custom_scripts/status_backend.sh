#!/bin/bash

# Check Intraforms Backend API Status

PID_FILE="/tmp/intraforms_api.pid"
LOG_FILE="/tmp/intraforms_api.log"

echo "🔍 Checking Intraforms Backend API status..."
echo ""

# Check if PID file exists
if [ ! -f "$PID_FILE" ]; then
    echo "❌ Backend API is NOT running (no PID file)"
    exit 1
fi

PID=$(cat "$PID_FILE")

# Check if process is running
if ps -p $PID > /dev/null 2>&1; then
    echo "✅ Backend API is running"
    echo "   PID: $PID"
    echo "   URL: https://localhost:5001"
    echo "   Swagger: https://localhost:5001/swagger"
    echo "   Logs: $LOG_FILE"
    echo ""
    
    # Test health endpoint
    echo "🏥 Testing health endpoint..."
    HEALTH_CHECK=$(curl -k -s https://localhost:5001/api/health 2>&1)
    
    if echo "$HEALTH_CHECK" | grep -q "ok"; then
        echo "✅ Health check passed"
        echo "$HEALTH_CHECK" | python3 -m json.tool 2>/dev/null || echo "$HEALTH_CHECK"
    else
        echo "⚠️  Health check failed or server not responding"
    fi
    
    echo ""
    echo "📊 Process Info:"
    ps -p $PID -o pid,ppid,%cpu,%mem,etime,command
    
    exit 0
else
    echo "❌ Backend API is NOT running (PID $PID not found)"
    echo "   Cleaning up stale PID file..."
    rm -f "$PID_FILE"
    exit 1
fi
