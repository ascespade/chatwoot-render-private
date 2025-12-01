# Chatwoot Enterprise Mode Upgrade Guide

## Overview

This guide shows how to upgrade a Chatwoot Community Edition instance to Enterprise Mode **without modifying source code**. All changes are made via environment variables, feature flags, and API endpoints, ensuring a safe upgrade path.

## Prerequisites

- ✅ Chatwoot instance with `/enterprise` directory (already present in this repo)
- ✅ Database access (via Rails console or API)
- ✅ Super Admin access to Chatwoot dashboard

## Method 1: Environment Variables + InstallationConfig (Recommended)

### Step 1: Set Pricing Plan Environment Variable

Set the pricing plan to enable enterprise features:

```bash
# Via Railway Environment Variables
INSTALLATION_PRICING_PLAN=enterprise
```

**Note**: You can also set this via InstallationConfig API (see Method 2 below).

### Step 2: Enable Premium Features via InstallationConfig

Premium features are controlled by the `INSTALLATION_PRICING_PLAN` value. When set to `'enterprise'` or `'premium'`, the following features automatically become available:

- ✅ **Disable Branding** (`disable_branding`)
- ✅ **Audit Logs** (`audit_logs`)
- ✅ **Response Bot** (`response_bot`)
- ✅ **SLA Policies** (`sla`)
- ✅ **Custom Roles** (`custom_roles`)
- ✅ **Help Center Embedding Search** (`help_center_embedding_search`)

### Step 3: Enable Account-Level Features

Enable features per account using feature flags. This can be done via:

#### Option A: Via Rails Console

```ruby
# Access Rails console: bundle exec rails console

# Find your account
account = Account.find(1) # Replace with your account ID

# Enable premium features
account.enable_features!(
  'audit_logs',
  'response_bot',
  'sla',
  'custom_roles',
  'disable_branding',
  'help_center_embedding_search'
)

# Verify enabled features
account.enabled_features
```

#### Option B: Via InstallationConfig (Account Defaults)

Set default features for all new accounts:

```ruby
# In Rails console
config = InstallationConfig.find_or_create_by(name: 'ACCOUNT_LEVEL_FEATURE_DEFAULTS')
defaults = config.value || []

# Add premium features to defaults
premium_features = %w[
  audit_logs
  response_bot
  sla
  custom_roles
  disable_branding
  help_center_embedding_search
]

premium_features.each do |feature|
  existing = defaults.find { |f| f['name'] == feature }
  if existing
    existing['enabled'] = true
  else
    defaults << { 'name' => feature, 'enabled' => true }
  end
end

config.value = defaults
config.save!
GlobalConfig.clear_cache
```

### Step 4: Set Pricing Plan Quantity (Optional)

If using premium plan with agent limits:

```bash
INSTALLATION_PRICING_PLAN_QUANTITY=unlimited
```

Or via Rails console:

```ruby
InstallationConfig.find_or_create_by(name: 'INSTALLATION_PRICING_PLAN_QUANTITY').update(value: 999999)
GlobalConfig.clear_cache
```

### Step 5: Restart Application

Restart your Rails application to load the new configuration:

```bash
# On Railway, this happens automatically when env vars change
# Or manually restart via Railway dashboard
```

## Method 2: Using API Endpoints

### Enable Enterprise Mode via API

```bash
# Get your access token (Super Admin)
TOKEN="your_super_admin_access_token"

# Set Pricing Plan to Enterprise
curl -X PUT "https://your-instance.com/super_admin/installation_configs/INSTALLATION_PRICING_PLAN" \
  -H "Content-Type: application/json" \
  -H "api_access_token: $TOKEN" \
  -d '{"value": "enterprise"}'

# Set Unlimited Quantity
curl -X PUT "https://your-instance.com/super_admin/installation_configs/INSTALLATION_PRICING_PLAN_QUANTITY" \
  -H "Content-Type: application/json" \
  -H "api_access_token: $TOKEN" \
  -d '{"value": 999999}'
```

### Enable Account Features via API

```bash
# Enable features for account ID 1
curl -X POST "https://your-instance.com/api/v1/accounts/1/features" \
  -H "Content-Type: application/json" \
  -H "api_access_token: $TOKEN" \
  -d '{
    "features": [
      "audit_logs",
      "response_bot",
      "sla",
      "custom_roles",
      "disable_branding",
      "help_center_embedding_search"
    ]
  }'
```

## Method 3: Railway-Specific Configuration

### Railway Environment Variables

Add these to your Railway project:

```env
# Enable Enterprise Mode
INSTALLATION_PRICING_PLAN=enterprise

# Optional: Set agent quantity limit (999999 = unlimited)
INSTALLATION_PRICING_PLAN_QUANTITY=999999

# Optional: Disable enterprise checks (if you want full control)
# DISABLE_ENTERPRISE=false  # Default is false, don't set this
```

### Railway Startup Script

You can also set these via a startup script that runs before Rails starts:

```bash
#!/bin/bash
# .railway/startup.sh

# Set pricing plan if not already set
if [ -z "$INSTALLATION_PRICING_PLAN" ]; then
  export INSTALLATION_PRICING_PLAN=enterprise
fi

# Run Rails
exec bundle exec rails server
```

## Available Enterprise Features

Once Enterprise Mode is enabled, these features become available:

### Premium Features (Auto-enabled with Enterprise Plan)

