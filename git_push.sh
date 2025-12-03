#!/bin/bash

# Git push script with commit message

# Check if there are any changes to commit
if [[ -z $(git status -s) ]]; then
  echo "No changes to commit"
  exit 0
fi

# Show current status
echo "Current changes:"
git status -s
echo ""

# Prompt for commit message
read -p "Enter commit message: " commit_message

if [ -z "$commit_message" ]; then
  echo "❌ Commit message cannot be empty"
  exit 1
fi

# Add all changes
echo "Adding all changes..."
git add .

# Commit changes
echo "Committing changes..."
git commit -m "$commit_message"

# Push to current branch
echo "Pushing to remote..."
current_branch=$(git branch --show-current)
git push origin "$current_branch"

echo "✅ Successfully pushed to $current_branch"
