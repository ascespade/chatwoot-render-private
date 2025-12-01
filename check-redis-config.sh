#!/bin/bash
# Quick script to check Redis configuration status

echo "🔍 Checking Redis Configuration"
echo "════════════════════════════════════════════════════"
echo ""

source .env 2>/dev/null || {
  echo "⚠️  .env file not found - checking environment..."
}

if command -v railway &> /dev/null; then
  echo "📡 Checking Railway environment variables..."
  echo ""
  
  # Try to get environment variables from Railway
  ENV_VARS=$(railway variables 2>/dev/null)
  
  if [ $? -eq 0 ] && [ ! -z "$ENV_VARS" ]; then
    if echo "$ENV_VARS" | grep -qiE "REDIS_URL|REDIS"; then
      echo "✅ Redis environment variables found in Railway:"
      echo "$ENV_VARS" | grep -iE "REDIS_URL|REDIS" | head -5 | sed 's/^/   /'
    else
      echo "❌ No REDIS_URL or Redis-related environment variables found"
      echo ""
      echo "⚠️  ACTION REQUIRED:"
      echo "   1. Go to Railway Dashboard"
      echo "   2. Add Redis service: + New → Database → Redis"
      echo "   3. Add REDIS_URL environment variable to web service"
    fi
  else
    echo "⚠️  Could not fetch Railway variables"
    echo "   Please check Railway Dashboard manually"
  fi
else
  echo "⚠️  Railway CLI not found"
  echo ""
  echo "💡 Manual Check Steps:"
  echo "   1. Go to Railway Dashboard"
  echo "   2. Check Services → Is Redis service present?"
  echo "   3. Check web service → Environment Variables → Is REDIS_URL set?"
fi

echo ""
echo "════════════════════════════════════════════════════"
echo ""
echo "Expected Redis configuration:"
echo "   REDIS_URL=redis://[host]:[port]"
echo ""
echo "If Redis is missing, the server will hang during startup!"
echo ""

