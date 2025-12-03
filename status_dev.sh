#!/bin/bash

# Check if the Vue development server is running on port 3000
PID=$(lsof -ti:3000)

if [ -z "$PID" ]; then
  echo "❌ Development server is NOT running"
  exit 1
else
  echo "✅ Development server is running"
  echo "   Process ID: $PID"
  echo "   URL: http://localhost:3000"
  echo "   Logs: tail -f dev.log"
  exit 0
fi
