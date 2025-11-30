#!/usr/bin/env bash
set -euo pipefail
echo "🚀 Render build start"

# Increase Node.js memory limit to avoid OOM during Vite build
export NODE_OPTIONS="--max-old-space-size=6144"

bundle config set without 'development test'
bundle install --jobs=4 --retry=3

# Install pnpm@9 to match package.json engines requirement
if command -v corepack >/dev/null 2>&1; then
  corepack enable
  corepack prepare pnpm@9 --activate
else
  npm install -g pnpm@9
fi

pnpm install --frozen-lockfile
bundle exec rake assets:precompile

# Build Vite (Rails handles production mode automatically)
bundle exec vite build

echo "✅ Build finished"

