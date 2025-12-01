# frozen_string_literal: true

# Auto-Designate SuperAdmin on Application Start
# 
# This initializer automatically designates a user as SuperAdmin
# based on the SUPER_ADMIN_EMAIL environment variable.
# 
# Set this environment variable:
#   SUPER_ADMIN_EMAIL - Email of the user who should be SuperAdmin
#
# This runs once on application startup to ensure the specified user
# has SuperAdmin privileges. The user must already exist in the system.

Rails.application.config.after_initialize do
  # Only run in production or if explicitly enabled
  next unless Rails.env.production? || ENV['AUTO_CREATE_SUPERADMIN'] == 'true'
  
  # Only run if SUPER_ADMIN_EMAIL is set
  next unless ENV['SUPER_ADMIN_EMAIL'].present?
  
  begin
    # Check if database is available before proceeding
    # During build/deployment, database may not exist yet
    unless ActiveRecord::Base.connection_pool.with_connection { |conn| conn.active? }
      Rails.logger.debug "[Auto-SuperAdmin] Database not available yet, skipping (this is normal during build)"
      next
    end
    
    # Try a simple query to verify database connection works
    ActiveRecord::Base.connection_pool.with_connection do |conn|
      conn.execute('SELECT 1')
    rescue ActiveRecord::StatementInvalid, PG::ConnectionBad, PG::UndefinedDatabase
      Rails.logger.debug "[Auto-SuperAdmin] Database connection failed, skipping (this is normal during build)"
      next
    end
    
    email = ENV['SUPER_ADMIN_EMAIL'].strip.downcase
    
    # Check if user exists with this email
    user = User.find_by('LOWER(email) = ?', email)
    
    unless user
      Rails.logger.warn "[Auto-SuperAdmin] ⚠️  User with email #{email} not found. User must be created first."
      next
    end
    
    # Check if user is already SuperAdmin
    if user.type == 'SuperAdmin'
      Rails.logger.info "[Auto-SuperAdmin] ✅ User #{email} is already SuperAdmin"
      next
    end
    
    # Convert user to SuperAdmin
    Rails.logger.info "[Auto-SuperAdmin] Converting user #{email} to SuperAdmin..."
    user.type = 'SuperAdmin'
    
    if user.save
      Rails.logger.info "[Auto-SuperAdmin] ✅ Successfully converted #{email} to SuperAdmin"
    else
      Rails.logger.error "[Auto-SuperAdmin] ❌ Error converting user to SuperAdmin: #{user.errors.full_messages.join(', ')}"
    end
    
    # Also ensure no other SuperAdmins exist (optional - only if you want single SuperAdmin)
    if ENV['SUPER_ADMIN_SINGLE'] == 'true'
      other_superadmins = SuperAdmin.where.not(email: email)
      if other_superadmins.exists?
        Rails.logger.info "[Auto-SuperAdmin] Removing SuperAdmin status from other users..."
        other_superadmins.update_all(type: nil)
        Rails.logger.info "[Auto-SuperAdmin] ✅ Removed SuperAdmin from #{other_superadmins.count} other user(s)"
      end
    end
    
  rescue ActiveRecord::StatementInvalid, PG::ConnectionBad, PG::UndefinedDatabase => e
    # Database not available - this is fine during build phase
    Rails.logger.debug "[Auto-SuperAdmin] Database not available: #{e.message}. Skipping (normal during build)."
    # Don't fail startup if database isn't ready
  rescue StandardError => e
    Rails.logger.error "[Auto-SuperAdmin] Error: #{e.message}"
    Rails.logger.error e.backtrace.first(5).join("\n")
    # Don't fail startup if superadmin designation fails
  end
end

