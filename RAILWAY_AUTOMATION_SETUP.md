# Railway Automation Setup

Complete setup for Railway tools, log watcher, auto-fix mode, and auto-deploy check.

## Files Created

1. **Railway API Tools** (`tools/railway/`):
   - `get_services.sh` - Get list of Railway services
   - `get_logs.sh` - Fetch logs from a service
   - `get_envs.sh` - Fetch environment variables from a service

2. **Automation Scripts**:
   - `dev_log_watcher.sh` - Continuously watches and downloads Railway logs
   - `auto_deploy_check.sh` - Monitors deployment status

3. **Configuration Files**:
   - `tools.json` - Cursor tools configuration
   - `cursor-autofix.json` - AutoFix mode configuration

## Setup Instructions

### 1. Environment Variables

Create a `.env` file in the project root with:

```bash
RAILWAY_TOKEN=your_railway_token_here
RAILWAY_PROJECT_ID=your_project_id_here
```

**Important**: Never commit the `.env` file. It should be in `.gitignore`.

### 2. Make Scripts Executable

```bash
chmod +x tools/railway/*.sh dev_log_watcher.sh auto_deploy_check.sh
```

### 3. Install Dependencies

The scripts require `jq` for JSON parsing:

```bash
# On macOS
brew install jq

# On Ubuntu/Debian
sudo apt-get install jq

# On Windows (Git Bash)
# jq should already be available or install via Chocolatey
```

### 4. Run Log Watcher

Start the log watcher to continuously fetch Railway logs:

```bash
# Load environment variables and start watcher
source .env
bash dev_log_watcher.sh
```

This will:
- Create `dev_logs/` directory
- Automatically detect web and worker services
- Fetch logs every 3 seconds
- Save logs to `dev_logs/web.log` and `dev_logs/worker.log`

### 5. (Optional) Run Auto-Deploy Checker

Monitor deployment status:

```bash
source .env
bash auto_deploy_check.sh
```

### 6. Enable AutoFix Mode

1. Open `dev_logs/web.log` or `dev_logs/worker.log` in Cursor
2. Cursor will automatically detect errors based on `cursor-autofix.json` configuration
3. When errors are found, Cursor will:
   - Analyze the error
   - Generate a patch
   - Ask for permission to apply
   - Commit and wait for deployment
   - Re-check logs

## Manual Tool Usage

### Get Services

```bash
source .env
bash tools/railway/get_services.sh
```

### Get Logs

```bash
source .env
bash tools/railway/get_logs.sh <SERVICE_ID> [LINES]
```

Example:
```bash
bash tools/railway/get_logs.sh abc123def456 500
```

### Get Environment Variables

```bash
source .env
bash tools/railway/get_envs.sh <SERVICE_ID>
```

## AutoFix Mode Features

AutoFix Mode will automatically detect and handle:

- `Error` - General errors
- `Exception` - Exceptions
- `undefined method` - Missing method errors
- `NoMethodError` - Ruby method errors
- `ActiveRecord::` - Database errors
- `RuntimeError` - Runtime errors
- `crashed` - Service crashes
- `ECONNREFUSED` - Connection errors

When an error is detected, AutoFix Mode will:
1. 🔍 Extract error details (file, line, stack trace)
2. ⚙️ Generate a fix patch
3. Ask for permission to apply
4. Commit the fix
5. ⏳ Wait for deployment
6. Re-check logs
7. ✅ Confirm resolution

## Troubleshooting

### Scripts not executable

```bash
chmod +x tools/railway/*.sh dev_log_watcher.sh auto_deploy_check.sh
```

### jq not found

Install jq (see dependencies above)

### Railway API errors

- Verify `RAILWAY_TOKEN` is correct
- Verify `RAILWAY_PROJECT_ID` is correct
- Check Railway API documentation for rate limits

### Log files not updating

- Check if log watcher is running
- Verify service IDs are correct
- Check Railway service status

## Security Notes

⚠️ **Important**: 
- Never commit `.env` file with Railway token
- Keep Railway token secure
- Use environment variables only
- Add `.env` to `.gitignore` if not already there

## Next Steps

1. Start log watcher in a terminal
2. Open `dev_logs/web.log` in Cursor
3. Watch for errors
4. Let AutoFix Mode handle fixes automatically

## Continuous Debug Mode

After setup, you can enter continuous debug mode by:

1. Running the log watcher
2. Opening log files in Cursor
3. Cursor will automatically watch for new errors and suggest fixes

