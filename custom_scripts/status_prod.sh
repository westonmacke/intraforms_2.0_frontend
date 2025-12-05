#!/bin/bash

# Check if the production preview server is running on port 4173
PID=$(lsof -ti:4173)

if [ -z "$PID" ]; then
  echo "❌ Production server is NOT running"
  exit 1
else
  echo "✅ Production server is running"
  echo "   Process ID: $PID"
  echo "   Local URL: http://localhost:4173"
  echo "   Network URL: http://$(ipconfig getifaddr en0):4173"
  echo "   Logs: tail -f prod.log"
  exit 0
fi
