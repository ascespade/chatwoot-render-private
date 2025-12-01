# frozen_string_literal: true

#
# Auto-Create SuperAdmin on Startup
# 
# This script is called automatically on deployment to ensure
# a superadmin account exists. It uses environment variables.
#
# Environment Variables Required:
#   SUPER_ADMIN_EMAIL - Email for superadmin account
#   SUPER_ADMIN_NAME - Name for superadmin (optional, defaults to 'Administrator')
#   SUPER_ADMIN_PASSWORD - Password for superadmin account
#

email = ENV['SUPER_ADMIN_EMAIL']
password = ENV['SUPER_ADMIN_PASSWORD']
name = ENV['SUPER_ADMIN_NAME'] || 'Administrator'

# Exit if email or password not provided
unless email.present? && password.present?
  puts "[Auto-SuperAdmin] Skipping - SUPER_ADMIN_EMAIL or SUPER_ADMIN_PASSWORD not set"
  exit 0
end

# Check if superadmin already exists
existing = SuperAdmin.find_by(email: email)

if existing
  puts "[Auto-SuperAdmin] SuperAdmin already exists: #{email}"
  
  # Update password if it changed (optional - only if you want auto-updates)
  if ENV['SUPER_ADMIN_AUTO_UPDATE_PASSWORD'] == 'true'
    existing.password = password
    existing.password_confirmation = password
    existing.skip_confirmation!
    existing.save!
    puts "[Auto-SuperAdmin] Password updated for existing SuperAdmin"
  end
else
  # Check if user exists with different type
  user = User.find_by(email: email)
  
  if user
    puts "[Auto-SuperAdmin] Converting existing user to SuperAdmin: #{email}"
    user.type = 'SuperAdmin'
    user.password = password
    user.password_confirmation = password
    user.skip_confirmation!
    user.save!
  else
    # Create new superadmin
    puts "[Auto-SuperAdmin] Creating new SuperAdmin: #{email}"
    super_admin = SuperAdmin.new(
      name: name,
      email: email,
      password: password,
      password_confirmation: password
    )
    super_admin.skip_confirmation!
    
    if super_admin.save
      puts "[Auto-SuperAdmin] ✅ SuperAdmin created successfully: #{email}"
    else
      puts "[Auto-SuperAdmin] ❌ Error creating SuperAdmin:"
      super_admin.errors.full_messages.each { |e| puts "  - #{e}" }
      exit 1
    end
  end
end

