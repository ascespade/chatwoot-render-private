#!/bin/bash
# Monitor Railway deployment until it succeeds
# Reads both BUILD logs and DEPLOYMENT logs separately

source .env 2>/dev/null || {
  echo "❌ Error: .env file not found"
  exit 1
}

echo "🚂 Monitoring Railway Deployment (Build + Deploy Logs)"
echo "════════════════════════════════════════════════════"
echo ""
echo "Will check both BUILD and DEPLOYMENT logs"
echo "Empty logs are normal when a new deployment starts"
echo ""
echo "Press Ctrl+C to stop monitoring"
echo "════════════════════════════════════════════════════"
echo ""

# Detect service name (try multiple common names)
SERVICE_NAME=${1:-"chatwoot-render-private"}

CHECK_COUNT=0
BUILD_COMPLETE=false
DEPLOY_SUCCESS=false

# Function to get all logs (tries multiple methods)
get_all_logs() {
  if command -v railway &> /dev/null; then
    # Method 1: Try service-specific logs first
    LOGS=$(railway logs --service "$SERVICE_NAME" --tail 500 2>/dev/null)
    
    # Method 2: If empty, try without service name (gets all logs)
    if [ -z "$LOGS" ] || [ "$(echo "$LOGS" | wc -l)" -lt 5 ]; then
      LOGS=$(railway logs --tail 500 2>/dev/null)
    fi
    
    # Method 3: Try with "web" service name
    if [ -z "$LOGS" ] || [ "$(echo "$LOGS" | wc -l)" -lt 5 ]; then
      LOGS=$(railway logs --service "web" --tail 500 2>/dev/null || railway logs --tail 500 2>/dev/null)
    fi
    
    echo "$LOGS"
  fi
}

