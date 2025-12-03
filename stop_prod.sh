#!/bin/bash

# Stop the production preview server running on port 4173
PID=$(lsof -ti:4173)

if [ -z "$PID" ]; then
  echo "No production server running on port 4173"
else
  kill $PID
  echo "Production server stopped (PID: $PID)"
fi
