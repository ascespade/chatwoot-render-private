# Railway Automation - Quick Start Guide

## 🚀 Quick Setup (3 Steps)

### 1. Run Setup Script

```bash
bash setup-railway-automation.sh
```

This will:
- Create `dev_logs/` directory
- Create `.env` file with Railway credentials
- Make all scripts executable
- Check for dependencies

### 2. Start Log Watcher

```bash
source .env
bash dev_log_watcher.sh
```

Logs will be saved to:
- `dev_logs/web.log` - Web service logs
- `dev_logs/worker.log` - Worker service logs

### 3. Open Logs in Cursor

Open `dev_logs/web.log` in Cursor. AutoFix Mode will automatically:
- 🔍 Detect errors
- ⚙️ Generate fixes
- ✅ Apply patches after approval

## 📋 Railway Configuration

Your Railway credentials:
- **API Token**: Get from Railway Dashboard → Settings → API Tokens
- **Project ID**: Get from Railway Dashboard → Project Settings

⚠️ **Never commit credentials!** They should only be in `.env` file (already in .gitignore).

These are saved in `.env` file (do not commit).

## 🛠️ Available Tools

### Get Services
```bash
bash tools/railway/get_services.sh
```

### Get Logs
```bash
bash tools/railway/get_logs.sh <SERVICE_ID> [LINES]
```

### Get Environment Variables
```bash
bash tools/railway/get_envs.sh <SERVICE_ID>
```

### Auto-Deploy Checker
```bash
bash auto_deploy_check.sh
```

## 🔧 Troubleshooting

**Scripts not executable?**
```bash
chmod +x tools/railway/*.sh dev_log_watcher.sh auto_deploy_check.sh
```

**jq not found?**
- macOS: `brew install jq`
- Ubuntu: `sudo apt-get install jq`
- Windows: `choco install jq`

**Logs not updating?**
- Check if log watcher is running
- Verify Railway service status
- Check `.env` file has correct credentials

## 📚 More Information

See `RAILWAY_AUTOMATION_SETUP.md` for detailed documentation.

## 🔐 Security

⚠️ **Never commit `.env` file** - It contains your Railway API token!

