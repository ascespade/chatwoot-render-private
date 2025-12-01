#!/bin/bash
# Automated deployment monitoring - keeps checking until success

source .env 2>/dev/null || {
  echo "❌ Error: .env file not found"
  exit 1
}

echo "🚂 Automated Railway Deployment Monitor"
echo "════════════════════════════════════════════════════"
echo "Project: chatwoot-private"
echo "Monitoring every 10 seconds..."
echo "════════════════════════════════════════════════════"
echo ""

CHECK_COUNT=0
MAX_CHECKS=300  # Maximum 50 minutes (300 * 10 seconds)
SUCCESS=false

while [ $CHECK_COUNT -lt $MAX_CHECKS ]; do
  CHECK_COUNT=$((CHECK_COUNT + 1))
  TIMESTAMP=$(date +'%H:%M:%S')
  
  echo "[$TIMESTAMP] Check #$CHECK_COUNT"
  
  # Method 1: Use Railway CLI if available (most reliable)
  if command -v railway &> /dev/null; then
    RECENT_LOGS=$(railway logs --tail 100 2>/dev/null)
    
    if [ $? -eq 0 ]; then
      # Check for success
      if echo "$RECENT_LOGS" | grep -qiE "Listening on|Puma starting|Rails application started|started in production"; then
        SUCCESS=true
        echo ""
        echo "════════════════════════════════════════════════════"
        echo "✅ ✅ ✅ DEPLOYMENT SUCCESSFUL! ✅ ✅ ✅"
        echo "════════════════════════════════════════════════════"
        echo ""
        echo "Success indicators found:"
        echo "$RECENT_LOGS" | grep -iE "Listening on|Puma starting|Rails application started" | tail -3 | sed 's/^/   /'
        echo ""
        echo "📋 Latest logs:"
        echo "$RECENT_LOGS" | tail -5 | sed 's/^/   /'
        echo ""
        echo "✅ Deployment completed successfully!"
        echo "   Total checks: $CHECK_COUNT"
        echo "   Time: $(date +'%Y-%m-%d %H:%M:%S')"
        echo ""
        break
      fi
      
      # Check for errors
      if echo "$RECENT_LOGS" | grep -qiE "NameError|NoMethodError|uninitialized constant|SyntaxError"; then
        ERROR=$(echo "$RECENT_LOGS" | grep -iE "NameError|NoMethodError|uninitialized constant" | tail -1)
        echo "   ⚠️  Error detected: ${ERROR:0:100}..."
      fi
      
      # Show progress
      LAST_LOG=$(echo "$RECENT_LOGS" | tail -1)
      echo "   Latest: ${LAST_LOG:0:70}..."
    fi
  else
    # Method 2: Use API method
    echo "   Using API method..."
    
    # Get services first to get service IDs
    SERVICES=$(curl -s -X GET \
      -H "Authorization: Bearer $RAILWAY_TOKEN" \
      -H "Content-Type: application/json" \
      "https://backboard.railway.app/v2/projects/$RAILWAY_PROJECT_ID/services" 2>/dev/null)
    
    # Extract web service ID (simplified - would need jq for proper parsing)
    # For now, just check if we can get any response
    if echo "$SERVICES" | grep -q "id"; then
      echo "   ✓ API connection working"
    fi
  fi
  
  # Wait before next check
  sleep 10
done

if [ "$SUCCESS" = false ]; then
  echo ""
  echo "⏱️  Monitoring timeout reached ($MAX_CHECKS checks)"
  echo "   Check deployment manually: railway logs --tail 200"
  exit 1
fi

exit 0

