#!/bin/bash

# Check Dependencies Script
# Verifies all required dependencies are installed for the project

echo "🔍 Checking Project Dependencies..."
echo "================================================"
echo ""

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

MISSING_DEPS=0

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to check npm package
check_npm_package() {
    if [ -d "node_modules/$1" ]; then
        echo -e "${GREEN}✓${NC} $1 (installed)"
        return 0
    else
        echo -e "${RED}✗${NC} $1 (missing)"
        return 1
    fi
}

# Check Node.js
echo "Checking Node.js..."
if command_exists node; then
    NODE_VERSION=$(node --version)
    echo -e "${GREEN}✓${NC} Node.js $NODE_VERSION"
else
    echo -e "${RED}✗${NC} Node.js not found"
    echo "   Install from: https://nodejs.org/"
    MISSING_DEPS=1
fi
echo ""

# Check npm
echo "Checking npm..."
if command_exists npm; then
    NPM_VERSION=$(npm --version)
    echo -e "${GREEN}✓${NC} npm $NPM_VERSION"
else
    echo -e "${RED}✗${NC} npm not found"
    MISSING_DEPS=1
fi
echo ""

# Check .NET SDK
echo "Checking .NET SDK..."
if command_exists dotnet; then
    DOTNET_VERSION=$(dotnet --version)
    echo -e "${GREEN}✓${NC} .NET SDK $DOTNET_VERSION"
else
    echo -e "${RED}✗${NC} .NET SDK not found"
    echo "   Install from: https://dotnet.microsoft.com/download"
    MISSING_DEPS=1
fi
echo ""

# Check if node_modules exists
echo "Checking Node.js packages..."
if [ ! -d "node_modules" ]; then
    echo -e "${YELLOW}⚠${NC} node_modules directory not found"
    echo "   Run: npm install"
    MISSING_DEPS=1
else
    # Check critical npm packages
    echo "Checking critical packages:"
    
    check_npm_package "vue" || MISSING_DEPS=1
    check_npm_package "vuetify" || MISSING_DEPS=1
    check_npm_package "axios" || MISSING_DEPS=1
    check_npm_package "vue-router" || MISSING_DEPS=1
    check_npm_package "pinia" || MISSING_DEPS=1
    check_npm_package "vite" || MISSING_DEPS=1
fi
echo ""

# Check .NET packages
echo "Checking .NET packages..."
if [ -f "Backend/IntraformsAPI/IntraformsAPI.csproj" ]; then
    cd Backend/IntraformsAPI
    
    # Check if packages are restored
    if [ -d "obj" ]; then
        echo -e "${GREEN}✓${NC} .NET packages restored"
    else
        echo -e "${YELLOW}⚠${NC} .NET packages not restored"
        echo "   Run: cd Backend/IntraformsAPI && dotnet restore"
        MISSING_DEPS=1
    fi
    
    cd ../..
else
    echo -e "${RED}✗${NC} Backend project not found"
    MISSING_DEPS=1
fi
echo ""

# Check for SQL Server connection
echo "Checking SQL Server container..."
if command_exists docker; then
    if docker ps | grep -q mssql-express; then
        echo -e "${GREEN}✓${NC} SQL Server container is running"
        
        # Test SQL Server connection
        if docker exec mssql-express /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P Skittles123! -C -Q "SELECT @@VERSION" > /dev/null 2>&1; then
            echo -e "${GREEN}✓${NC} SQL Server is responding to queries"
            echo "   Host: localhost:1433"
            echo "   Database: SampleDB"
        else
            echo -e "${YELLOW}⚠${NC} Container running but SQL Server not responding"
            MISSING_DEPS=1
        fi
    else
        echo -e "${RED}✗${NC} SQL Server container is not running"
        echo "   Run: docker start mssql-express"
        echo "   Or run the start script if container doesn't exist"
        MISSING_DEPS=1
    fi
else
    echo -e "${RED}✗${NC} Docker not found"
    echo "   Install from: https://www.docker.com/products/docker-desktop"
    MISSING_DEPS=1
fi
echo ""

# Summary
echo "================================================"
if [ $MISSING_DEPS -eq 0 ]; then
    echo -e "${GREEN}✓ All dependencies are installed!${NC}"
    echo ""
    echo "You can now run:"
    echo "  npm run dev      - Start frontend"
    echo "  ./start_backend.sh - Start backend"
    exit 0
else
    echo -e "${RED}✗ Some dependencies are missing${NC}"
    echo ""
    echo "To fix missing dependencies, run:"
    echo ""
    
    if [ ! -d "node_modules" ]; then
        echo "  npm install"
    fi
    
    if [ ! -d "Backend/IntraformsAPI/obj" ]; then
        echo "  cd Backend/IntraformsAPI && dotnet restore"
    fi
    
    echo ""
    exit 1
fi