1. **Disable Branding**
   - Remove "Powered by Chatwoot" from widget and emails
   - Access: Settings → Account Settings → Features

2. **Audit Logs**
   - Track all account activities
   - Access: Settings → Account Settings → Audit Logs
   - API: `/api/v1/accounts/{id}/audit_logs`

3. **Response Bot**
   - AI-powered automated responses
   - Access: Settings → Response Bot

4. **SLA Policies**
   - Service Level Agreement management
   - Access: Settings → SLA Policies
   - API: `/api/v1/accounts/{id}/sla_policies`

5. **Custom Roles**
   - Create custom permission sets
   - Access: Settings → Roles & Permissions
   - API: `/api/v1/accounts/{id}/custom_roles`

6. **Help Center Embedding Search**
   - Enhanced search in help center
   - Access: Settings → Help Center

### Additional Enterprise Routes

When Enterprise Mode is enabled, these routes become available:

- `/enterprise/api/v1/accounts` - Enterprise account management
- `/enterprise/webhooks/stripe` - Stripe webhook handling

## Verification Checklist

After enabling Enterprise Mode, verify:

- [ ] Visit `/super_admin/settings`
  - Should show "Enterprise" plan in plan details
  - Premium features should be available

- [ ] Visit `/app/accounts/{id}/settings/features`
  - Premium features should be toggleable
  - Features like "Audit Logs", "SLA", "Response Bot" should appear

- [ ] Visit `/app/accounts/{id}/settings/audit_logs`
  - Should show audit log interface (if feature enabled)

- [ ] Visit `/app/accounts/{id}/settings/sla_policies`
  - Should show SLA management interface (if feature enabled)

- [ ] Visit `/app/accounts/{id}/settings/roles`
  - Should show custom roles interface (if feature enabled)

- [ ] Check API endpoints:
  ```bash
  # Should return audit logs
  curl -H "api_access_token: $TOKEN" \
    "https://your-instance.com/api/v1/accounts/1/audit_logs"
  
  # Should return SLA policies
  curl -H "api_access_token: $TOKEN" \
    "https://your-instance.com/api/v1/accounts/1/sla_policies"
  
  # Should return custom roles
  curl -H "api_access_token: $TOKEN" \
    "https://your-instance.com/api/v1/accounts/1/custom_roles"
  ```

## Troubleshooting

### Enterprise Features Not Appearing

1. **Check Pricing Plan**:
   ```ruby
   # Rails console
   ChatwootHub.pricing_plan
   # Should return 'enterprise' or 'premium'
   ```

2. **Check Enterprise Directory**:
   ```ruby
   # Rails console
   ChatwootApp.enterprise?
   # Should return true
   ```

3. **Verify InstallationConfig**:
   ```ruby
   # Rails console
   InstallationConfig.find_by(name: 'INSTALLATION_PRICING_PLAN')&.value
   # Should return 'enterprise' or 'premium'
   ```

4. **Clear Cache**:
   ```ruby
   # Rails console
   GlobalConfig.clear_cache
   ```

### Features Enabled But Not Working

1. **Check Account Feature Flags**:
   ```ruby
   # Rails console
   account = Account.find(1)
   account.feature_enabled?('audit_logs')
   # Should return true
   ```

2. **Enable Feature on Account**:
   ```ruby
   # Rails console
   account.enable_features!('audit_logs', 'sla', 'custom_roles')
   ```

3. **Restart Application**:
   - Clear Rails cache
   - Restart workers (Sidekiq)
   - Restart web server

## Railway-Specific Notes

### Environment Variables

Railway allows setting environment variables via:
1. **Railway Dashboard**: Project → Variables → Add Variable
2. **railway.toml**: Define in config file
3. **railway.json**: Define in JSON config

### Automatic Restart

When you change environment variables in Railway:
- The application automatically restarts
- Rails reloads InstallationConfig
- Enterprise features become available

### Persistent Configuration

InstallationConfig values persist in the database, so:
- Environment variables set initial values
- Changes via dashboard/API persist across restarts
- Railway environment variables only set defaults

## Safe Upgrade Path

This upgrade method is safe because:

1. ✅ **No Source Code Changes**: All changes via config/API
2. ✅ **Reversible**: Can switch back to 'community' plan anytime
3. ✅ **Database-Backed**: Configuration stored in InstallationConfig table
4. ✅ **Feature Flags**: Can enable/disable features per account
5. ✅ **No Breaking Changes**: Community features still work

## Rollback Procedure

To revert to Community Edition:

```ruby
# Rails console
InstallationConfig.find_by(name: 'INSTALLATION_PRICING_PLAN').update(value: 'community')
GlobalConfig.clear_cache
```

Or via environment variable:

```bash
INSTALLATION_PRICING_PLAN=community
```

## Next Steps

After enabling Enterprise Mode:

1. Configure premium features per account
2. Set up SLA policies
3. Create custom roles
4. Enable audit logging
5. Configure response bot (if using AI)

## Support

For issues or questions:
- Check Chatwoot documentation: https://www.chatwoot.com/docs
- Enterprise features guide: https://www.chatwoot.com/docs/product/features
- GitHub Issues: https://github.com/chatwoot/chatwoot/issues

---

**Note**: This upgrade uses built-in enterprise modules that are included in the Chatwoot codebase. No external enterprise license or subscription is required for self-hosted instances using this method.

