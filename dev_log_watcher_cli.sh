#!/bin/bash
# Log watcher using Railway CLI (much simpler and more reliable)

if ! command -v railway &> /dev/null; then
  echo "❌ Railway CLI not installed"
  echo "Install it with: curl -fsSL https://railway.com/install.sh | sh"
  echo ""
  echo "Falling back to API-based watcher..."
  source .env 2>/dev/null || {
    echo "❌ Error: .env file not found"
    exit 1
  }
  exec bash dev_log_watcher_no_jq.sh
fi

mkdir -p dev_logs

echo "🚂 Railway Log Watcher (Using Railway CLI)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "📡 Watching logs for project: chatwoot-private"
echo "📁 Saving logs to: dev_logs/"
echo ""
echo "Press Ctrl+C to stop"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Watch logs for web service (most common service name)
SERVICE_NAME=${1:-"chatwoot-render-private"}

while true; do
  # Get logs for the service
  railway logs --service "$SERVICE_NAME" --tail 200 > dev_logs/web.log 2>/dev/null
  
  # Also try to get all logs if service-specific fails
  if [ ! -s dev_logs/web.log ]; then
    railway logs --tail 200 > dev_logs/web.log 2>/dev/null
  fi
  
  echo "[$(date +'%H:%M:%S')] ✅ Updated dev_logs/web.log ($(wc -l < dev_logs/web.log) lines)"
  
  sleep 3
done

