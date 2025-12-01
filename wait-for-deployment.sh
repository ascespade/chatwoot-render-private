#!/bin/bash
# Continuously monitor Railway deployment until it succeeds
# This script will keep checking and only exit when deployment is successful

source .env 2>/dev/null || {
  echo "❌ Error: .env file not found"
  exit 1
}

echo "🚂 Railway Deployment Monitor"
echo "════════════════════════════════════════════════════"
echo "Will continuously check until deployment succeeds"
echo "Press Ctrl+C to stop"
echo "════════════════════════════════════════════════════"
echo ""

CHECK_COUNT=0
LAST_ERROR=""
SUCCESS_MESSAGE=""

# Function to check deployment status
check_deployment() {
  CHECK_COUNT=$((CHECK_COUNT + 1))
  TIMESTAMP=$(date +'%Y-%m-%d %H:%M:%S')
  
  echo "[$TIMESTAMP] Check #$CHECK_COUNT - Checking deployment..."
  
  # Try Railway CLI first
  if command -v railway &> /dev/null; then
    LOGS=$(railway logs --tail 150 2>/dev/null)
    
    if [ $? -eq 0 ] && [ ! -z "$LOGS" ]; then
      # Check for success
      if echo "$LOGS" | grep -qiE "Listening on tcp|Rails application started in production|started in production mode|Puma starting in.*mode"; then
        SUCCESS_MESSAGE=$(echo "$LOGS" | grep -iE "Listening on|Rails application started|Puma starting" | tail -1)
        return 0  # Success
      fi
      
      # Check for fatal errors
      if echo "$LOGS" | grep -qiE "NameError|NoMethodError|SyntaxError|uninitialized constant"; then
        LAST_ERROR=$(echo "$LOGS" | grep -iE "NameError|NoMethodError|SyntaxError|uninitialized constant" | tail -1)
        return 2  # Error
      fi
      
      # Show latest activity
      LAST_LINE=$(echo "$LOGS" | tail -1)
      echo "   Status: ${LAST_LINE:0:80}..."
      return 1  # In progress
    fi
  fi
  
  # Fallback: Try to check via log watcher output
  if [ -f "dev_logs/web.log" ] && [ -s "dev_logs/web.log" ]; then
    LOGS=$(tail -100 dev_logs/web.log 2>/dev/null)
    
    if echo "$LOGS" | grep -qiE "Listening on|Rails application started|started in production"; then
      SUCCESS_MESSAGE=$(echo "$LOGS" | grep -iE "Listening on|Rails application started" | tail -1)
      return 0  # Success
    fi
    
    if echo "$LOGS" | grep -qiE "NameError|NoMethodError|SyntaxError|uninitialized constant"; then
      LAST_ERROR=$(echo "$LOGS" | grep -iE "NameError|NoMethodError|SyntaxError|uninitialized constant" | tail -1)
      return 2  # Error
    fi
    
    LAST_LINE=$(echo "$LOGS" | tail -1)
    echo "   Status: ${LAST_LINE:0:80}..."
    return 1  # In progress
  fi
  
  echo "   ⏳ Waiting for logs..."
  return 1  # In progress
}

# Main monitoring loop
while true; do
  check_deployment
  STATUS=$?
  
  case $STATUS in
    0)
      # Success!
      echo ""
      echo "════════════════════════════════════════════════════"
      echo "✅ ✅ ✅ DEPLOYMENT SUCCESSFUL! ✅ ✅ ✅"
      echo "════════════════════════════════════════════════════"
      echo ""
      echo "Success indicator:"
      echo "   $SUCCESS_MESSAGE"
      echo ""
      echo "📊 Deployment Statistics:"
      echo "   Total checks: $CHECK_COUNT"
      echo "   Completed at: $(date +'%Y-%m-%d %H:%M:%S')"
      echo ""
      echo "✅ Your application is now running successfully!"
      echo ""
      exit 0
      ;;
    2)
      # Error detected
      echo ""
      echo "⚠️  ERROR DETECTED:"
      echo "   $LAST_ERROR"
      echo ""
      echo "⏳ Waiting for fix deployment... (will continue monitoring)"
      ;;
  esac
  
  # Wait before next check
  sleep 10
done

