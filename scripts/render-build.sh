#!/usr/bin/env bash
set -euo pipefail
echo "🚀 Render build start"
bundle config set without 'development test'
bundle install --jobs=4 --retry=3
if command -v corepack >/dev/null 2>&1; then
  corepack enable
  corepack prepare pnpm@10 --activate
else
  npm install -g pnpm@10
fi
pnpm install --frozen-lockfile
bundle exec rake assets:precompile
bundle exec vite build
echo "✅ Build finished"

