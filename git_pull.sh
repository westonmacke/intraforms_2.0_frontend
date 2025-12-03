#!/bin/bash

# Git pull script to get latest changes

# Get current branch
current_branch=$(git branch --show-current)

echo "Pulling latest changes from $current_branch..."

# Pull latest changes
git pull origin "$current_branch"

if [ $? -eq 0 ]; then
  echo "✅ Successfully pulled latest changes from $current_branch"
else
  echo "❌ Failed to pull changes"
  exit 1
fi
