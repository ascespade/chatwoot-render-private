#!/bin/bash

#
# Enterprise Theme Build Script
# 
# This script rebuilds assets with enterprise theme and branding applied.
# Run this after making changes to enterprise configuration or theme files.
#

set -e

echo "🎨 Applying Enterprise Theme..."

# Check if we're in the project root
if [ ! -f "package.json" ]; then
  echo "❌ Error: Must run from project root directory"
  exit 1
fi

# Check if node_modules exists
if [ ! -d "node_modules" ]; then
  echo "📦 Installing dependencies..."
  npm install
fi

# Clean previous builds
echo "🧹 Cleaning previous builds..."
rm -rf public/vite/.vite 2>/dev/null || true
rm -rf public/vite/assets 2>/dev/null || true

# Build assets
echo "🔨 Building assets with enterprise theme..."
npm run build

# Check if build was successful
if [ $? -eq 0 ]; then
  echo "✅ Enterprise theme applied successfully!"
  echo ""
  echo "📝 Next steps:"
  echo "   1. Restart your Rails server"
  echo "   2. Clear browser cache"
  echo "   3. Refresh the application"
else
  echo "❌ Build failed. Please check the errors above."
  exit 1
fi

