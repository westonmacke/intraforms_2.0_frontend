#!/bin/bash

# Git pull script
echo "📥 Pulling latest changes from repository..."
echo ""

# Get current branch
current_branch=$(git branch --show-current)

# Check for uncommitted changes
if [[ -n $(git status -s) ]]; then
    echo "⚠️  You have uncommitted changes:"
    git status -s
    echo ""
    read -p "Stash changes before pulling? (y/n): " stash_choice
    
    if [[ "$stash_choice" == "y" || "$stash_choice" == "Y" ]]; then
        echo "Stashing changes..."
        git stash
        stashed=true
    else
        echo "❌ Cannot pull with uncommitted changes. Commit or stash them first."
        exit 1
    fi
fi

# Pull from remote
echo "Pulling from origin/$current_branch..."
git pull origin "$current_branch"

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Successfully pulled from origin/$current_branch"
    
    # Apply stashed changes if any
    if [[ "$stashed" == "true" ]]; then
        echo ""
        read -p "Apply stashed changes? (y/n): " apply_choice
        if [[ "$apply_choice" == "y" || "$apply_choice" == "Y" ]]; then
            echo "Applying stashed changes..."
            git stash pop
            if [ $? -eq 0 ]; then
                echo "✅ Stashed changes applied successfully"
            else
                echo "⚠️  Conflicts detected. Resolve them manually."
                echo "Use 'git stash list' to see stashed changes"
            fi
        else
            echo "ℹ️  Stashed changes kept. Use 'git stash pop' to apply later"
        fi
    fi
else
    echo ""
    echo "❌ Failed to pull changes"
    exit 1
fi
