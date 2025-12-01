# Quick Enterprise Mode Upgrade Guide

Upgrade Chatwoot Community Edition to Enterprise Mode using **only environment variables, feature flags, and endpoints** - **NO source code changes**.

## ✅ Requirements

- ✅ Do not modify source code
- ✅ Use only ENV variables, feature flags, and endpoints
- ✅ Auto-enable enterprise-only modules built into the OSS version
- ✅ Make it compatible with Railway hosting
- ✅ Keep upgrade path safe

---

## Step 1: Enable Enterprise Mode

### Set Environment Variables

Add these environment variables (Railway Dashboard → Variables):

```bash
INSTALLATION_PRICING_PLAN=enterprise
INSTALLATION_PRICING_PLAN_QUANTITY=999999
```

**Or via Rails Console**:

```ruby
# Set pricing plan
InstallationConfig.find_or_create_by(name: 'INSTALLATION_PRICING_PLAN').update(
  value: 'enterprise',
  locked: false
)

# Set unlimited quantity
InstallationConfig.find_or_create_by(name: 'INSTALLATION_PRICING_PLAN_QUANTITY').update(
  value: 999999,
  locked: false
)

# Clear cache
GlobalConfig.clear_cache
```

---

## Step 2: Restart Web + Worker

Railway will automatically restart when environment variables change.

**Manual restart** (if needed):
- Railway Dashboard → Service → Restart

---

## Step 3: Activate Enterprise Features

### Option A: Enable All Premium Features (Recommended)

**Via Rails Console**:

```ruby
# Enable features for all accounts
premium_features = %w[
  audit_logs
  response_bot
  sla
  custom_roles
  disable_branding
  help_center_embedding_search
]

Account.find_each do |account|
  account.enable_features!(*premium_features)
  puts "✓ Enabled features for account: #{account.name}"
end
```

**Via Script**:

```bash
# Run the automated script
./scripts/enable-enterprise-mode.sh

# Or via Rails runner
bundle exec rails runner scripts/enable-enterprise-features.rb
```

### Option B: Enable Features Per Account

**Via Rails Console**:

```ruby
# For specific account
account = Account.find(1)  # Replace with your account ID
account.enable_features!(
  'audit_logs',
  'sla',
  'custom_roles',
  'response_bot',
  'disable_branding'
)
```

---

## Step 4: Enable Default Features for New Accounts

**Via Rails Console**:

```ruby
# Update default features
config = InstallationConfig.find_or_create_by(name: 'ACCOUNT_LEVEL_FEATURE_DEFAULTS')
defaults = config.value || []

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

---

## Step 5: Verify Upgrade

### Checklist

- [ ] **Visit `/super_admin/settings`**
  - Should show "Enterprise" plan
  
- [ ] **Check Pricing Plan**:
  ```ruby
  # Rails console
  ChatwootHub.pricing_plan
  # Should return: "enterprise"
  ```

- [ ] **Visit `/app/accounts/{id}/settings/features`**
  - Premium features should be toggleable
  - Features visible: Audit Logs, SLA, Custom Roles, Response Bot, etc.

- [ ] **Visit `/app/accounts/{id}/settings/audit_logs`**
  - Audit logs interface should be accessible

- [ ] **Visit `/app/accounts/{id}/settings/sla_policies`**
  - SLA management interface should be accessible

- [ ] **Visit `/app/accounts/{id}/settings/roles`**
  - Custom roles interface should be accessible

- [ ] **Check Enterprise API Endpoints**:
  ```bash
  # Audit logs
  curl -H "api_access_token: YOUR_TOKEN" \
    "https://your-instance.com/api/v1/accounts/1/audit_logs"
  
  # SLA policies
  curl -H "api_access_token: YOUR_TOKEN" \
    "https://your-instance.com/api/v1/accounts/1/sla_policies"
  
  # Custom roles
  curl -H "api_access_token: YOUR_TOKEN" \
    "https://your-instance.com/api/v1/accounts/1/custom_roles"
  ```

---

## Available Enterprise Features

Once Enterprise Mode is enabled, these features become available:

### Premium Features

1. **Audit Logs** (`audit_logs`)
   - Track all account activities
   - API: `/api/v1/accounts/{id}/audit_logs`

2. **SLA Policies** (`sla`)
   - Service Level Agreement management
   - API: `/api/v1/accounts/{id}/sla_policies`

3. **Custom Roles** (`custom_roles`)
   - Create custom permission sets
   - API: `/api/v1/accounts/{id}/custom_roles`

4. **Response Bot** (`response_bot`)
   - AI-powered automated responses
   - Settings: `/app/accounts/{id}/settings/response_documents`

5. **Disable Branding** (`disable_branding`)
   - Remove "Powered by Chatwoot" from widget and emails

6. **Help Center Embedding Search** (`help_center_embedding_search`)
   - Enhanced search in help center

---

## Railway-Specific Configuration

### Environment Variables (Railway Dashboard)

1. Go to **Railway Dashboard** → Your Project → **Variables**
2. Add these variables:

```env
INSTALLATION_PRICING_PLAN=enterprise
INSTALLATION_PRICING_PLAN_QUANTITY=999999
```

3. Railway will automatically restart the service

### Railway Configuration File (Optional)

Create `railway.toml` in project root (see `railway.toml.example`):

```toml
[env]
INSTALLATION_PRICING_PLAN = "enterprise"
INSTALLATION_PRICING_PLAN_QUANTITY = "999999"
```

---

## Quick Enable Script

### Automated Script

```bash
# Make executable (first time only)
chmod +x scripts/enable-enterprise-mode.sh

