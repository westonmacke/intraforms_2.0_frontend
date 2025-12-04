#!/bin/bash

# Manual SFTP Deployment Script for Mac
# Deploys Vue.js frontend to Windows Server IIS via SFTP

set -e

echo "=== SFTP Deployment to IIS ==="

# Configuration
read -p "SFTP Server (IP or hostname): " SFTP_HOST
read -p "SFTP Port [22]: " SFTP_PORT
SFTP_PORT=${SFTP_PORT:-22}
read -p "SFTP Username: " SFTP_USERNAME
read -sp "SFTP Password: " SFTP_PASSWORD
echo ""
read -p "Remote Path (e.g., /c/inetpub/wwwroot/intraforms): " SFTP_REMOTE_PATH

echo ""
echo "Configuration:"
echo "  Host: $SFTP_HOST:$SFTP_PORT"
echo "  User: $SFTP_USERNAME"
echo "  Remote Path: $SFTP_REMOTE_PATH"
echo ""

read -p "Continue with deployment? (y/n): " confirm
if [[ $confirm != "y" ]]; then
    echo "Deployment cancelled"
    exit 0
fi

# Build the project
echo ""
echo "📦 Building production version..."
npm run build

if [ $? -ne 0 ]; then
    echo "❌ Build failed"
    exit 1
fi

echo "✅ Build completed successfully"
echo ""

# Check if lftp is installed
if ! command -v lftp &> /dev/null; then
    echo "⚠️  lftp not found. Installing via Homebrew..."
    if command -v brew &> /dev/null; then
        brew install lftp
    else
        echo "❌ Homebrew not found. Please install lftp manually:"
        echo "   brew install lftp"
        exit 1
    fi
fi

# Deploy using lftp
echo "🚀 Deploying to $SFTP_HOST..."
echo ""

lftp -u "$SFTP_USERNAME,$SFTP_PASSWORD" sftp://"$SFTP_HOST":"$SFTP_PORT" <<EOF
set sftp:auto-confirm yes
set ssl:verify-certificate no
cd $SFTP_REMOTE_PATH
lcd dist
mirror --reverse --delete --verbose .
bye
EOF

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Deployment completed successfully!"
    echo "Your application should now be live on the IIS server"
else
    echo ""
    echo "❌ Deployment failed"
    echo ""
    echo "Troubleshooting:"
    echo "1. Verify your IP is whitelisted on the Windows Server firewall"
    echo "2. Check your credentials are correct"
    echo "3. Ensure the remote path exists and has proper permissions"
    echo "4. Test connection: sftp -P $SFTP_PORT $SFTP_USERNAME@$SFTP_HOST"
    exit 1
fi
