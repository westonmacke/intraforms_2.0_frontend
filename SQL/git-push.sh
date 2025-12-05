#!/bin/bash

# Git push script
echo "📤 Pushing changes to repository..."
echo ""

# Check if there are any changes to commit
if [[ -z $(git status -s) ]]; then
    echo "ℹ️  No changes to commit"
    echo ""
else
    # Show current status
    echo "Current changes:"
    git status -s
    echo ""
    
    # Prompt for commit message
    read -p "Enter commit message: " commit_message
    
    if [[ -z "$commit_message" ]]; then
        echo "❌ Commit message cannot be empty"
        exit 1
    fi
    
    # Stage all changes
    echo ""
    echo "Staging all changes..."
    git add .
    
    # Commit changes
    echo "Committing changes..."
    git commit -m "$commit_message"
    
    if [ $? -ne 0 ]; then
        echo "❌ Failed to commit changes"
        exit 1
    fi
fi

# Get current branch
current_branch=$(git branch --show-current)

# Push to remote
echo "Pushing to origin/$current_branch..."
git push origin "$current_branch"

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Successfully pushed to origin/$current_branch"
else
    echo ""
    echo "❌ Failed to push changes"
    exit 1
fi
