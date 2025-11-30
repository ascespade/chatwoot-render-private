# Render.com Configuration Guide

## Web Service Configuration

### Build Command:
```bash
bash scripts/render-build.sh
```

### Start Command:
```bash
bash bin/render-start.sh
```

### Environment Variables:

Add these environment variables in Render.com dashboard:

| Variable | Value | Description |
|----------|-------|-------------|
| `RAILS_ENV` | `production` | Rails environment |
| `RACK_ENV` | `production` | Rack environment |
| `RAILS_LOG_TO_STDOUT` | `true` | Send logs to stdout for Render |
| `FRONTEND_URL` | `https://your-app.onrender.com` | Replace with your Render app URL |
| `SECRET_KEY_BASE` | `run rails secret` | Generate with: `rails secret` |
| `DATABASE_URL` | `from Render Postgres` | Auto-provided by Render Postgres addon |
| `REDIS_URL` | `from Render Redis` | Auto-provided by Render Redis addon |
| `ENABLE_ACCOUNT_SIGNUP` | `true` | Enable user signups |

### Required Addons:

1. **PostgreSQL Database**
   - Add from Render dashboard
   - DATABASE_URL will be automatically provided

2. **Redis**
   - Add from Render dashboard  
   - REDIS_URL will be automatically provided

## Optional: Sidekiq Worker Service

If you need background job processing, create a separate Worker service:

### Build Command:
```bash
bash scripts/render-build.sh
```

### Start Command:
```bash
bundle exec sidekiq -C config/sidekiq.yml
```

### Environment Variables:
Same as Web Service (above)

---

## Verification Checklist

After deployment, verify:

- [ ] Visit `/installation/onboarding`
- [ ] Should NOT show 'Something went wrong'
- [ ] Vite should not build during runtime (builds during build phase)
- [ ] Dashboard should load after onboarding
- [ ] No timeout errors on first page load

---

## Troubleshooting

### Build Timeout
- Render free tier has 45min build limit
- Ensure all assets precompile during build phase
- Vite builds during build, not runtime

### Database Connection
- Verify DATABASE_URL is set automatically from Postgres addon
- Check Postgres service is running

### Redis Connection
- Verify REDIS_URL is set automatically from Redis addon
- Check Redis service is running

