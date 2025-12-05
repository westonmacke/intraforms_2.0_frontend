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

# Check dependencies first
echo "0. Checking dependencies..."
if [ -f "check_dependencies.sh" ]; then
    ./check_dependencies.sh
    if [ $? -ne 0 ]; then
        echo -e "${RED}✗${NC} Dependency check failed"
        echo ""
        echo "Please install missing dependencies before starting services."
        exit 1
    fi
    echo ""
else
    echo -e "${YELLOW}⚠${NC} check_dependencies.sh not found, skipping dependency check"
    echo ""
fi

# Start SQL Server
echo "1. Starting SQL Server..."
if [ -f "SQL/start.sh" ]; then
    cd SQL
    ./start.sh > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓${NC} SQL Server started"
    else
        # Check if already running
        if docker ps | grep -q mssql-express; then
            echo -e "${YELLOW}⚠${NC} SQL Server already running"
        else
            echo -e "${RED}✗${NC} Failed to start SQL Server"
            FAILED=1
        fi
    fi
    cd ..
else
    echo -e "${RED}✗${NC} SQL/start.sh not found"
    FAILED=1
fi
echo ""

# Wait a moment for SQL Server to be ready
sleep 2

# Start Backend API
echo "2. Starting Backend API..."
if [ -f "start_backend.sh" ]; then
    ./start_backend.sh > /dev/null 2>&1
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
    echo -e "${RED}✗${NC} start_backend.sh not found"
    FAILED=1
fi
echo ""

# Start Frontend
echo "3. Starting Frontend..."
if [ -f "start_frontend.sh" ]; then
    ./start_frontend.sh > /dev/null 2>&1
    sleep 3
    
    # Check if frontend started successfully
    if [ -f "/tmp/intraforms_frontend.pid" ]; then
        PID=$(cat /tmp/intraforms_frontend.pid)
        if ps -p $PID > /dev/null 2>&1; then
            echo -e "${GREEN}✓${NC} Frontend started (PID: $PID)"
            echo "   URL: http://localhost:5173"
        else
            echo -e "${RED}✗${NC} Frontend failed to start"
            FAILED=1
        fi
    else
        echo -e "${RED}✗${NC} Frontend PID file not found"
        FAILED=1
    fi
else
    echo -e "${RED}✗${NC} start_frontend.sh not found"
    FAILED=1
fi
echo ""

# Summary
echo "================================================"
if [ $FAILED -eq 0 ]; then
    echo -e "${GREEN}✓ All services started successfully!${NC}"
    echo ""
    echo "Service URLs:"
    echo "  Frontend:  http://localhost:5173"
    echo "  Backend:   https://localhost:5001"
    echo "  SQL Server: localhost:1433"
    echo ""
    echo "To check status: ./status_dev.sh"
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
