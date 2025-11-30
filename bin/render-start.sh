#!/usr/bin/env bash
set -euo pipefail
echo "🚀 Starting Chatwoot on Render"
bundle exec rails db:migrate
bundle exec rails ip_lookup:setup || echo "Skipping IP lookup"
PORT="${PORT:-3000}"
exec bundle exec rails server -b 0.0.0.0 -p $PORT

