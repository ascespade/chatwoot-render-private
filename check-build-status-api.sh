#!/bin/bash
# Check build status using Railway API (works without Railway CLI)

source .env 2>/dev/null || {
  echo "❌ Error: .env file not found"
  exit 1
}

if [ -z "$RAILWAY_TOKEN" ] || [ -z "$RAILWAY_PROJECT_ID" ]; then
  echo "❌ Missing Railway credentials in .env file"
  echo "   Need: RAILWAY_TOKEN and RAILWAY_PROJECT_ID"
  exit 1
fi

echo "🔍 Checking Build Status (Using Railway API)"
echo "════════════════════════════════════════════════════"
echo ""

# Get services first
echo "📡 Fetching services..."
SERVICES_RESPONSE=$(curl -s -X GET \
  -H "Authorization: Bearer $RAILWAY_TOKEN" \
  -H "Content-Type: application/json" \
  "https://backboard.railway.app/v2/projects/$RAILWAY_PROJECT_ID/services" 2>/dev/null)

if [ $? -ne 0 ] || [ -z "$SERVICES_RESPONSE" ]; then
  echo "❌ Failed to fetch services from Railway API"
  exit 1
fi

# Find web service ID
WEB_SERVICE_ID=$(echo "$SERVICES_RESPONSE" | grep -oE '"id":"[^"]*"' | head -1 | cut -d'"' -f4)

if [ -z "$WEB_SERVICE_ID" ]; then
  echo "⚠️  Could not find service ID, trying to get logs from all services..."
  WEB_SERVICE_ID=""
fi

echo "✅ Connected to Railway API"
if [ ! -z "$WEB_SERVICE_ID" ]; then
  echo "   Service ID: $WEB_SERVICE_ID"
fi
echo ""

# Get logs
echo "📋 Fetching latest build logs..."
if [ ! -z "$WEB_SERVICE_ID" ]; then
  LOGS_RESPONSE=$(curl -s -X GET \
    -H "Authorization: Bearer $RAILWAY_TOKEN" \
    -H "Content-Type: application/json" \
    "https://backboard.railway.app/v2/services/$WEB_SERVICE_ID/logs?lines=100" 2>/dev/null)
else
  # Try to get from deployments endpoint
  LOGS_RESPONSE=$(curl -s -X GET \
    -H "Authorization: Bearer $RAILWAY_TOKEN" \
    -H "Content-Type: application/json" \
    "https://backboard.railway.app/v2/projects/$RAILWAY_PROJECT_ID/deployments" 2>/dev/null)
fi

# Parse logs (Railway API returns JSON with log entries)
if [ ! -z "$LOGS_RESPONSE" ]; then
  # Extract log messages from JSON response
  LATEST_LOGS=$(echo "$LOGS_RESPONSE" | grep -oE '"message":"[^"]*"' | sed 's/"message":"//g' | sed 's/"$//g' | tail -50)
  
  if [ ! -z "$LATEST_LOGS" ]; then
    LOG_COUNT=$(echo "$LATEST_LOGS" | wc -l)
    echo "✅ Got $LOG_COUNT log entries"
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
      echo "⏳ BUILD STUCK: Vite is rendering chunks"
      echo ""
      echo "⚠️  Build has been at 'rendering chunks' for 20+ minutes"
      echo ""
      echo "Last activity:"
      echo "$LATEST_LOGS" | grep -iE "rendering|computing|chunks" | tail -3 | sed 's/^/   /'
      echo ""
      echo "💡 Possible causes:"
      echo "   • Large bundle size (4194 modules)"
      echo "   • Insufficient memory in Railway build environment"
      echo "   • Vite optimization taking too long"
      echo ""
      echo "🔧 Recommended Actions:"
      echo "   1. Check Railway Dashboard for memory/timeout errors"
      echo "   2. If stuck >30 min total, cancel & retry deployment"
      echo "   3. Consider checking Railway plan limits"
      
    elif echo "$LATEST_LOGS" | grep -qiE "transforming|Building with Vite"; then
      echo "⏳ BUILD IN PROGRESS: Transforming modules"
      
    elif echo "$LATEST_LOGS" | grep -qiE "Listening on|Rails application started|Booting Puma"; then
      echo "✅ BUILD COMPLETE: Application is running!"
      
    else
      echo "⏸️  Showing latest activity:"
      echo "$LATEST_LOGS" | tail -5 | sed 's/^/   /'
    fi
    
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "📋 Latest Log Activity (last 10 lines):"
    echo ""
    echo "$LATEST_LOGS" | tail -10 | sed 's/^/   /'
    
  else
    echo "⚠️  Could not parse logs from API response"
    echo "   Raw response (first 200 chars):"
    echo "$LOGS_RESPONSE" | head -c 200
    echo "..."
  fi
else
  echo "❌ Failed to fetch logs from Railway API"
fi

echo ""
echo "════════════════════════════════════════════════════"
echo "💡 If build is truly stuck (>30 minutes):"
echo "   1. Check Railway Dashboard: https://railway.app/dashboard"
echo "   2. Look for memory errors or timeouts in build logs"
echo "   3. Cancel and retry the deployment"
echo ""
echo "💡 To use Railway CLI (if installed in WSL):"
echo "   wsl bash check-build-status.sh"
echo ""

