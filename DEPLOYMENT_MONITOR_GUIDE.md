# 🚀 Railway Deployment Monitor

Scripts to continuously monitor Railway deployments until they succeed.

## 📋 Available Scripts

### 1. Monitor Deployment (CLI) - Recommended
```bash
bash monitor-deployment-cli.sh
```

**Features:**
- Uses Railway CLI (faster and more reliable)
- Checks logs every 10 seconds
- Detects success indicators (Puma starting, Rails started, etc.)
- Detects errors in real-time
- Shows progress and latest log lines
- Exits automatically when deployment succeeds

### 2. Monitor Deployment (API Fallback)
```bash
bash monitor-deployment.sh
```

**Features:**
- Uses Railway API if CLI not available
- Checks deployment status via API
- Falls back to log checking
- Same monitoring behavior

## 🎯 Success Indicators

The monitor looks for these success indicators:
- ✅ "Listening on" - Server started
- ✅ "Puma starting" - Puma server booting
- ✅ "Rails application started" - Rails fully loaded
- ✅ "booted" - Application booted
- ✅ "started in production" - Production mode active

## ⚠️ Error Detection

The monitor also detects these errors:
- ❌ "error", "Error", "ERROR"
- ❌ "Exception"
- ❌ "failed", "Failed"
- ❌ "crash"
- ❌ "NameError", "NoMethodError"
- ❌ "Exiting"

## 📊 Usage

### Basic Monitoring
```bash
bash monitor-deployment-cli.sh
```

This will:
1. Check logs every 10 seconds
2. Show progress updates
3. Exit when deployment succeeds
4. Display errors if found

### Run in Background
```bash
bash monitor-deployment-cli.sh > deployment-monitor.log 2>&1 &
```

### Check Status Manually
```bash
railway logs --tail 50
```

## 🔄 Integration with AutoFix Mode

After deployment succeeds, you can:
1. Open `dev_logs/web.log` in Cursor
2. AutoFix Mode will detect any errors
3. Automatically suggest fixes

## 📝 Example Output

```
🚂 Monitoring Railway Deployment (CLI Mode)...
════════════════════════════════════════════════════

Will check logs every 10 seconds until deployment succeeds
Press Ctrl+C to stop monitoring

════════════════════════════════════════════════════

[2025-12-01 06:15:00] Check #1 - Fetching recent logs...
   Latest: Booting Rails server...

[2025-12-01 06:15:10] Check #2 - Fetching recent logs...
   Latest: Loading application...

[2025-12-01 06:15:20] Check #3 - Fetching recent logs...
   Latest: => Booting Puma

════════════════════════════════════════════════════
✅ DEPLOYMENT SUCCESSFUL!
════════════════════════════════════════════════════

Success indicator found:
   => Rails application started in production

Deployment completed at: 2025-12-01 06:15:30
Total checks: 3
```

## 🛑 Stopping the Monitor

Press `Ctrl+C` to stop monitoring at any time.

## ✨ Tips

1. **Let it run**: The monitor will automatically exit on success
2. **Check logs**: If errors appear, monitor will show them
3. **AutoFix ready**: Once successful, logs are ready for AutoFix Mode
4. **Background mode**: Run in background if you need terminal access

---

**Ready to monitor!** Run `bash monitor-deployment-cli.sh` to start. 🚀

