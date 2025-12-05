#!/bin/bash

# Start All Services Script
# Starts SQL Server, Backend API, and Frontend in the background

echo "🚀 Starting All Services..."
echo "================================================"
echo ""

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Track if any service failed to start
FAILED=0

# Note: Skipping dependency check during startup since we're about to start services
# Run ./check_dependencies.sh separately to verify all dependencies are installed

# Start SQL Server
echo "1. Starting SQL Server..."
# Check if already running
if docker ps | grep -q mssql-express; then
    echo -e "${YELLOW}⚠${NC} SQL Server already running"
else
    # Try to start existing container first
    docker start mssql-express > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓${NC} SQL Server started"
        # Wait for SQL Server to be ready
        sleep 3
    else
        # Container doesn't exist, try using script to create it
        if [ -f "SQL/start.sh" ]; then
            cd SQL
            ./start.sh > /tmp/sql_start.log 2>&1
            RESULT=$?
            cd ..
            if [ $RESULT -eq 0 ]; then
                echo -e "${GREEN}✓${NC} SQL Server started"
            else
                echo -e "${RED}✗${NC} Failed to start SQL Server"
                echo "   Check log: cat /tmp/sql_start.log"
                FAILED=1
            fi
        else
            echo -e "${RED}✗${NC} SQL/start.sh not found and container doesn't exist"
            FAILED=1
        fi
    fi
fi
echo ""

# Wait a moment for SQL Server to be ready
sleep 2

# Start Backend API
echo "2. Starting Backend API..."
if [ -f "custom_scripts/start_backend.sh" ]; then
    ./custom_scripts/start_backend.sh > /dev/null 2>&1
    sleep 2
    
    # Check if backend started successfully
    if [ -f "/tmp/intraforms_api.pid" ]; then
        PID=$(cat /tmp/intraforms_api.pid)
        if ps -p $PID > /dev/null 2>&1; then
            echo -e "${GREEN}✓${NC} Backend API started (PID: $PID)"
            echo "   URL: https://localhost:5001"
        else
            echo -e "${RED}✗${NC} Backend API failed to start"
            FAILED=1
        fi
    else
        echo -e "${RED}✗${NC} Backend API PID file not found"
        FAILED=1
    fi
else
    echo -e "${RED}✗${NC} custom_scripts/start_backend.sh not found"
    FAILED=1
fi
echo ""

# Start Frontend
echo "3. Starting Frontend..."
if [ -f "custom_scripts/start_dev.sh" ]; then
    ./custom_scripts/start_dev.sh > /dev/null 2>&1 &
    sleep 3
    
    # Check if frontend started successfully
    if pgrep -f "vite" > /dev/null 2>&1; then
        PID=$(pgrep -f "vite")
        echo -e "${GREEN}✓${NC} Frontend started (PID: $PID)"
        echo "   URL: http://localhost:3000"
    else
        echo -e "${RED}✗${NC} Frontend failed to start"
        FAILED=1
    fi
else
    echo -e "${RED}✗${NC} custom_scripts/start_dev.sh not found"
    FAILED=1
fi
echo ""

# Summary
echo "================================================"
if [ $FAILED -eq 0 ]; then
    echo -e "${GREEN}✓ All services started successfully!${NC}"
    echo ""
    echo "Service URLs:"
    echo "  Frontend:  http://localhost:3000"
    echo "   Health: https://localhost:5001/api/health"
    echo "   Swagger: https://localhost:5001/swagger"
    echo "  Backend:   https://localhost:5001"
    echo "  SQL Server: localhost:1433"
    echo ""
    echo "To check status: ./status_all.sh"
    echo "To stop all:     ./stop_all.sh"
else
    echo -e "${RED}✗ Some services failed to start${NC}"
    echo ""
    echo "Check logs:"
    echo "  Backend:  cat /tmp/intraforms_api.log"
    echo "  Frontend: cat /tmp/intraforms_frontend.log"
    echo "  SQL:      cd SQL && ./status.sh"
fi
echo ""
