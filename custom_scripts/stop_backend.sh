#!/bin/bash

# Stop Intraforms Backend API

PID_FILE="/tmp/intraforms_api.pid"
LOG_FILE="/tmp/intraforms_api.log"

# Check if PID file exists
if [ ! -f "$PID_FILE" ]; then
    echo "❌ Backend API is not running (no PID file found)"
    exit 1
fi

PID=$(cat "$PID_FILE")

# Check if process is running
if ! ps -p $PID > /dev/null 2>&1; then
    echo "❌ Backend API is not running (PID $PID not found)"
    rm -f "$PID_FILE"
    exit 1
fi

echo "🛑 Stopping Intraforms Backend API (PID: $PID)..."

# Kill the process
kill $PID

# Wait for process to stop
for i in {1..10}; do
    if ! ps -p $PID > /dev/null 2>&1; then
        echo "✅ Backend API stopped successfully"
        rm -f "$PID_FILE"
        exit 0
    fi
    sleep 1
done

# Force kill if still running
if ps -p $PID > /dev/null 2>&1; then
    echo "⚠️  Force stopping Backend API..."
    kill -9 $PID
    sleep 1
    if ! ps -p $PID > /dev/null 2>&1; then
        echo "✅ Backend API stopped (forced)"
        rm -f "$PID_FILE"
    else
        echo "❌ Failed to stop Backend API"
        exit 1
    fi
fi
