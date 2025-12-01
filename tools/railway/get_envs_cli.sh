#!/bin/bash
# Get Railway environment variables using Railway CLI

if ! command -v railway &> /dev/null; then
  echo "❌ Railway CLI not installed"
  echo "Install it with: curl -fsSL https://railway.com/install.sh | sh"
  exit 1
fi

SERVICE_NAME=${1:-""}

if [ -z "$SERVICE_NAME" ]; then
  echo "Getting environment variables for current project..."
  railway variables
else
  echo "Getting environment variables for service: $SERVICE_NAME"
  railway variables --service "$SERVICE_NAME"
fi