# Run the script
./scripts/enable-enterprise-mode.sh
```

This script will:
- ✅ Set pricing plan to `enterprise`
- ✅ Set unlimited agent quantity
- ✅ Enable premium features for all accounts
- ✅ Set default features for new accounts
- ✅ Verify configuration

---

## API Endpoints Reference

### Enable Features via API

```bash
# Enable features for account (if API endpoint exists)
curl -X POST "https://your-instance.com/api/v1/accounts/1/features" \
  -H "Content-Type: application/json" \
  -H "api_access_token: YOUR_TOKEN" \
  -d '{
    "features": ["audit_logs", "sla", "custom_roles"]
  }'
```

### Update InstallationConfig via Super Admin API

```bash
# Update pricing plan (requires Super Admin access)
curl -X PUT "https://your-instance.com/super_admin/installation_configs/INSTALLATION_PRICING_PLAN" \
  -H "Content-Type: application/json" \
  -H "api_access_token: SUPER_ADMIN_TOKEN" \
  -d '{"installation_config": {"value": "enterprise"}}'
```

---

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

---

## Troubleshooting

### Enterprise Features Not Appearing

1. **Check Pricing Plan**:
   ```ruby
   ChatwootHub.pricing_plan  # Should return 'enterprise'
   ```

2. **Check Enterprise Directory**:
   ```ruby
   ChatwootApp.enterprise?  # Should return true
   ```

3. **Clear Cache**:
   ```ruby
   GlobalConfig.clear_cache
   ```

4. **Restart Application**:
   - Railway: Service → Restart
   - Manual: Restart Rails server

### Features Enabled But Not Working

1. **Check Account Features**:
   ```ruby
   account = Account.find(1)
   account.feature_enabled?('audit_logs')  # Should return true
   ```

2. **Re-enable Features**:
   ```ruby
   account.enable_features!('audit_logs', 'sla', 'custom_roles')
   ```

---

## Success!

✅ **Chatwoot Community Edition is now running in Enterprise Mode using official environment flags and endpoints.**

All enterprise features are now available:
- ✅ Audit Logs
- ✅ SLA Policies
- ✅ Custom Roles
- ✅ Response Bot
- ✅ Disable Branding
- ✅ Help Center Embedding Search

---

## Next Steps

1. Configure premium features per account
2. Set up SLA policies for your workflows
3. Create custom roles for your team
4. Enable audit logging for compliance
5. Configure response bot (requires OpenAI API key)

For detailed information, see [ENTERPRISE_UPGRADE_GUIDE.md](./ENTERPRISE_UPGRADE_GUIDE.md)

