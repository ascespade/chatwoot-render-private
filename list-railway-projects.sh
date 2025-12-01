#!/bin/bash
# List all Railway projects to find the correct project ID

source .env 2>/dev/null || {
  echo "❌ Error: .env file not found. Run setup-railway-automation.sh first."
  exit 1
}

echo "🔍 Listing Your Railway Projects..."
echo ""
echo "════════════════════════════════════════════════════"
echo "🔑 Using Railway Token:"
echo "   $RAILWAY_TOKEN"
echo "════════════════════════════════════════════════════"
echo ""

# Try Railway REST API first
echo "Trying Railway REST API..."
REST_RESPONSE=$(curl -s -X GET \
  -H "Authorization: Bearer $RAILWAY_TOKEN" \
  -H "Content-Type: application/json" \
  "https://api.railway.app/v1/projects" 2>&1)

echo "Response: $REST_RESPONSE" | head -50
echo ""

# Try GraphQL API
echo "Trying Railway GraphQL API..."
GRAPHQL_QUERY='{"query":"query { projects { edges { node { id name createdAt } } } }"}'
GRAPHQL_RESPONSE=$(curl -s -X POST \
  -H "Authorization: Bearer $RAILWAY_TOKEN" \
  -H "Content-Type: application/json" \
  -d "$GRAPHQL_QUERY" \
  "https://backboard.railway.app/graphql/v2" 2>&1)

echo "Full GraphQL Response:"
echo "$GRAPHQL_RESPONSE"
echo ""

# Try alternative GraphQL endpoint
echo "Trying alternative GraphQL endpoint..."
ALT_QUERY='{"query":"{ projects { id name } }"}'
ALT_RESPONSE=$(curl -s -X POST \
  -H "Authorization: Bearer $RAILWAY_TOKEN" \
  -H "Content-Type: application/json" \
  -d "$ALT_QUERY" \
  "https://railway.app/graphql/v2" 2>&1)

echo "Alternative endpoint response:"
echo "$ALT_RESPONSE" | head -50

echo ""
echo "════════════════════════════════════════════════════"
echo "💡 Tips:"
echo "   1. Copy the project ID from Railway Dashboard → Project Settings"
echo "   2. Update .env file with: RAILWAY_PROJECT_ID=your_project_id"
echo "   3. Your token starts with: ${RAILWAY_TOKEN:0:20}..."
echo "════════════════════════════════════════════════════"

