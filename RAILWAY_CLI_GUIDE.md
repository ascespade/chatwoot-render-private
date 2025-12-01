# 🚂 Railway CLI Guide

Since you've successfully linked your Railway project, you can now use the Railway CLI for easier automation!

## ✅ Project Status

Your project is linked:
- **Project ID**: `b4f33d17-b8cf-462b-821d-bba048134555`
- **Project Name**: `chatwoot-private`
- **Environment**: `production`
- **Service**: `chatwoot-render-private`

## 🛠️ Railway CLI Commands

### View Logs
```bash
# View logs for all services
railway logs

# View logs for specific service
railway logs --service chatwoot-render-private

# Follow logs in real-time
railway logs --tail 200

# Save logs to file
railway logs --tail 500 > logs.txt
```

### Environment Variables
```bash
# View all environment variables
railway variables

# View for specific service
railway variables --service chatwoot-render-private

# Set environment variable
railway variables set KEY=value

# Remove environment variable
railway variables unset KEY
```

### Deploy
```bash
# Deploy current directory
railway up

# Deploy specific service
railway up --service chatwoot-render-private
```

### Status
```bash
# Check project status
railway status

# View environment info
railway environment
```

## 📝 Helper Scripts

### Using Railway CLI (Easier)
```bash
# Get logs using CLI
bash tools/railway/get_logs_cli.sh

# Get environment variables using CLI
bash tools/railway/get_envs_cli.sh

# Verify Railway setup
bash verify-railway-setup.sh
```

### Using API (If CLI not available)
```bash
# Get logs via API
bash tools/railway/get_logs.sh <SERVICE_ID>

# Get services via API
bash tools/railway/get_services.sh

# Test connection
bash test-railway-connection.sh
```

## 🎯 Recommended Workflow

### Option 1: Use Railway CLI (Recommended)
```bash
# View logs in real-time
railway logs --tail 200

# Check environment variables
railway variables

# Deploy changes
railway up
```

### Option 2: Use Helper Scripts
```bash
# Get logs (uses CLI if available, falls back to API)
bash tools/railway/get_logs_cli.sh chatwoot-render-private 200

# Get environment variables
bash tools/railway/get_envs_cli.sh chatwoot-render-private
```

### Option 3: Use API Directly
```bash
source .env
bash tools/railway/get_logs.sh <SERVICE_ID> 200
```

## 🔄 Log Watcher with Railway CLI

Since you have Railway CLI, you can use a simpler log watcher:

```bash
# Watch logs in real-time
railway logs --tail 0 -f

# Or save to file continuously
while true; do
  railway logs --tail 200 > dev_logs/web.log
  sleep 3
done
```

## ✅ Quick Verification

Run this to verify everything is set up:
```bash
bash verify-railway-setup.sh
```

This will:
1. Check if Railway CLI is installed
2. Show current project status
3. Display project information
4. Fall back to API if CLI not available

---

**Your project is ready!** Use `railway logs` to view logs or `railway up` to deploy.

