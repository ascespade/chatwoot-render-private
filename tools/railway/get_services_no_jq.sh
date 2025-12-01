#!/bin/bash
# Alternative version that doesn't require jq - uses grep/sed instead

RESPONSE=$(curl -s -X GET \
  -H "Authorization: Bearer $RAILWAY_TOKEN" \
  -H "Content-Type: application/json" \
  "https://backboard.railway.app/v2/projects/$RAILWAY_PROJECT_ID/services")

# Check if response contains error
if echo "$RESPONSE" | grep -q "error\|Error\|ERROR"; then
  echo "Error fetching services:"
  echo "$RESPONSE"
  exit 1
fi

# Pretty print using Python if available, otherwise raw JSON
if command -v python &> /dev/null; then
  echo "$RESPONSE" | python -m json.tool 2>/dev/null || echo "$RESPONSE"
elif command -v python3 &> /dev/null; then
  echo "$RESPONSE" | python3 -m json.tool 2>/dev/null || echo "$RESPONSE"
else
  echo "$RESPONSE"
fi

