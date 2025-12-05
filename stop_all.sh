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

# Stop Frontend (Dev Server)
echo "1. Stopping Frontend..."
# Kill Vite dev server process
if pgrep -f "vite" > /dev/null 2>&1; then
    pkill -f "vite"
    echo -e "${GREEN}✓${NC} Frontend dev server stopped"
else
    echo -e "${YELLOW}⚠${NC} Frontend dev server not running"
fi

# Clean up PID file if it exists
if [ -f "/tmp/intraforms_frontend.pid" ]; then
    rm /tmp/intraforms_frontend.pid
fi
echo ""

# Stop Backend API
echo "2. Stopping Backend API..."
if [ -f "custom_scripts/stop_backend.sh" ]; then
    ./custom_scripts/stop_backend.sh > /dev/null 2>&1
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
if docker ps | grep -q mssql-express; then
    docker stop mssql-express > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓${NC} SQL Server container stopped"
    else
        echo -e "${RED}✗${NC} Failed to stop SQL Server container"
    fi
else
    echo -e "${YELLOW}⚠${NC} SQL Server container not running"
fi
echo ""

echo "================================================"
echo -e "${GREEN}✓ All services stopped${NC}"
echo ""
