# 🚀 Start Deployment Monitoring

## Quick Command

Run this to continuously monitor until deployment succeeds:

```bash
bash monitor-until-success.sh
```

## What It Does

✅ **Reads BUILD logs** - Shows build, install, compile progress  
✅ **Reads DEPLOYMENT logs** - Shows runtime, Rails startup, Puma  
✅ **Monitors both phases** - Tracks build → deployment → success  
✅ **Handles empty logs** - Normal when new deployment starts  
✅ **Detects errors** - Shows build or deployment errors immediately  
✅ **Exits on success** - Stops when deployment succeeds  

## How It Works

The script reads Railway logs and separates them into two phases:

### 📦 BUILD Phase
- Installing dependencies
- Building assets
- Running migrations
- Compiling code

### 🚀 DEPLOYMENT Phase  
- Starting Container
- Booting Rails
- Starting Puma server
- Application ready

## Expected Behavior

### 1. Initial State (Empty Logs)
```
📦 BUILD Phase: Waiting for logs to start...
🚀 DEPLOYMENT Phase: Waiting for build to complete...
```
**This is normal!** New deployments start with empty logs.

### 2. Build Phase
```
📦 BUILD Phase:
   ⏳ Build in progress...
      Installing dependencies...
      Setting up packages...
```
**Building is in progress.**

### 3. Build Complete → Deployment Starting
```
📦 BUILD Phase:
   ✅ Build completed successfully

🚀 DEPLOYMENT Phase:
   ⏳ Deployment in progress...
      Starting Container
      Booting Rails...
```
**Build done, deployment starting.**

### 4. Success! 🎉
```
📦 BUILD Phase:
   ✅ Build completed successfully

🚀 DEPLOYMENT Phase:
   ✅ ✅ ✅ DEPLOYMENT SUCCESSFUL! ✅ ✅ ✅

   Success indicators found:
      ✓ => Rails application started in production
      ✓ Listening on tcp://0.0.0.0:3000

✅ Application is running successfully!
```

## Usage

```bash
# Start monitoring (will run until success)
bash monitor-until-success.sh

# Or run in background
bash monitor-until-success.sh > monitor.log 2>&1 &
```

## Stop Monitoring

Press `Ctrl+C` to stop at any time.

## What Gets Monitored

### Build Logs Include:
- Package installation (npm, yarn, bundle)
- Dependency downloads
- Asset compilation
- Database migrations
- Build completion status

### Deployment Logs Include:
- Container startup
- Rails initialization
- Puma server boot
- Application ready status
- Runtime errors (if any)

---

**Ready!** Run `bash monitor-until-success.sh` now to start monitoring! 🚀
