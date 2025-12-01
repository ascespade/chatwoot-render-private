#!/bin/bash
# Verify Railway setup using Railway CLI (if available) or API

echo "🔍 Verifying Railway Setup..."
echo ""

# Check if Railway CLI is installed
if command -v railway &> /dev/null; then
  echo "✅ Railway CLI is installed"
  echo ""
  echo "📋 Current Railway Project Status:"
  railway status 2>/dev/null || echo "   Run 'railway link' first if needed"
  echo ""
  
  echo "📦 Getting project info via Railway CLI..."
  PROJECT_INFO=$(railway status --json 2>/dev/null || railway environment 2>/dev/null)
  echo "$PROJECT_INFO"
  echo ""
  
  echo "✅ Railway CLI is ready to use!"
  echo "   You can use 'railway logs', 'railway variables', etc."
else
  echo "⚠️  Railway CLI not installed"
  echo "   Install it with: curl -fsSL https://railway.com/install.sh | sh"
  echo ""
  
  # Fallback to API method
  source .env 2>/dev/null || {
    echo "❌ Error: .env file not found"
    exit 1
  }
  
  echo "Using API method instead..."
  bash test-railway-connection.sh
fi

echo ""
echo "════════════════════════════════════════════════════"
echo "✅ Setup Complete!"
echo "════════════════════════════════════════════════════"

