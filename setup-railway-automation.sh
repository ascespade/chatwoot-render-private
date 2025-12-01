#!/bin/bash

# Railway Automation Setup Script
# This script sets up the Railway automation environment

set -e

echo "🚂 Setting up Railway Automation..."

# Create dev_logs directory
mkdir -p dev_logs
echo "✓ Created dev_logs directory"

# Check if .env file exists
if [ ! -f .env ]; then
  echo "📝 Creating .env file from template..."
  cat > .env << 'EOF'
# Railway API Configuration
# Replace these values with your actual Railway credentials
# Get these from: Railway Dashboard → Settings → API Tokens
RAILWAY_TOKEN=your_railway_token_here
RAILWAY_PROJECT_ID=your_project_id_here
EOF
  echo "✓ Created .env file"
  echo "⚠️  Please verify the Railway token and project ID in .env file"
else
  echo "✓ .env file already exists"
fi

# Make scripts executable
echo "🔧 Making scripts executable..."
chmod +x tools/railway/*.sh 2>/dev/null || true
chmod +x dev_log_watcher.sh 2>/dev/null || true
chmod +x auto_deploy_check.sh 2>/dev/null || true
echo "✓ Scripts are now executable"

# Check for jq
if ! command -v jq &> /dev/null; then
  echo "⚠️  Warning: jq is not installed"
  echo "   Install it with:"
  echo "   - macOS: brew install jq"
  echo "   - Ubuntu/Debian: sudo apt-get install jq"
  echo "   - Windows: choco install jq"
else
  echo "✓ jq is installed"
fi

# Check for curl
if ! command -v curl &> /dev/null; then
  echo "⚠️  Warning: curl is not installed"
else
  echo "✓ curl is installed"
fi

echo ""
echo "✅ Railway automation setup complete!"
echo ""
echo "Next steps:"
echo "1. Verify .env file contains correct Railway credentials"
echo "2. Run log watcher: bash dev_log_watcher.sh"
echo "3. (Optional) Run deploy checker: bash auto_deploy_check.sh"
echo "4. Open dev_logs/web.log in Cursor to activate AutoFix Mode"
echo ""
echo "For more information, see: RAILWAY_AUTOMATION_SETUP.md"

