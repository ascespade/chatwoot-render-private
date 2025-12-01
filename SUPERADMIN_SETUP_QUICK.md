# SuperAdmin Setup - Quick Guide (Method 3)

## ✅ Simplified: Just One Variable!

Set only **`SUPER_ADMIN_EMAIL`** to automatically designate a user as SuperAdmin.

## Setup Steps

### 1. Create User First

The user must exist before they can become SuperAdmin. Create them via:

**Option A: Normal Signup**
- Go to your Chatwoot instance
- Sign up with email: `cur@cw.com.sa`
- Complete registration

**Option B: Rails Console** (if you have console access)
```ruby
User.create!(
  name: 'Admin',
  email: 'cur@cw.com.sa',
  password: 'YourPassword123!',
  password_confirmation: 'YourPassword123!'
).skip_confirmation!
```

### 2. Set Environment Variable

In **Railway Dashboard** → **Variables**, add:

```env
SUPER_ADMIN_EMAIL=cur@cw.com.sa
AUTO_CREATE_SUPERADMIN=true
```

Or in `railway.toml`:

```toml
[env]
SUPER_ADMIN_EMAIL = "cur@cw.com.sa"
AUTO_CREATE_SUPERADMIN = "true"
```

### 3. Deploy

On next deployment/restart, the user will automatically become SuperAdmin.

### 4. Verify

Check logs for:
```
[Auto-SuperAdmin] ✅ Successfully converted cur@cw.com.sa to SuperAdmin
```

Login at: `https://your-instance.com/super_admin`

## How It Works

1. ✅ User exists with email `cur@cw.com.sa`
2. ✅ Set `SUPER_ADMIN_EMAIL=cur@cw.com.sa` in environment
3. ✅ On startup, system finds user by email
4. ✅ Converts user to SuperAdmin automatically
5. ✅ Done!

## Benefits

- ✅ **Simple**: Just one environment variable
- ✅ **Secure**: No passwords in environment
- ✅ **Flexible**: User manages their own password
- ✅ **Safe**: Case-insensitive email matching

## Optional: Single SuperAdmin

To ensure only one SuperAdmin exists, add:

```env
SUPER_ADMIN_SINGLE=true
```

This will automatically remove SuperAdmin status from other users.

---

**That's it! Just set `SUPER_ADMIN_EMAIL=cur@cw.com.sa` and deploy.**

For detailed documentation, see: `docs/SUPERADMIN_METHOD3_SETUP.md`

