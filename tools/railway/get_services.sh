#!/bin/bash
curl -s -X GET \
  -H "Authorization: Bearer $RAILWAY_TOKEN" \
  -H "Content-Type: application/json" \
  "https://backboard.railway.app/v2/projects/$RAILWAY_PROJECT_ID/services"

