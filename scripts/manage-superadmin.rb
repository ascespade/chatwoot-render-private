# frozen_string_literal: true

#
# SuperAdmin Management Script
# 
# Usage: bundle exec rails runner scripts/manage-superadmin.rb [action] [email] [options]
#
# Actions:
#   create    - Create a new superadmin
#   list      - List all superadmins
#   update    - Update superadmin email/password
#   delete    - Remove superadmin status (convert to regular user)
#   password  - Change superadmin password
#

require 'colorize'

action = ARGV[0] || 'list'
email = ARGV[1]

case action
when 'create'
  if email.nil?
    puts "Usage: bundle exec rails runner scripts/manage-superadmin.rb create email@example.com [name] [password]".colorize(:yellow)
    exit 1
  end

  name = ARGV[2] || 'Administrator'
  password = ARGV[3] || SecureRandom.alphanumeric(16)

  if SuperAdmin.exists?(email: email)
    puts "⚠️  SuperAdmin with email #{email} already exists".colorize(:yellow)
    exit 1
  end

  super_admin = SuperAdmin.new(
    name: name,
    email: email,
    password: password,
    password_confirmation: password
  )
  super_admin.skip_confirmation!

  if super_admin.save
    puts "✅ SuperAdmin created successfully".colorize(:green)
    puts "   Email: #{email}"
    puts "   Password: #{password}"
    puts "   Login URL: /super_admin"
  else
    puts "❌ Error creating SuperAdmin:".colorize(:red)
    super_admin.errors.full_messages.each { |e| puts "   - #{e}" }
    exit 1
  end

when 'list'
  puts "👤 SuperAdmin Accounts".colorize(:cyan)
  puts "=" * 50

  if SuperAdmin.count.zero?
    puts "No SuperAdmin accounts found".colorize(:yellow)
  else
    SuperAdmin.all.each do |admin|
      puts ""
      puts "ID: #{admin.id}".colorize(:white)
      puts "Name: #{admin.name}".colorize(:white)
      puts "Email: #{admin.email}".colorize(:white)
      puts "Confirmed: #{admin.confirmed? ? 'Yes' : 'No'}"
      puts "Last Login: #{admin.last_sign_in_at || 'Never'}"
      puts "Created: #{admin.created_at}"
    end
  end

when 'update'
  if email.nil?
    puts "Usage: bundle exec rails runner scripts/manage-superadmin.rb update email@example.com [new_email] [new_name]".colorize(:yellow)
    exit 1
  end

  admin = SuperAdmin.find_by(email: email)
  unless admin
    puts "❌ SuperAdmin not found: #{email}".colorize(:red)
    exit 1
  end

  new_email = ARGV[2]
  new_name = ARGV[3]

  admin.email = new_email if new_email.present?
  admin.name = new_name if new_name.present?
  admin.skip_reconfirmation! if new_email.present?

  if admin.save
    puts "✅ SuperAdmin updated successfully".colorize(:green)
    puts "   Email: #{admin.email}"
    puts "   Name: #{admin.name}"
  else
    puts "❌ Error updating SuperAdmin:".colorize(:red)
    admin.errors.full_messages.each { |e| puts "   - #{e}" }
    exit 1
  end

when 'password'
  if email.nil?
    puts "Usage: bundle exec rails runner scripts/manage-superadmin.rb password email@example.com [new_password]".colorize(:yellow)
    exit 1
  end

  admin = SuperAdmin.find_by(email: email)
  unless admin
    puts "❌ SuperAdmin not found: #{email}".colorize(:red)
    exit 1
  end

  new_password = ARGV[2] || SecureRandom.alphanumeric(16)
  admin.password = new_password
  admin.password_confirmation = new_password

  if admin.save
    puts "✅ Password updated successfully".colorize(:green)
    puts "   Email: #{admin.email}"
    puts "   New Password: #{new_password}"
  else
    puts "❌ Error updating password:".colorize(:red)
    admin.errors.full_messages.each { |e| puts "   - #{e}" }
    exit 1
  end

when 'delete'
  if email.nil?
    puts "Usage: bundle exec rails runner scripts/manage-superadmin.rb delete email@example.com".colorize(:yellow)
    exit 1
  end

  admin = SuperAdmin.find_by(email: email)
  unless admin
    puts "❌ SuperAdmin not found: #{email}".colorize(:red)
    exit 1
  end

  # Convert to regular user instead of deleting
  admin.type = nil
  if admin.save
    puts "✅ SuperAdmin status removed (converted to regular user)".colorize(:green)
    puts "   Email: #{admin.email}"
  else
    puts "❌ Error removing SuperAdmin status:".colorize(:red)
    admin.errors.full_messages.each { |e| puts "   - #{e}" }
    exit 1
  end

else
  puts "Unknown action: #{action}".colorize(:red)
  puts ""
  puts "Available actions:".colorize(:cyan)
  puts "  create   - Create a new superadmin"
  puts "  list     - List all superadmins"
  puts "  update   - Update superadmin email/name"
  puts "  password - Change superadmin password"
  puts "  delete   - Remove superadmin status"
  exit 1
end

