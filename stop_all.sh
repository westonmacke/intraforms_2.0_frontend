#!/bin/bash

# Stop All Services Script
# Stops Frontend, Backend API, and SQL Server

echo "🛑 Stopping All Services..."
echo "================================================"
echo ""

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Stop Frontend
echo "1. Stopping Frontend..."
if [ -f "/tmp/intraforms_frontend.pid" ]; then
    PID=$(cat /tmp/intraforms_frontend.pid)
    if ps -p $PID > /dev/null 2>&1; then
        kill $PID
        rm /tmp/intraforms_frontend.pid
        echo -e "${GREEN}✓${NC} Frontend stopped"
    else
        echo -e "${YELLOW}⚠${NC} Frontend not running"
        rm /tmp/intraforms_frontend.pid
    fi
else
    echo -e "${YELLOW}⚠${NC} Frontend not running"
fi
echo ""

# Stop Backend API
echo "2. Stopping Backend API..."
if [ -f "stop_backend.sh" ]; then
    ./stop_backend.sh > /dev/null 2>&1
    echo -e "${GREEN}✓${NC} Backend API stopped"
else
    if [ -f "/tmp/intraforms_api.pid" ]; then
        PID=$(cat /tmp/intraforms_api.pid)
        if ps -p $PID > /dev/null 2>&1; then
            kill $PID
            rm /tmp/intraforms_api.pid
            echo -e "${GREEN}✓${NC} Backend API stopped"
        else
            echo -e "${YELLOW}⚠${NC} Backend API not running"
            rm /tmp/intraforms_api.pid
        fi
    else
        echo -e "${YELLOW}⚠${NC} Backend API not running"
    fi
fi
echo ""

# Stop SQL Server
echo "3. Stopping SQL Server..."
if [ -f "SQL/stop.sh" ]; then
    cd SQL
    ./stop.sh > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓${NC} SQL Server stopped"
    else
        echo -e "${YELLOW}⚠${NC} SQL Server may not be running"
    fi
    cd ..
else
    echo -e "${RED}✗${NC} SQL/stop.sh not found"
fi
echo ""

echo "================================================"
echo -e "${GREEN}✓ All services stopped${NC}"
echo ""
