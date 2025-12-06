#!/bin/bash
# Build and test Docker image locally before deploying to Railway

set -e

echo "🔨 Building Docker image locally..."
echo ""

# Build the image
docker build -f docker/Dockerfile.railway -t chatwoot-local:latest .

echo ""
echo "✅ Build completed successfully!"
echo ""
echo "📦 Image size:"
docker images chatwoot-local:latest --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}"
echo ""
echo "🧪 To test the image locally, run:"
echo "   docker run -p 3000:3000 --env-file .env.local chatwoot-local:latest"
echo ""
echo "💡 Note: Make sure you have a .env.local file with required environment variables"

