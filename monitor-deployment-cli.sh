#!/bin/bash
# Monitor Railway deployment using CLI until it succeeds

if ! command -v railway &> /dev/null; then
  echo "❌ Railway CLI not installed"
  echo "Install it with: curl -fsSL https://railway.com/install.sh | sh"
  exit 1
fi

echo "🚂 Monitoring Railway Deployment (CLI Mode)..."
echo "════════════════════════════════════════════════════"
echo ""
echo "Will check logs every 10 seconds until deployment succeeds"
echo "Press Ctrl+C to stop monitoring"
echo ""
echo "════════════════════════════════════════════════════"
echo ""

CHECK_COUNT=0
SUCCESS_INDICATORS=(
  "Listening on"
  "Puma starting"
  "Rails application started"
  "booted"
  "started in production"
  "=> Booting Puma"
  "=> Rails.*application starting"
)

ERROR_INDICATORS=(
  "error"
  "Error"
  "ERROR"
  "Exception"
  "failed"
  "Failed"
  "crash"
  "Exiting"
  "NameError"
  "NoMethodError"
)

while true; do
  CHECK_COUNT=$((CHECK_COUNT + 1))
  TIMESTAMP=$(date +'%Y-%m-%d %H:%M:%S')
  
  echo "[$TIMESTAMP] Check #$CHECK_COUNT - Fetching recent logs..."
  
  # Get recent logs
  RECENT_LOGS=$(railway logs --tail 100 2>/dev/null)
  
  if [ $? -ne 0 ]; then
    echo "   ⚠️  Failed to fetch logs. Retrying..."
    sleep 10
    continue
  fi
  
  # Check for success indicators
  SUCCESS_FOUND=false
  for indicator in "${SUCCESS_INDICATORS[@]}"; do
    if echo "$RECENT_LOGS" | grep -qiE "$indicator"; then
      SUCCESS_FOUND=true
      SUCCESS_LINE=$(echo "$RECENT_LOGS" | grep -iE "$indicator" | tail -1)
      break
    fi
  done
  
  # Check for errors
  ERROR_FOUND=false
  ERROR_LINE=""
  for indicator in "${ERROR_INDICATORS[@]}"; do
    if echo "$RECENT_LOGS" | grep -qiE "$indicator"; then
      # Skip if it's just in stack trace (already handled errors)
      if ! echo "$RECENT_LOGS" | grep -iE "$indicator" | grep -q "from.*gems\|from.*lib"; then
        ERROR_FOUND=true
        ERROR_LINE=$(echo "$RECENT_LOGS" | grep -iE "$indicator" | grep -v "from.*gems\|from.*lib" | tail -1)
        break
      fi
    fi
  done
  
  if [ "$SUCCESS_FOUND" = true ]; then
    echo ""
    echo "════════════════════════════════════════════════════"
    echo "✅ DEPLOYMENT SUCCESSFUL!"
    echo "════════════════════════════════════════════════════"
    echo ""
    echo "Success indicator found:"
    echo "   $SUCCESS_LINE"
    echo ""
    echo "Deployment completed at: $TIMESTAMP"
    echo "Total checks: $CHECK_COUNT"
    echo ""
    echo "📋 Latest log lines:"
    echo "$RECENT_LOGS" | tail -5 | sed 's/^/   /'
    echo ""
    echo "✅ Application is running successfully!"
    echo ""
    exit 0
  elif [ "$ERROR_FOUND" = true ]; then
    echo ""
    echo "⚠️  ERROR DETECTED in logs:"
    echo "   $ERROR_LINE"
    echo ""
    echo "Showing last 10 log lines:"
    echo "$RECENT_LOGS" | tail -10 | sed 's/^/   /'
    echo ""
    echo "⏳ Continuing to monitor... (errors may be resolved in next deployment)"
    echo ""
  else
    # Show status - what's happening
    LAST_LINE=$(echo "$RECENT_LOGS" | tail -1)
    echo "   Latest: ${LAST_LINE:0:80}..."
  fi
  
  # Wait before next check
  sleep 10
done

