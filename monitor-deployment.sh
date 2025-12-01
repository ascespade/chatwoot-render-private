#!/bin/bash
# Monitor Railway deployment until it succeeds

source .env 2>/dev/null || {
  echo "❌ Error: .env file not found. Run setup-railway-automation.sh first."
  exit 1
}

echo "🚂 Monitoring Railway Deployment..."
echo "════════════════════════════════════════════════════"
echo ""
echo "Project: chatwoot-private"
echo "Will check every 10 seconds until deployment succeeds"
echo ""
echo "Press Ctrl+C to stop monitoring"
echo "════════════════════════════════════════════════════"
echo ""

CHECK_COUNT=0

while true; do
  CHECK_COUNT=$((CHECK_COUNT + 1))
  TIMESTAMP=$(date +'%Y-%m-%d %H:%M:%S')
  
  echo "[$TIMESTAMP] Check #$CHECK_COUNT - Checking deployment status..."
  
  # Try using Railway CLI first (if available)
  if command -v railway &> /dev/null; then
    # Get latest deployment status
    DEPLOY_STATUS=$(railway status 2>/dev/null | grep -i "status\|deploy" | head -5)
    
    # Also check logs for deployment completion
    RECENT_LOGS=$(railway logs --tail 50 2>/dev/null | tail -10)
    
    if echo "$RECENT_LOGS" | grep -qi "Listening\|starting\|booted\|Puma starting\|Rails.*started"; then
      echo ""
      echo "════════════════════════════════════════════════════"
      echo "✅ DEPLOYMENT SUCCESSFUL!"
      echo "════════════════════════════════════════════════════"
      echo ""
      echo "Application is running! Recent logs show:"
      echo "$RECENT_LOGS" | grep -i "Listening\|starting\|booted\|Puma starting\|Rails.*started" | head -3
      echo ""
      echo "Deployment completed at: $TIMESTAMP"
      echo "Total checks: $CHECK_COUNT"
      echo ""
      exit 0
    fi
    
    # Check for errors in logs
    if echo "$RECENT_LOGS" | grep -qi "error\|exception\|failed\|crash\|exiting"; then
      echo "⚠️  Found errors in logs:"
      echo "$RECENT_LOGS" | grep -i "error\|exception\|failed\|crash" | head -3
      echo ""
    fi
  else
    # Fallback to API method
    if [ -z "$RAILWAY_PROJECT_ID" ]; then
      echo "❌ RAILWAY_PROJECT_ID not set in .env"
      exit 1
    fi
    
    # Check deployment status via API
    DEPLOYMENTS=$(curl -s -X GET \
      -H "Authorization: Bearer $RAILWAY_TOKEN" \
      -H "Content-Type: application/json" \
      "https://backboard.railway.app/v1/projects/$RAILWAY_PROJECT_ID/deployments?limit=1" 2>/dev/null)
    
    if [ $? -eq 0 ]; then
      STATUS=$(echo "$DEPLOYMENTS" | grep -o '"status":"[^"]*"' | head -1 | cut -d'"' -f4)
      
      if [ "$STATUS" = "SUCCESS" ] || [ "$STATUS" = "success" ]; then
        echo ""
        echo "════════════════════════════════════════════════════"
        echo "✅ DEPLOYMENT SUCCESSFUL!"
        echo "════════════════════════════════════════════════════"
        echo ""
        echo "Deployment status: $STATUS"
        echo "Deployment completed at: $TIMESTAMP"
        echo "Total checks: $CHECK_COUNT"
        echo ""
        exit 0
      else
        echo "   Status: $STATUS"
      fi
    fi
  fi
  
  # Wait before next check
  echo "   ⏳ Waiting 10 seconds before next check..."
  sleep 10
done

