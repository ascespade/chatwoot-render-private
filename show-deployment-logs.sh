#!/bin/bash
# Simple script that shows deployment logs directly - no filtering

echo "📋 Showing Deployment Logs (Raw)"
echo "════════════════════════════════════════════════════"
echo ""

# Try Railway CLI
if command -v railway &> /dev/null; then
  echo "📡 Fetching logs via Railway CLI..."
  echo ""
  
  # Try different methods to get logs
  LOGS=$(railway logs --tail 100 2>&1)
  
  if [ $? -ne 0 ] || [ -z "$LOGS" ] || echo "$LOGS" | grep -qiE "error|not found"; then
    echo "⚠️  Method 1 failed, trying service-specific..."
    LOGS=$(railway logs --service "chatwoot-render-private" --tail 100 2>&1)
  fi
  
  if [ $? -ne 0 ] || [ -z "$LOGS" ] || echo "$LOGS" | grep -qiE "error|not found"; then
    echo "⚠️  Method 2 failed, trying 'web' service..."
    LOGS=$(railway logs --service "web" --tail 100 2>&1)
  fi
  
  if [ ! -z "$LOGS" ] && ! echo "$LOGS" | grep -qiE "error|not found|command not found"; then
    LOG_COUNT=$(echo "$LOGS" | wc -l)
    echo "✅ Got $LOG_COUNT log lines"
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "📋 Latest Logs (Last 30 lines):"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "$LOGS" | tail -30
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    
    # Check for deployment indicators
    if echo "$LOGS" | grep -qiE "Starting Container|Loading Installation|ConfigLoader"; then
      echo "🚀 DEPLOYMENT IN PROGRESS:"
      echo ""
      echo "$LOGS" | grep -iE "Starting Container|Loading Installation|ConfigLoader|Auto-SuperAdmin|Booting|Rails|Puma|Listening" | tail -10 | sed 's/^/   /'
    fi
    
    # Check for success
    if echo "$LOGS" | grep -qiE "Listening on|Rails application started|started in production|Booting Puma"; then
      echo ""
      echo "✅ ✅ ✅ APPLICATION IS RUNNING! ✅ ✅ ✅"
    fi
    
  else
    echo "❌ Could not fetch logs"
    echo ""
    echo "Error output:"
    echo "$LOGS" | head -10
    echo ""
    echo "💡 Try running in WSL:"
    echo "   wsl railway logs --tail 50"
  fi
else
  echo "❌ Railway CLI not found"
  echo ""
  echo "💡 Options:"
  echo "   1. Install Railway CLI"
  echo "   2. Use WSL: wsl railway logs --tail 50"
  echo "   3. Check Railway Dashboard"
fi

echo ""

