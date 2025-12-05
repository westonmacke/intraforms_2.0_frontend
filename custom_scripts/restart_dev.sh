#!/bin/bash

# Restart the development server

echo "Restarting development server..."

# Stop the dev server
./stop_dev.sh

# Wait a moment
sleep 1

# Start the dev server
./start_dev.sh