while true; do
  CHECK_COUNT=$((CHECK_COUNT + 1))
  TIMESTAMP=$(date +'%H:%M:%S')
  
  echo "[$TIMESTAMP] Check #$CHECK_COUNT"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  
  if command -v railway &> /dev/null; then
    # Get all logs using multiple methods
    ALL_LOGS=$(get_all_logs)
    
    if [ $? -eq 0 ]; then
      # Count non-empty lines
      LOG_LINES=$(echo "$ALL_LOGS" | grep -v '^$' | wc -l)
      
      if [ -z "$ALL_LOGS" ] || [ "$LOG_LINES" -lt 5 ]; then
        echo "📦 BUILD Phase: Waiting for logs to start... ($LOG_LINES lines)"
        echo "🚀 DEPLOYMENT Phase: Waiting for build to complete..."
      else
        echo "   📊 Got $LOG_LINES log lines"
        
        # Extract BUILD logs - match build patterns
        BUILD_LOGS=$(echo "$ALL_LOGS" | grep -iE "Setting up|installing|bundle|npm|yarn|pnpm|railway|nixpacks|compiling|building|Building|Installing|Downloading|Fetching|apt-get|dpkg|rbenv|ruby|gem install|vite|transforming|rendering chunks|Bundle complete|built in" || echo "")
        
        # Extract DEPLOYMENT logs - IMPORTANT: Don't filter out "Starting Container", "Loading Installation", etc.
        # These are runtime/deployment logs, not build logs
        DEPLOY_LOGS=$(echo "$ALL_LOGS" | grep -v -iE "Setting up|installing|bundle|npm|yarn|pnpm|railway|nixpacks|compiling|building|Building|Installing|Downloading|Fetching|apt-get|dpkg|rbenv|ruby|gem install|vite|transforming|rendering chunks" || echo "$ALL_LOGS")
        
        # Actually, let's just use ALL_LOGS and check for deployment patterns
        # Check BUILD phase
        echo "📦 BUILD Phase:"
        if [ ! -z "$BUILD_LOGS" ]; then
          # Check if build completed
          if echo "$ALL_LOGS" | grep -qiE "built in|Bundle complete|Done in|build.*complete|build.*succeeded|Successfully built"; then
            BUILD_COMPLETE=true
            echo "   ✅ Build completed successfully"
            echo "$ALL_LOGS" | grep -iE "built in|Bundle complete|Done in|build.*complete" | tail -1 | sed 's/^/      ✓ /'
          elif echo "$BUILD_LOGS" | grep -qiE "error|Error|ERROR|failed|Failed|FAILED|exit code|Exit code|fatal:"; then
            BUILD_ERROR=$(echo "$BUILD_LOGS" | grep -iE "error|failed|exit code|fatal" | tail -1 | head -c 120)
            echo "   ❌ Build error detected: ${BUILD_ERROR}..."
          else
            echo "   ⏳ Build in progress..."
            BUILD_LATEST=$(echo "$BUILD_LOGS" | tail -2 | head -1)
            if [ ! -z "$BUILD_LATEST" ]; then
              echo "      Latest: ${BUILD_LATEST:0:80}..."
            fi
          fi
        else
          # Check if we're past build phase (deployment has started)
          if echo "$ALL_LOGS" | grep -qiE "Starting Container|Loading Installation|ConfigLoader|Booting|Rails"; then
            BUILD_COMPLETE=true
            echo "   ✅ Build phase completed (deployment started)"
          else
            if [ ! -z "$ALL_LOGS" ]; then
              FIRST_LINES=$(echo "$ALL_LOGS" | head -3 | grep -v '^$')
              if [ ! -z "$FIRST_LINES" ]; then
                echo "   🔍 Latest log activity:"
                echo "$FIRST_LINES" | sed 's/^/      /'
              else
                echo "   ⏳ Waiting for build logs..."
              fi
            else
              echo "   ⏳ Waiting for build logs..."
            fi
          fi
        fi
        
        # Check DEPLOYMENT phase - FIXED to show "Starting Container", "Loading Installation", etc.
        echo ""
        echo "🚀 DEPLOYMENT Phase:"
        
        # Check for deployment logs (Starting Container, Loading Installation config, etc.)
        if echo "$ALL_LOGS" | grep -qiE "Starting Container|Loading Installation|ConfigLoader|Auto-SuperAdmin|Booting|Rails|Puma|Listening"; then
          # Check for success indicators
          if echo "$ALL_LOGS" | grep -qiE "Listening on tcp://|Rails application started in production|started in production mode|=> Booting Puma|=> Rails.*application starting in production|Puma starting in.*mode"; then
            DEPLOY_SUCCESS=true
            echo "   ✅ ✅ ✅ DEPLOYMENT SUCCESSFUL! ✅ ✅ ✅"
            echo ""
            echo "   Success indicators found:"
            echo "$ALL_LOGS" | grep -iE "Listening on|Rails application started|started in production|Booting Puma" | tail -3 | sed 's/^/      ✓ /'
            echo ""
            echo "   Latest deployment logs:"
            echo "$ALL_LOGS" | tail -10 | grep -v -iE "Setting up|installing|bundle|npm|yarn|railway|nixpacks|transforming|rendering" | tail -5 | sed 's/^/      /'
            
            echo ""
            echo "════════════════════════════════════════════════════"
            echo "✅ ✅ ✅ DEPLOYMENT SUCCESSFUL! ✅ ✅ ✅"
            echo "════════════════════════════════════════════════════"
            echo ""
            echo "📊 Deployment Summary:"
            echo "   Total checks: $CHECK_COUNT"
            echo "   Build phase: ✅ Complete"
            echo "   Deployment phase: ✅ Success"
            echo "   Completed at: $(date +'%Y-%m-%d %H:%M:%S')"
            echo ""
            echo "✅ Application is running successfully!"
            echo ""
            exit 0
          fi
          
          # Show deployment progress (Starting Container, Loading Installation, etc.)
          echo "   ⏳ Deployment in progress..."
          
          # Show latest deployment activity
          DEPLOY_ACTIVITY=$(echo "$ALL_LOGS" | grep -iE "Starting Container|Loading Installation|ConfigLoader|Auto-SuperAdmin|Booting|Rails|Processing|INFO" | tail -5)
          if [ ! -z "$DEPLOY_ACTIVITY" ]; then
            echo ""
            echo "   📝 Latest deployment activity:"
            echo "$DEPLOY_ACTIVITY" | sed 's/^/      /'
          fi
          
          # Check for deployment errors
          if echo "$ALL_LOGS" | grep -qiE "NameError|NoMethodError|SyntaxError|uninitialized constant|Exiting|failed to start|Cannot find|not found|Error|ERROR"; then
            DEPLOY_ERROR=$(echo "$ALL_LOGS" | grep -iE "NameError|NoMethodError|SyntaxError|uninitialized constant|failed to start|Error|ERROR" | tail -1 | head -c 120)
            echo ""
            echo "   ⚠️  Deployment error detected: ${DEPLOY_ERROR}..."
          fi
          
        else
          echo "   ⏸️  Waiting for deployment phase to start..."
          # Show what we have
          if [ ! -z "$ALL_LOGS" ]; then
            echo ""
            echo "   Current logs (last 3 lines):"
            echo "$ALL_LOGS" | tail -3 | sed 's/^/      /'
          fi
        fi
      fi
    else
      echo "⚠️  Could not fetch logs, retrying..."
    fi
  else
    # Fallback: Check log file
    if [ -f "dev_logs/web.log" ] && [ -s "dev_logs/web.log" ]; then
      ALL_LOGS=$(tail -200 dev_logs/web.log 2>/dev/null)
      if echo "$ALL_LOGS" | grep -qiE "Listening on|Rails application started|started in production"; then
        echo ""
        echo "✅ ✅ ✅ DEPLOYMENT SUCCESSFUL! ✅ ✅ ✅"
        echo ""
        exit 0
      fi
      LAST_LINE=$(echo "$ALL_LOGS" | tail -1)
      echo "Latest from log file: ${LAST_LINE:0:80}..."
    else
      echo "📦 BUILD Phase: Waiting for logs..."
      echo "🚀 DEPLOYMENT Phase: Waiting for build..."
      echo ""
      echo "   💡 Tip: Run 'bash dev_log_watcher_cli.sh' in another terminal"
    fi
  fi
  
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "   ⏳ Waiting 10 seconds before next check..."
  echo ""
  
  sleep 10
done
