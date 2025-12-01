#!/bin/bash
# Check if build is stuck and diagnose the issue

echo "🔍 Checking Build Status & Diagnostics"
echo "════════════════════════════════════════════════════"
echo ""

# Try to find Railway CLI in common locations
RAILWAY_CMD=""
if command -v railway &> /dev/null; then
  RAILWAY_CMD="railway"
elif [ -f ~/.railway/bin/railway ]; then
  RAILWAY_CMD="$HOME/.railway/bin/railway"
elif [ -f /usr/local/bin/railway ]; then
  RAILWAY_CMD="/usr/local/bin/railway"
elif [ -f ~/.local/bin/railway ]; then
  RAILWAY_CMD="$HOME/.local/bin/railway"
fi

# Also try to source Railway from common install locations
if [ -z "$RAILWAY_CMD" ]; then
  # Check if Railway is in PATH via different methods
  export PATH="$HOME/.railway/bin:$HOME/.local/bin:/usr/local/bin:$PATH"
  if command -v railway &> /dev/null; then
    RAILWAY_CMD="railway"
  fi
fi

# Check if we can use Railway API as fallback
USE_API=false
if [ -z "$RAILWAY_CMD" ]; then
  source .env 2>/dev/null
  if [ ! -z "$RAILWAY_TOKEN" ] && [ ! -z "$RAILWAY_PROJECT_ID" ]; then
    USE_API=true
    echo "⚠️  Railway CLI not found, using API method..."
  fi
fi

if [ ! -z "$RAILWAY_CMD" ]; then
  echo "✅ Railway CLI found: $RAILWAY_CMD"
  echo ""
  echo "📡 Fetching latest logs from Railway..."
  echo ""
  
  # Get last 100 lines to see current activity
  LATEST_LOGS=$($RAILWAY_CMD logs --tail 100 2>&1)
  
  if [ $? -ne 0 ] || [ -z "$LATEST_LOGS" ] || echo "$LATEST_LOGS" | grep -qiE "error|not found|command not found"; then
    echo "⚠️  Railway CLI command failed, trying different methods..."
    # Try with service name
    LATEST_LOGS=$($RAILWAY_CMD logs --service "chatwoot-render-private" --tail 100 2>&1)
  fi
  
  if [ ! -z "$LATEST_LOGS" ] && ! echo "$LATEST_LOGS" | grep -qiE "error|not found|command not found"; then
    LOG_COUNT=$(echo "$LATEST_LOGS" | grep -v '^$' | wc -l)
    echo "✅ Got $LOG_COUNT log lines"
    echo ""
    
    # Check for errors
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "🔍 Error Check:"
    ERRORS=$(echo "$LATEST_LOGS" | grep -iE "error|Error|ERROR|failed|Failed|FAILED|fatal|Fatal|exception|Exception|killed|timeout|out of memory|OOM")
    if [ ! -z "$ERRORS" ]; then
      echo "❌ ERRORS FOUND:"
      echo "$ERRORS" | tail -10 | sed 's/^/   /'
    else
      echo "✅ No errors found in recent logs"
    fi
    
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "📊 Current Build Stage:"
    
    # Check build stage
    if echo "$LATEST_LOGS" | grep -qiE "rendering chunks|computing gzip"; then
      echo "⏳ BUILD STUCK: Vite is rendering chunks (this can take 5-15+ minutes)"
      echo ""
      echo "Last activity:"
      echo "$LATEST_LOGS" | grep -iE "rendering|computing|chunks" | tail -3 | sed 's/^/   /'
      echo ""
      echo "💡 This is normal for large apps but 20+ minutes is excessive."
      echo "💡 Possible causes:"
      echo "   • Large bundle size (4194 modules is a lot)"
      echo "   • Insufficient memory in Railway build environment"
      echo "   • Vite optimization taking too long"
      echo ""
      echo "🔧 Solutions:"
      echo "   1. Wait a bit longer (can take 15-30 min for first build)"
      echo "   2. Check Railway build logs for memory issues"
      echo "   3. Consider optimizing bundle size"
      
    elif echo "$LATEST_LOGS" | grep -qiE "transforming|Building with Vite"; then
      echo "⏳ BUILD IN PROGRESS: Transforming modules"
      echo ""
      MODULES=$(echo "$LATEST_LOGS" | grep -oE "[0-9]+ modules transformed" | tail -1)
      if [ ! -z "$MODULES" ]; then
        echo "   $MODULES"
      fi
      
    elif echo "$LATEST_LOGS" | grep -qiE "bundle install|Installing gem"; then
      echo "⏳ BUILD IN PROGRESS: Installing Ruby gems"
      
    elif echo "$LATEST_LOGS" | grep -qiE "pnpm i|Installing packages"; then
      echo "⏳ BUILD IN PROGRESS: Installing Node packages"
      
    elif echo "$LATEST_LOGS" | grep -qiE "Listening on|Rails application started|Booting Puma"; then
      echo "✅ BUILD COMPLETE: Application is running!"
      
    else
      echo "⏸️  Unknown stage - showing latest activity:"
      echo "$LATEST_LOGS" | tail -5 | sed 's/^/   /'
    fi
    
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "📋 Latest Log Activity (last 10 lines):"
    echo ""
    echo "$LATEST_LOGS" | tail -10 | sed 's/^/   /'
    
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "⏱️  Time Analysis:"
    TIMESTAMPS=$(echo "$LATEST_LOGS" | grep -oE "2025-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}" | tail -5)
    if [ ! -z "$TIMESTAMPS" ]; then
      echo "Recent timestamps:"
      echo "$TIMESTAMPS" | sed 's/^/   /'
      echo ""
      FIRST=$(echo "$TIMESTAMPS" | head -1)
      LAST=$(echo "$TIMESTAMPS" | tail -1)
      echo "   First: $FIRST"
      echo "   Last:  $LAST"
      
      # Check if timestamps are updating
      if [ "$FIRST" = "$LAST" ]; then
        echo ""
        echo "⚠️  WARNING: Timestamps are NOT updating - build may be stuck!"
      else
        echo ""
        echo "✅ Timestamps are updating - build is still progressing"
      fi
    fi
    
  else
    echo "❌ Could not fetch logs from Railway CLI"
    echo "   Error output:"
    echo "$LATEST_LOGS" | head -5 | sed 's/^/   /'
    USE_API=true
  fi
