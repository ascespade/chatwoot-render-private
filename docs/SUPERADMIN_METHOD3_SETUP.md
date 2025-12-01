# SuperAdmin Setup - Method 3: Automated via Email (Simplified)

## Overview

Method 3 automatically designates a user as SuperAdmin based on their email address. This is the simplest and most secure approach:

- ✅ **No passwords in environment variables**
- ✅ **Just set one variable: `SUPER_ADMIN_EMAIL`**
- ✅ **User must exist first (created via signup or manually)**
- ✅ **Automatic conversion to SuperAdmin on deployment**

## How It Works

1. User creates account normally (via signup or manual creation)
2. Set `SUPER_ADMIN_EMAIL=user@example.com` in environment
3. On application startup, the system checks if a user with that email exists
4. If found, converts them to SuperAdmin automatically
5. Works seamlessly with Railway/container deployments

## Setup Instructions

### Step 1: Create User Account First

The user must exist before they can be designated as SuperAdmin. Create the user via:

**Option A: Regular Signup**
1. Go to your Chatwoot instance
2. Sign up with email: `cur@cw.com.sa`
3. Complete registration

**Option B: Via Rails Console**
```ruby
# Rails console
User.create!(
  name: 'Admin Name',
  email: 'cur@cw.com.sa',
  password: 'SecurePassword123!',
  password_confirmation: 'SecurePassword123!'
).skip_confirmation!
```

**Option C: Via SuperAdmin Script** (if you have another superadmin)
```bash
bundle exec rails runner scripts/manage-superadmin.rb create cur@cw.com.sa "Admin Name" "password"
```

### Step 2: Set Environment Variable

#### Railway Dashboard Method (Recommended)

1. Go to **Railway Dashboard** → Your Project → **Variables**
2. Add this variable:

```env
SUPER_ADMIN_EMAIL=cur@cw.com.sa
AUTO_CREATE_SUPERADMIN=true
```

#### Railway.toml Method

Edit `railway.toml` in your project root:

```toml
[env]
SUPER_ADMIN_EMAIL = "cur@cw.com.sa"
AUTO_CREATE_SUPERADMIN = "true"
```

### Step 3: Deploy

The user will be automatically converted to SuperAdmin on the next deployment.

### Step 4: Verify

1. Wait for deployment to complete
2. Check logs for: `[Auto-SuperAdmin] ✅ Successfully converted cur@cw.com.sa to SuperAdmin`
3. Login at: `https://your-instance.com/super_admin`

## Environment Variables

### Required Variables

| Variable | Description | Example |
|----------|-------------|---------|
| `SUPER_ADMIN_EMAIL` | Email of user to designate as SuperAdmin | `cur@cw.com.sa` |

### Optional Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `AUTO_CREATE_SUPERADMIN` | Enable auto-designation | `false` (set to `true` to enable) |
| `SUPER_ADMIN_SINGLE` | Only allow one SuperAdmin (removes SuperAdmin from others) | `false` |

## Railway Configuration Example

### Minimal Configuration

```toml
[env]
SUPER_ADMIN_EMAIL = "cur@cw.com.sa"
AUTO_CREATE_SUPERADMIN = "true"
```

That's it! Just these two variables.

### Complete railway.toml Example

```toml
[build]
builder = "NIXPACKS"

[deploy]
startCommand = "bundle exec rails server -p $PORT -b 0.0.0.0"

[env]
# SuperAdmin (Method 3 - Simplified)
SUPER_ADMIN_EMAIL = "cur@cw.com.sa"
AUTO_CREATE_SUPERADMIN = "true"

# Optional: Only one SuperAdmin allowed
# SUPER_ADMIN_SINGLE = "true"

# Enterprise Mode
INSTALLATION_PRICING_PLAN = "enterprise"
INSTALLATION_PRICING_PLAN_QUANTITY = "999999"

# Clinic Configuration
CLINIC_NAME = "YourClinic"
CLINIC_AI_ENABLED = "true"

# Security
ENABLE_ACCOUNT_SIGNUP = "false"
```

## How Auto-Designation Works

The system uses an initializer (`config/initializers/auto_superadmin.rb`) that:

1. Runs on application startup (after Rails initializes)
2. Checks if `SUPER_ADMIN_EMAIL` is set
3. Checks if `AUTO_CREATE_SUPERADMIN` is `true` (or runs in production)
4. Searches for user with matching email (case-insensitive)
5. Converts user to SuperAdmin if found
6. Optionally removes SuperAdmin from other users if `SUPER_ADMIN_SINGLE=true`
7. Logs all actions for debugging

## Security Considerations

### ✅ Best Practices

1. **User Must Exist First**
   - Create user account before setting `SUPER_ADMIN_EMAIL`
   - User can be created via normal signup or manually

