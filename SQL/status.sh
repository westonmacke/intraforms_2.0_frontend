#!/bin/bash

# Check status of SQL Server container
echo "Checking SQL Server container status..."
echo ""

if docker ps | grep -q mssql-express; then
    echo "✅ Container Status: RUNNING"
    echo ""
    docker ps --filter "name=mssql-express" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
    echo ""
    
    # Test SQL Server connection
    echo "Testing SQL Server connection..."
    if docker exec mssql-express /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P Skittles123! -C -Q "SELECT @@VERSION" > /dev/null 2>&1; then
        echo "✅ SQL Server is responding to queries"
        echo ""
        echo "Connection details:"
        echo "  Host: localhost"
        echo "  Port: 1433"
        echo "  User: sa"
        echo "  Password: Skittles123!"
        echo "  Database: SampleDB"
    else
        echo "⚠️  Container is running but SQL Server is not responding"
    fi
else
    echo "❌ Container Status: STOPPED"
    echo ""
    echo "Run './start.sh' to start the SQL Server container"
fi
