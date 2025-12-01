#!/bin/bash
mkdir -p dev_logs

SERVICES=$(curl -s -X GET -H "Authorization: Bearer $RAILWAY_TOKEN" "https://backboard.railway.app/v2/projects/$RAILWAY_PROJECT_ID/services")
WEB_ID=$(echo $SERVICES | jq -r '.services[] | select(.name | test("web"; "i")) | .id')
WORKER_ID=$(echo $SERVICES | jq -r '.services[] | select(.name | test("worker"; "i")) | .id')

while true; do
  if [ ! -z "$WEB_ID" ]; then
    curl -s -X GET -H "Authorization: Bearer $RAILWAY_TOKEN" "https://backboard.railway.app/v2/services/$WEB_ID/logs?lines=200" > dev_logs/web.log
  fi
  if [ ! -z "$WORKER_ID" ]; then
    curl -s -X GET -H "Authorization: Bearer $RAILWAY_TOKEN" "https://backboard.railway.app/v2/services/$WORKER_ID/logs?lines=200" > dev_logs/worker.log
  fi
  sleep 3
done