2. **No Passwords in Environment**
   - Password management is separate
   - More secure approach

3. **Case-Insensitive Email Matching**
   - `cur@cw.com.sa` matches `Cur@Cw.com.sa`
   - Email is normalized to lowercase

4. **Single SuperAdmin Option**
   - Set `SUPER_ADMIN_SINGLE=true` to ensure only one SuperAdmin
   - Automatically removes SuperAdmin from other users

### ⚠️ Important Notes

- User must exist before they can be designated as SuperAdmin
- If user doesn't exist, a warning is logged and nothing happens
- Email matching is case-insensitive for safety
- No password changes are made automatically

## Troubleshooting

### SuperAdmin Not Created

1. **Check if User Exists**:
   ```ruby
   # Rails console
   User.find_by(email: 'cur@cw.com.sa')
   ```
   If nil, create the user first.

2. **Check Environment Variable**:
   ```bash
   # In Railway, verify variable is set:
   # SUPER_ADMIN_EMAIL=cur@cw.com.sa
   # AUTO_CREATE_SUPERADMIN=true
   ```

3. **Check Logs**:
   ```
   [Auto-SuperAdmin] messages in deployment logs
   ```

### User Not Found Error

```
[Auto-SuperAdmin] ⚠️  User with email cur@cw.com.sa not found
```

**Solution**: Create the user first:
```ruby
# Rails console
User.create!(
  name: 'Admin Name',
  email: 'cur@cw.com.sa',
  password: 'SecurePassword123!',
  password_confirmation: 'SecurePassword123!'
).skip_confirmation!
```

### User Already SuperAdmin

```
[Auto-SuperAdmin] ✅ User cur@cw.com.sa is already SuperAdmin
```

This is normal - the system confirms the user is already SuperAdmin.

## Workflow Examples

### Example 1: New Installation

1. **Deploy Chatwoot** (without `SUPER_ADMIN_EMAIL` yet)
2. **Sign up** with email `cur@cw.com.sa`
3. **Set environment variable**: `SUPER_ADMIN_EMAIL=cur@cw.com.sa`
4. **Redeploy** or restart
5. **User is now SuperAdmin** automatically

### Example 2: Existing User

1. **User already exists** with email `cur@cw.com.sa`
2. **Set environment variable**: `SUPER_ADMIN_EMAIL=cur@cw.com.sa`
3. **Deploy** or restart
4. **User converted to SuperAdmin** automatically

### Example 3: Change SuperAdmin

1. **Current SuperAdmin**: `old@email.com`
2. **Set new variable**: `SUPER_ADMIN_EMAIL=new@email.com`
3. **Ensure `new@email.com` user exists**
4. **Set `SUPER_ADMIN_SINGLE=true`** (optional)
5. **Deploy** or restart
6. **New user becomes SuperAdmin**, old one loses SuperAdmin status

## Manual Conversion (Fallback)

If auto-designation fails, convert manually:

```ruby
# Rails console
user = User.find_by(email: 'cur@cw.com.sa')
user.update!(type: 'SuperAdmin')
```

## Complete Setup for Railway

### 1. Set Variable in Railway Dashboard

Go to Railway → Project → Variables → Add Variable:

```
SUPER_ADMIN_EMAIL = cur@cw.com.sa
AUTO_CREATE_SUPERADMIN = true
```

### 2. Ensure User Exists

**Option A**: User signs up normally
**Option B**: Create via Rails console:
```ruby
User.create!(
  name: 'Admin',
  email: 'cur@cw.com.sa',
  password: 'YourPassword123!',
  password_confirmation: 'YourPassword123!'
).skip_confirmation!
```

### 3. Deploy

Railway will automatically:
- Set environment variable
- Deploy application
- Convert user to SuperAdmin on startup

### 4. Login

Visit: `https://your-instance.railway.app/super_admin`
- Email: `cur@cw.com.sa`
- Password: (the password the user created with)

## Success Indicators

After deployment, check logs for:

```
[Auto-SuperAdmin] ✅ Successfully converted cur@cw.com.sa to SuperAdmin
```

Or if already SuperAdmin:

```
[Auto-SuperAdmin] ✅ User cur@cw.com.sa is already SuperAdmin
```

## Advantages of Method 3 (Simplified)

✅ **Simple**: Just one environment variable  
✅ **Secure**: No passwords in environment  
✅ **Flexible**: User manages their own password  
✅ **Safe**: Case-insensitive email matching  
✅ **Auditable**: All actions logged  
✅ **Idempotent**: Can run multiple times safely  

---

**Method 3 (Simplified) is now configured!**

Just set `SUPER_ADMIN_EMAIL=cur@cw.com.sa` in Railway and deploy. The user will automatically become SuperAdmin on startup.
