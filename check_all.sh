#!/bin/bash

# Check All Services Script
# Verifies that SQL Server, Backend API, and Frontend are running and responding

echo "🔍 Checking All Services..."
echo "================================================"
echo ""

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

ALL_HEALTHY=0

# Check SQL Server
echo "1. Checking SQL Server..."
if command -v docker >/dev/null 2>&1; then
    if docker ps | grep -q mssql-express; then
        echo -e "${GREEN}✓${NC} Container is running"
        
        # Test SQL Server connection
        if docker exec mssql-express /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P Skittles123! -C -Q "SELECT 1" > /dev/null 2>&1; then
            echo -e "${GREEN}✓${NC} SQL Server is responding"
            echo "   Host: localhost:1433"
        else
            echo -e "${RED}✗${NC} SQL Server not responding"
            ALL_HEALTHY=1
        fi
    else
        echo -e "${RED}✗${NC} SQL Server container not running"
        echo "   Run: ./start_all.sh or cd SQL && ./start.sh"
        ALL_HEALTHY=1
    fi
else
    echo -e "${RED}✗${NC} Docker not found"
    ALL_HEALTHY=1
fi
echo ""

# Check Backend API
echo "2. Checking Backend API..."
if [ -f "/tmp/intraforms_api.pid" ]; then
    PID=$(cat /tmp/intraforms_api.pid)
    if ps -p $PID > /dev/null 2>&1; then
        echo -e "${GREEN}✓${NC} Process is running (PID: $PID)"
        
        # Test backend health endpoint
        sleep 1
        if curl -k -s -o /dev/null -w "%{http_code}" https://localhost:5001/api/health 2>/dev/null | grep -q "200\|404"; then
            echo -e "${GREEN}✓${NC} Backend is responding"
            echo "   URL: https://localhost:5001"
        else
            echo -e "${YELLOW}⚠${NC} Backend may still be starting up..."
            echo "   URL: https://localhost:5001"
        fi
    else
        echo -e "${RED}✗${NC} Backend process not running (stale PID)"
        echo "   Run: ./start_all.sh or ./start_backend.sh"
        ALL_HEALTHY=1
    fi
else
    echo -e "${RED}✗${NC} Backend not running"
    echo "   Run: ./start_all.sh or ./start_backend.sh"
    ALL_HEALTHY=1
fi
echo ""

# Check Frontend (Dev Server)
echo "3. Checking Frontend..."
# Check for Vite dev server process (npm run dev)
if pgrep -f "vite" > /dev/null 2>&1; then
    PID=$(pgrep -f "vite")
    echo -e "${GREEN}✓${NC} Dev server is running (PID: $PID)"
    
    # Test frontend on dev port
    sleep 1
    if curl -s -o /dev/null -w "%{http_code}" http://localhost:3000 2>/dev/null | grep -q "200"; then
        echo -e "${GREEN}✓${NC} Frontend is responding"
        echo "   URL: http://localhost:3000"
    else
        echo -e "${YELLOW}⚠${NC} Frontend may still be starting up..."
        echo "   URL: http://localhost:3000"
    fi
else
    echo -e "${RED}✗${NC} Frontend dev server not running"
    echo "   Run: ./start_all.sh or npm run dev"
    ALL_HEALTHY=1
fi
echo ""

# Check logs for recent errors
echo "4. Checking for recent errors..."
ERROR_COUNT=0

if [ -f "/tmp/intraforms_api.log" ]; then
    BACKEND_ERRORS=$(tail -20 /tmp/intraforms_api.log 2>/dev/null | grep -i "error\|exception\|fail" | wc -l | tr -d ' ')
    if [ "$BACKEND_ERRORS" -gt 0 ]; then
        echo -e "${YELLOW}⚠${NC} Backend: $BACKEND_ERRORS recent error(s) in log"
        ERROR_COUNT=$((ERROR_COUNT + BACKEND_ERRORS))
    else
        echo -e "${GREEN}✓${NC} Backend: No recent errors"
    fi
fi

if [ -f "/tmp/intraforms_frontend.log" ]; then
    FRONTEND_ERRORS=$(tail -20 /tmp/intraforms_frontend.log 2>/dev/null | grep -i "error\|exception\|fail" | wc -l | tr -d ' ')
    if [ "$FRONTEND_ERRORS" -gt 0 ]; then
        echo -e "${YELLOW}⚠${NC} Frontend: $FRONTEND_ERRORS recent error(s) in log"
        ERROR_COUNT=$((ERROR_COUNT + FRONTEND_ERRORS))
    else
        echo -e "${GREEN}✓${NC} Frontend: No recent errors"
    fi
fi

if [ $ERROR_COUNT -eq 0 ] && [ ! -f "/tmp/intraforms_api.log" ] && [ ! -f "/tmp/intraforms_frontend.log" ]; then
    echo -e "${YELLOW}⚠${NC} No log files found"
fi
echo ""

# Summary
echo "================================================"
if [ $ALL_HEALTHY -eq 0 ]; then
    echo -e "${GREEN}✓ All services are healthy!${NC}"
    echo ""
    echo "Application URLs:"
    echo "  Frontend:  http://localhost:5173"
    echo "  Backend:   https://localhost:5001"
    echo "  SQL Server: localhost:1433"
    echo ""
    if [ $ERROR_COUNT -gt 0 ]; then
        echo -e "${YELLOW}Note: $ERROR_COUNT error(s) found in logs - check if expected${NC}"
        echo ""
    fi
    exit 0
else
    echo -e "${RED}✗ Some services are not healthy${NC}"
    echo ""
    echo "To start all services: ./start_all.sh"
    echo "To view logs:"
    echo "  Backend:  cat /tmp/intraforms_api.log"
    echo "  Frontend: cat /tmp/intraforms_frontend.log"
    echo ""
    exit 1
fi
