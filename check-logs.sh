#!/bin/bash
# Check all log sources and files

echo "📋 Checking All Log Sources"
echo "════════════════════════════════════════════════════"
echo ""

# Check log files
echo "📁 Log Files:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
if [ -f "dev_logs/web.log" ]; then
  WEB_LINES=$(wc -l < dev_logs/web.log)
  WEB_SIZE=$(du -h dev_logs/web.log | cut -f1)
  echo "✅ dev_logs/web.log: $WEB_LINES lines ($WEB_SIZE)"
  if [ "$WEB_LINES" -gt 0 ]; then
    echo ""
    echo "   Last 5 lines:"
    tail -5 dev_logs/web.log | sed 's/^/      /'
  else
    echo "   ⚠️  File is empty"
  fi
else
  echo "❌ dev_logs/web.log: Not found"
fi

echo ""

if [ -f "dev_logs/worker.log" ]; then
  WORKER_LINES=$(wc -l < dev_logs/worker.log)
  WORKER_SIZE=$(du -h dev_logs/worker.log | cut -f1)
  echo "✅ dev_logs/worker.log: $WORKER_LINES lines ($WORKER_SIZE)"
  if [ "$WORKER_LINES" -gt 0 ]; then
    echo ""
    echo "   Last 5 lines:"
    tail -5 dev_logs/worker.log | sed 's/^/      /'
  else
    echo "   ⚠️  File is empty"
  fi
else
  echo "❌ dev_logs/worker.log: Not found"
fi

echo ""
echo "════════════════════════════════════════════════════"
echo ""

# Check Railway CLI direct logs
if command -v railway &> /dev/null; then
  echo "🚂 Railway CLI Direct Logs:"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  
  SERVICE_NAME=${1:-"chatwoot-render-private"}
  
  echo "Checking service: $SERVICE_NAME"
  echo ""
  
  # Try to get logs
  echo "📦 Build + Deploy Logs (last 20 lines):"
  DIRECT_LOGS=$(railway logs --service "$SERVICE_NAME" --tail 20 2>&1)
  
  if [ $? -eq 0 ] && [ ! -z "$DIRECT_LOGS" ]; then
    echo "$DIRECT_LOGS" | sed 's/^/   /'
    echo ""
    LOG_COUNT=$(echo "$DIRECT_LOGS" | wc -l)
    echo "   ✅ Got $LOG_COUNT lines from Railway CLI"
  else
    echo "   ⚠️  Could not get logs or empty response"
    echo ""
    echo "   Trying without service name..."
    DIRECT_LOGS=$(railway logs --tail 20 2>&1)
    if [ ! -z "$DIRECT_LOGS" ]; then
      echo "$DIRECT_LOGS" | sed 's/^/   /'
      LOG_COUNT=$(echo "$DIRECT_LOGS" | wc -l)
      echo ""
      echo "   ✅ Got $LOG_COUNT lines (without service name)"
    else
      echo "   ❌ No logs available"
    fi
  fi
  
  echo ""
  echo "════════════════════════════════════════════════════"
  echo ""
fi

# Check Railway status
if command -v railway &> /dev/null; then
  echo "🚂 Railway Status:"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  railway status 2>&1 | head -10 | sed 's/^/   /' || echo "   ⚠️  Could not get Railway status"
  echo ""
fi

# Summary
echo "════════════════════════════════════════════════════"
echo "📊 Summary:"
echo "════════════════════════════════════════════════════"
echo ""
if [ -f "dev_logs/web.log" ] && [ -s "dev_logs/web.log" ]; then
  echo "✅ Log files have content"
else
  echo "⚠️  Log files are empty - run 'bash dev_log_watcher_cli.sh' to populate"
fi

if command -v railway &> /dev/null; then
  echo "✅ Railway CLI is available"
else
  echo "❌ Railway CLI not found"
fi

echo ""
echo "💡 Tips:"
echo "   • Run 'bash dev_log_watcher_cli.sh' to continuously update log files"
echo "   • Run 'bash monitor-until-success.sh' to monitor deployment"
echo "   • Use 'railway logs --tail 100' to see latest logs directly"
echo ""

