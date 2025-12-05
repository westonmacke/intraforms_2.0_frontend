#!/bin/bash

# Stop the Vue development server running on port 3000
PID=$(lsof -ti:3000)

if [ -z "$PID" ]; then
  echo "No development server running on port 3000"
else
  kill $PID
  echo "Development server stopped (PID: $PID)"
fi
