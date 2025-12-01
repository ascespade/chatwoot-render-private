# SuperAdmin Account Setup Guide

## Overview

SuperAdmin accounts are special users with `type='SuperAdmin'` that have full access to manage the entire Chatwoot installation, including:
- All accounts and users
- Installation configurations
- Platform apps
- System settings
- Clinic features (doctors, appointments)

## Creating Your First SuperAdmin

### Method 1: Rails Console (Recommended)

```ruby
# Access Rails console
bundle exec rails console

# Create superadmin
super_admin = SuperAdmin.new(
  name: 'Admin Name',
  email: 'admin@yourclinic.com',
  password: 'SecurePassword123!',
  password_confirmation: 'SecurePassword123!'
)
super_admin.skip_confirmation!  # Skip email confirmation
super_admin.save!

puts "✅ SuperAdmin created: #{super_admin.email}"
```

### Method 2: Using Script

```bash
# Run the automated script
./scripts/create-superadmin.sh
```

### Method 3: Via Account Builder (During Setup)

```ruby
# In Rails console
AccountBuilder.new(
  account_name: 'Your Clinic',
  email: 'admin@yourclinic.com',
  user_full_name: 'Admin Name',
  user_password: 'SecurePassword123!',
  super_admin: true,
  confirmed: true
).perform
```

## Managing SuperAdmin Accounts

### List All SuperAdmins

```ruby
# Rails console
SuperAdmin.all.each do |admin|
  puts "#{admin.name} (#{admin.email}) - Last login: #{admin.last_sign_in_at}"
end
```

### Update SuperAdmin Email

```ruby
# Rails console
admin = SuperAdmin.find_by(email: 'old@email.com')
admin.update(email: 'new@email.com')
admin.skip_reconfirmation!  # Skip email confirmation
admin.save!
```

### Change SuperAdmin Password

```ruby
# Rails console
admin = SuperAdmin.find_by(email: 'admin@yourclinic.com')
admin.password = 'NewSecurePassword123!'
admin.password_confirmation = 'NewSecurePassword123!'
admin.save!
```

### Disable/Delete SuperAdmin

```ruby
# Rails console
admin = SuperAdmin.find_by(email: 'admin@yourclinic.com')

# Option 1: Soft delete (recommended)
admin.update(email: "deleted_#{admin.id}_#{admin.email}")

# Option 2: Hard delete (use with caution)
# admin.destroy
```

## SuperAdmin Dashboard Access

### Login URL

```
https://your-instance.com/super_admin
```

### Default Login Flow

1. Navigate to `/super_admin`
2. Enter superadmin email and password
3. Access full admin dashboard

### Dashboard Features

- **Accounts**: Manage all accounts
- **Users**: Manage all users
- **Installation Configs**: System-wide settings
- **Platform Apps**: API applications
- **Doctors**: Manage clinic doctors (if clinic features enabled)
- **Appointments**: Manage all appointments (if clinic features enabled)
- **Settings**: System configuration

## Security Best Practices

### 1. Force Specific SuperAdmin Email

```ruby
# Rails console
# Ensure only specific email can be superadmin
admin_email = 'owner@yourclinic.com'

# Convert existing user to superadmin
user = User.find_by(email: admin_email)
if user
  user.update(type: 'SuperAdmin')
else
  SuperAdmin.create!(
    name: 'Owner',
    email: admin_email,
    password: 'SecurePassword123!',
    password_confirmation: 'SecurePassword123!'
  ).skip_confirmation!
end

# Remove superadmin from other users
User.where(type: 'SuperAdmin').where.not(email: admin_email).update_all(type: nil)
```

### 2. Disable Public Signup

```ruby
# Rails console
config = InstallationConfig.find_or_create_by(name: 'ENABLE_ACCOUNT_SIGNUP')
config.value = false
config.locked = false
config.save!
GlobalConfig.clear_cache
```

### 3. Set Strong Password Requirements

Ensure your superadmin uses a strong password:
- Minimum 8 characters
- Mix of uppercase, lowercase, numbers, special characters

## Railway/Production Setup

### Environment Variables

```bash
# Set in Railway dashboard
SUPER_ADMIN_EMAIL=owner@yourclinic.com
SUPER_ADMIN_PASSWORD=SecurePassword123!
```

### Automated Setup Script

Use the provided script to create superadmin on first deployment:

```bash
./scripts/create-superadmin.sh
```

## Troubleshooting

### Can't Access SuperAdmin Dashboard

1. **Check if superadmin exists**:
   ```ruby
   SuperAdmin.count
   SuperAdmin.pluck(:email)
   ```

2. **Verify password**:
   ```ruby
   admin = SuperAdmin.find_by(email: 'your@email.com')
   admin.valid_password?('your_password')
   ```

3. **Check confirmation**:
   ```ruby
   admin = SuperAdmin.find_by(email: 'your@email.com')
   admin.confirmed?  # Should be true
   admin.skip_confirmation! unless admin.confirmed?
   admin.save!
   ```

### Forgot SuperAdmin Password

```ruby
# Rails console
admin = SuperAdmin.find_by(email: 'your@email.com')
admin.password = 'NewPassword123!'
admin.password_confirmation = 'NewPassword123!'
admin.save!
```

### No SuperAdmin Exists

```ruby
# Rails console - Create first superadmin
SuperAdmin.create!(
  name: 'System Administrator',
  email: 'admin@yourclinic.com',
  password: 'SecurePassword123!',
  password_confirmation: 'SecurePassword123!'
).skip_confirmation!
```

## SuperAdmin Management via API

SuperAdmin accounts can be managed via the superadmin dashboard UI, which uses Administrate gem for CRUD operations.

## Access Control

SuperAdmin accounts have:
- ✅ Full access to all accounts
- ✅ Full access to all users
- ✅ System configuration access
- ✅ Installation config management
- ✅ Platform app management
- ✅ Clinic features management (if enabled)

## Next Steps

After creating your superadmin:

1. ✅ Login to `/super_admin`
2. ✅ Configure installation settings
3. ✅ Create/manage accounts
4. ✅ Set up clinic features (if using)
5. ✅ Configure branding and security

For clinic-specific superadmin features, see [CLINIC_SETUP_COMPLETE.md](./CLINIC_SETUP_COMPLETE.md)

