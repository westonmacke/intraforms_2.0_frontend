#!/bin/bash

# Start SQL Server container in the background
echo "Starting SQL Server container..."
docker-compose up -d

# Wait for SQL Server to be ready
echo "Waiting for SQL Server to start..."
sleep 10

# Check if container is running
if docker ps | grep -q mssql-express; then
    echo "✅ SQL Server is running!"
    echo "Connection details:"
    echo "  Host: localhost"
    echo "  Port: 1433"
    echo "  User: sa"
    echo "  Password: Skittles123!"
    echo "  Database: SampleDB"
else
    echo "❌ Failed to start SQL Server container"
    exit 1
fi