elif [ "$USE_API" = true ]; then
  echo "📡 Using Railway API method..."
  echo ""
  
  if [ -z "$RAILWAY_TOKEN" ] || [ -z "$RAILWAY_PROJECT_ID" ]; then
    echo "❌ Missing Railway credentials in .env file"
    echo "   Need: RAILWAY_TOKEN and RAILWAY_PROJECT_ID"
    exit 1
  fi
  
  # Use API to get logs (simplified version)
  echo "⚠️  API method not fully implemented in this script"
  echo "   Please use Railway Dashboard or install Railway CLI properly"
  
else
  echo "❌ Railway CLI not found and API credentials not available"
  echo ""
  echo "💡 Solutions:"
  echo "   1. Install Railway CLI:"
  echo "      curl -fsSL https://railway.com/install.sh | sh"
  echo ""
  echo "   2. Or use WSL if Railway CLI is installed there:"
  echo "      wsl bash check-build-status.sh"
  echo ""
  echo "   3. Or check Railway Dashboard directly:"
  echo "      https://railway.app/dashboard"
  echo ""
  echo "   4. Or add Railway to PATH:"
  echo "      export PATH=\"\$HOME/.railway/bin:\$PATH\""
  exit 1
fi

echo ""
echo "════════════════════════════════════════════════════"
echo "💡 If build is truly stuck (>30 minutes), consider:"
echo "   1. Canceling the deployment in Railway dashboard"
echo "   2. Checking Railway build logs for memory/timeout errors"
echo "   3. Reducing bundle size or optimizing Vite build"
echo ""
