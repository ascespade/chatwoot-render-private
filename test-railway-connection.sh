#!/bin/bash
# Test Railway API connection and show results

source .env 2>/dev/null || {
  echo "❌ Error: .env file not found. Run setup-railway-automation.sh first."
  exit 1
}

echo "🔍 Testing Railway Connection..."
echo ""
echo "════════════════════════════════════════════════════"
echo "📋 Railway Credentials:"
echo "════════════════════════════════════════════════════"
echo ""
echo "🔑 Railway Token:"
echo "   $RAILWAY_TOKEN"
echo ""
echo "🆔 Project ID:"
echo "   $RAILWAY_PROJECT_ID"
echo ""
echo "════════════════════════════════════════════════════"
echo ""

# Check if Railway CLI is available and project is linked
if command -v railway &> /dev/null; then
  echo "✅ Railway CLI detected - checking project link..."
  railway status > /dev/null 2>&1
  if [ $? -eq 0 ]; then
    echo "✅ Project is linked via Railway CLI!"
    echo ""
    echo "Current Railway project status:"
    railway status 2>/dev/null | head -10
    echo ""
    echo "✅ Using Railway CLI - connection verified!"
    echo "   You can use: railway logs, railway variables, railway up"
    exit 0
  fi
fi

echo ""

echo "📡 Testing Railway API access..."
echo ""

# Test using Railway GraphQL API v2 with correct queries
echo "Test 1: Verifying token with Railway GraphQL API..."
PROJECTS_QUERY='{"query":"query { projects { edges { node { id name createdAt } } } }"}'
PROJECTS_RESPONSE=$(curl -s -w "\nHTTP_CODE:%{http_code}" -X POST \
  -H "Authorization: Bearer $RAILWAY_TOKEN" \
  -H "Content-Type: application/json" \
  -d "$PROJECTS_QUERY" \
  "https://backboard.railway.app/graphql/v2")

PROJECTS_HTTP_CODE=$(echo "$PROJECTS_RESPONSE" | grep "HTTP_CODE" | cut -d: -f2)
PROJECTS_BODY=$(echo "$PROJECTS_RESPONSE" | sed '/HTTP_CODE/d')

echo "   Endpoint: https://backboard.railway.app/graphql/v2"
echo "   HTTP Status: $PROJECTS_HTTP_CODE"
echo ""

if [ "$PROJECTS_HTTP_CODE" = "200" ]; then
  # Check if we got data or errors
  if echo "$PROJECTS_BODY" | grep -q "\"errors\""; then
    echo "   ⚠️  API returned errors:"
    if command -v python &> /dev/null; then
      echo "$PROJECTS_BODY" | python -m json.tool 2>/dev/null | grep -A 5 "errors" | head -20
    elif command -v python3 &> /dev/null; then
      echo "$PROJECTS_BODY" | python3 -m json.tool 2>/dev/null | grep -A 5 "errors" | head -20
    else
      echo "$PROJECTS_BODY" | head -30
    fi
    TOKEN_VALID=false
  else
    echo "   ✅ Token is valid! Fetching your projects..."
    echo ""
    echo "   Your Railway Projects:"
    echo "   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    if command -v python &> /dev/null; then
      echo "$PROJECTS_BODY" | python -m json.tool 2>/dev/null | head -100
    elif command -v python3 &> /dev/null; then
      echo "$PROJECTS_BODY" | python3 -m json.tool 2>/dev/null | head -100
    else
      echo "$PROJECTS_BODY" | head -100
    fi
    
    echo ""
    echo "   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "   🔍 Checking if project ID '$RAILWAY_PROJECT_ID' exists..."
    if echo "$PROJECTS_BODY" | grep -q "$RAILWAY_PROJECT_ID"; then
      echo "   ✅ Project ID '$RAILWAY_PROJECT_ID' FOUND in your projects!"
      PROJECT_FOUND=true
    else
      echo "   ⚠️  Project ID '$RAILWAY_PROJECT_ID' NOT found in the projects list"
      echo ""
      echo "   Please find your project ID from the list above and update .env file:"
      echo "   RAILWAY_PROJECT_ID=your_actual_project_id_here"
      PROJECT_FOUND=false
    fi
    TOKEN_VALID=true
  fi
else
  echo "   ❌ Failed to connect to Railway API"
  echo "   Response: $PROJECTS_BODY"
  TOKEN_VALID=false
  PROJECT_FOUND=false
fi

echo ""
echo "════════════════════════════════════════════════════"
echo "📊 Verification Summary:"
echo "════════════════════════════════════════════════════"
echo ""

if [ "$TOKEN_VALID" = true ]; then
  echo "✅ Token Status: VALID"
  echo "   Your Railway API token is working correctly"
else
  echo "❌ Token Status: INVALID or ERROR"
  echo "   Please check your Railway token in Railway Dashboard"
fi

echo ""

if [ "$PROJECT_FOUND" = true ]; then
  echo "✅ Project ID Status: VERIFIED"
  echo "   Project ID '$RAILWAY_PROJECT_ID' exists in your account"
  echo ""
  echo "🎉 All credentials are correct! You can now use the Railway tools."
else
  echo "❌ Project ID Status: NOT FOUND"
  echo "   Project ID '$RAILWAY_PROJECT_ID' was not found"
  echo "   Please update .env file with the correct project ID from the list above"
fi

echo ""
echo "════════════════════════════════════════════════════"
