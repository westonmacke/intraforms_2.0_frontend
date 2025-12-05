#!/bin/bash

# Build and serve production version of the frontend

echo "Building production version..."
npm run build

if [ $? -eq 0 ]; then
  echo "✅ Build completed successfully"
  echo ""
  echo "Starting production preview server in the background..."
  nohup npm run preview -- --host > prod.log 2>&1 &
  
  sleep 2
  PID=$(lsof -ti:4173)
  
  if [ -z "$PID" ]; then
    echo "❌ Failed to start production server"
    exit 1
  else
    echo "✅ Production server started in the background"
    echo "   Process ID: $PID"
    echo "   Local URL: http://localhost:4173"
    echo "   Network URL: http://$(ipconfig getifaddr en0):4173"
    echo "   Logs: tail -f prod.log"
    echo "   Stop server: kill $PID"
  fi
else
  echo "❌ Build failed"
  exit 1
fi
