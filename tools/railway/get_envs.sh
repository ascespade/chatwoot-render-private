#!/bin/bash
SERVICE_ID=$1

curl -s -X GET \
  -H "Authorization: Bearer $RAILWAY_TOKEN" \
  -H "Content-Type: application/json" \
  "https://backboard.railway.app/v2/services/$SERVICE_ID/variables"

