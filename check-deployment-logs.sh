#!/bin/bash
# Simple script to check deployment logs (Starting Container, Loading Installation, etc.)

source .env 2>/dev/null || {
  echo "❌ Error: .env file not found"
  exit 1
}

echo "🔍 Checking Deployment Logs"
echo "════════════════════════════════════════════════════"
echo ""

# Try Railway CLI
if command -v railway &> /dev/null; then
  echo "📡 Fetching logs via Railway CLI..."
  echo ""
  
  # Try multiple methods
  LOGS=$(railway logs --tail 100 2>/dev/null)
  
  if [ -z "$LOGS" ] || [ "$(echo "$LOGS" | wc -l)" -lt 5 ]; then
    LOGS=$(railway logs --service "chatwoot-render-private" --tail 100 2>/dev/null)
  fi
  
  if [ -z "$LOGS" ] || [ "$(echo "$LOGS" | wc -l)" -lt 5 ]; then
    LOGS=$(railway logs --service "web" --tail 100 2>/dev/null)
  fi
  
  if [ ! -z "$LOGS" ] && [ "$(echo "$LOGS" | wc -l)" -ge 5 ]; then
    echo "✅ Got $(echo "$LOGS" | wc -l) log lines"
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "🚀 DEPLOYMENT LOGS (Starting Container, Loading Installation, etc.):"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    
    # Show deployment logs (not build logs)
    DEPLOY_LOGS=$(echo "$LOGS" | grep -iE "Starting Container|Loading Installation|ConfigLoader|Auto-SuperAdmin|Booting|Rails|Puma|Listening|Processing|INFO|WARN|ERROR" || echo "$LOGS")
    
    if [ ! -z "$DEPLOY_LOGS" ]; then
      echo "$DEPLOY_LOGS" | tail -30 | sed 's/^/   /'
    else
      echo "   No deployment logs found, showing all logs:"
      echo "$LOGS" | tail -30 | sed 's/^/   /'
    fi
    
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "📊 Status Check:"
    echo ""
    
    if echo "$LOGS" | grep -qiE "Listening on|Rails application started|started in production|Booting Puma"; then
      echo "✅ Application is RUNNING!"
    elif echo "$LOGS" | grep -qiE "Starting Container|Loading Installation|ConfigLoader"; then
      echo "⏳ Application is STARTING (deployment in progress)..."
    elif echo "$LOGS" | grep -qiE "Error|ERROR|failed|Failed"; then
      echo "❌ Error detected in logs"
    else
      echo "⏸️  Status unknown"
    fi
    
  else
    echo "❌ Could not fetch logs"
    echo "   Output: $(echo "$LOGS" | head -5)"
  fi
else
  echo "❌ Railway CLI not found"
  echo ""
  echo "💡 Try:"
  echo "   1. Install Railway CLI"
  echo "   2. Or use WSL if Railway CLI is installed there:"
  echo "      wsl railway logs --tail 50"
  echo "   3. Or check Railway Dashboard"
fi

echo ""

