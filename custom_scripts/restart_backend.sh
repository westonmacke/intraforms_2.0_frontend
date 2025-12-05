#!/bin/bash

# Restart Intraforms Backend API

echo "🔄 Restarting Intraforms Backend API..."
echo ""

# Stop the backend
./stop_backend.sh

# Wait a moment
sleep 2

# Start the backend
./start_backend.sh
