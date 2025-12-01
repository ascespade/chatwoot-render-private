#!/bin/bash
while true; do
  STATUS=$(curl -s -X GET -H "Authorization: Bearer $RAILWAY_TOKEN" "https://backboard.railway.app/v2/projects/$RAILWAY_PROJECT_ID/deployments" | jq -r '.deployments[0].status')
  echo "Deployment Status: $STATUS"
  if [ "$STATUS" = "SUCCESS" ]; then
    echo "Deployment completed. Bot will re-check logs." 
  fi
  sleep 5
done

