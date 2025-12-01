#!/bin/bash
# Get Railway logs using Railway CLI (much easier than API)

if ! command -v railway &> /dev/null; then
  echo "❌ Railway CLI not installed"
  echo "Install it with: curl -fsSL https://railway.com/install.sh | sh"
  exit 1
fi

SERVICE_NAME=${1:-""}
LINES=${2:-200}

if [ -z "$SERVICE_NAME" ]; then
  echo "Fetching logs for all services..."
  railway logs --tail "$LINES"
else
  echo "Fetching logs for service: $SERVICE_NAME"
  railway logs --service "$SERVICE_NAME" --tail "$LINES"
fi

