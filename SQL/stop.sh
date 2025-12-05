#!/bin/bash

# Stop SQL Server container
echo "Stopping SQL Server container..."
docker-compose down

if [ $? -eq 0 ]; then
    echo "✅ SQL Server container stopped successfully"
else
    echo "❌ Failed to stop SQL Server container"
    exit 1
fi
