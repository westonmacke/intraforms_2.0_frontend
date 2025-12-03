#!/bin/bash

# Start the Vue development server in the background
nohup npm run dev > dev.log 2>&1 &

echo "Development server started in the background"
echo "Process ID: $!"
echo "View logs: tail -f dev.log"
echo "Stop server: kill \$(lsof -ti:3000)"
