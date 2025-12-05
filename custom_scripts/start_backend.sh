#!/bin/bash

# Start Intraforms Backend API

# Get project root (parent of custom_scripts)
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

BACKEND_DIR="$PROJECT_ROOT/Backend/IntraformsAPI"
LOG_FILE="/tmp/intraforms_api.log"
PID_FILE="/tmp/intraforms_api.pid"

# Check if backend is already running
if [ -f "$PID_FILE" ]; then
    PID=$(cat "$PID_FILE")
    if ps -p $PID > /dev/null 2>&1; then
        echo "❌ Backend API is already running (PID: $PID)"
        echo "   Use stop_backend.sh to stop it first"
        exit 1
    else
        rm -f "$PID_FILE"
    fi
fi

# Check if port 5001 is already in use
if lsof -Pi :5001 -sTCP:LISTEN -t >/dev/null 2>&1; then
    echo "❌ Port 5001 is already in use"
    echo "   Another process is using the port. Finding process..."
    PORT_PID=$(lsof -Pi :5001 -sTCP:LISTEN -t)
    echo "   Process using port 5001: PID $PORT_PID"
    echo "   Use: kill $PORT_PID"
    echo "   Or use: ./stop_backend.sh"
    exit 1
fi

# Check if backend directory exists
if [ ! -d "$BACKEND_DIR" ]; then
    echo "❌ Backend directory not found: $BACKEND_DIR"
    exit 1
fi

echo "🚀 Starting Intraforms Backend API..."

# Start the backend in background
cd "$BACKEND_DIR"
nohup dotnet run --project IntraformsAPI.csproj > "$LOG_FILE" 2>&1 &
BACKEND_PID=$!

# Save PID
echo $BACKEND_PID > "$PID_FILE"

# Wait a moment and check if it started
sleep 3

if ps -p $BACKEND_PID > /dev/null 2>&1; then
    echo "✅ Backend API started successfully (PID: $BACKEND_PID)"
    echo "   URL: https://localhost:5001"
    echo "   Health: https://localhost:5001/api/health"
    echo "   Swagger: https://localhost:5001/swagger"
    echo "   Logs: $LOG_FILE"
    echo ""
    echo "📝 Tip: Use 'tail -f $LOG_FILE' to watch logs"
else
    echo "❌ Backend API failed to start"
    echo "   Check logs: cat $LOG_FILE"
    rm -f "$PID_FILE"
    exit 1
fi
