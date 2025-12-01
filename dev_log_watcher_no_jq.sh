#!/bin/bash
# Alternative log watcher that doesn't require jq
# Uses Python or basic grep to extract service IDs

mkdir -p dev_logs

echo "🔍 Detecting Railway services..."

# Get services
SERVICES=$(curl -s -X GET -H "Authorization: Bearer $RAILWAY_TOKEN" "https://backboard.railway.app/v2/projects/$RAILWAY_PROJECT_ID/services")

# Try Python first for JSON parsing, then fallback to grep
if command -v python &> /dev/null; then
  WEB_ID=$(echo "$SERVICES" | python -c "import sys, json; data = json.load(sys.stdin); services = data.get('services', []); web = [s['id'] for s in services if 'web' in s.get('name', '').lower()]; print(web[0] if web else '')" 2>/dev/null)
  WORKER_ID=$(echo "$SERVICES" | python -c "import sys, json; data = json.load(sys.stdin); services = data.get('services', []); worker = [s['id'] for s in services if 'worker' in s.get('name', '').lower()]; print(worker[0] if worker else '')" 2>/dev/null)
elif command -v python3 &> /dev/null; then
  WEB_ID=$(echo "$SERVICES" | python3 -c "import sys, json; data = json.load(sys.stdin); services = data.get('services', []); web = [s['id'] for s in services if 'web' in s.get('name', '').lower()]; print(web[0] if web else '')" 2>/dev/null)
  WORKER_ID=$(echo "$SERVICES" | python3 -c "import sys, json; data = json.load(sys.stdin); services = data.get('services', []); worker = [s['id'] for s in services if 'worker' in s.get('name', '').lower()]; print(worker[0] if worker else '')" 2>/dev/null)
else
  echo "⚠️  Warning: Python not found. Please install Python or jq for service detection."
  echo "You can manually set WEB_ID and WORKER_ID environment variables."
  exit 1
fi

if [ -z "$WEB_ID" ] && [ -z "$WORKER_ID" ]; then
  echo "❌ Could not detect web or worker services."
  echo "Available services:"
  echo "$SERVICES"
  echo ""
  echo "Please set WEB_ID and/or WORKER_ID manually:"
  echo "  export WEB_ID=<your-web-service-id>"
  echo "  export WORKER_ID=<your-worker-service-id>"
  exit 1
fi

[ ! -z "$WEB_ID" ] && echo "✅ Found web service: ${WEB_ID:0:20}..."
[ ! -z "$WORKER_ID" ] && echo "✅ Found worker service: ${WORKER_ID:0:20}..."

echo "📥 Starting log watcher (press Ctrl+C to stop)..."
echo ""

while true; do
  if [ ! -z "$WEB_ID" ]; then
    curl -s -X GET -H "Authorization: Bearer $RAILWAY_TOKEN" "https://backboard.railway.app/v2/services/$WEB_ID/logs?lines=200" > dev_logs/web.log 2>/dev/null
    echo "[$(date +'%H:%M:%S')] ✅ Updated web.log"
  fi
  if [ ! -z "$WORKER_ID" ]; then
    curl -s -X GET -H "Authorization: Bearer $RAILWAY_TOKEN" "https://backboard.railway.app/v2/services/$WORKER_ID/logs?lines=200" > dev_logs/worker.log 2>/dev/null
    echo "[$(date +'%H:%M:%S')] ✅ Updated worker.log"
  fi
  sleep 3
done

