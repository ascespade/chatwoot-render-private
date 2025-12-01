# frozen_string_literal: true

#
# Rails script to enable Enterprise Mode and premium features
# 
# Usage: bundle exec rails runner scripts/enable-enterprise-features.rb [account_id]
# 
# If account_id is provided, enables features for that account only.
# Otherwise, enables for all accounts and sets default features.
#

require 'colorize'

account_id = ARGV[0]&.to_i

puts "🚀 Enabling Chatwoot Enterprise Mode...".colorize(:green)
puts ""

# Check if enterprise directory exists
unless ChatwootApp.enterprise?
  puts "⚠️  Warning: Enterprise directory not found. Enterprise features may not be available.".colorize(:yellow)
  puts "   Continuing anyway...".colorize(:yellow)
end

# Step 1: Set Pricing Plan to Enterprise
puts "📋 Step 1: Setting pricing plan to enterprise...".colorize(:cyan)

plan_config = InstallationConfig.find_or_create_by(name: 'INSTALLATION_PRICING_PLAN')
plan_config.value = 'enterprise'
plan_config.locked = false
plan_config.save!

qty_config = InstallationConfig.find_or_create_by(name: 'INSTALLATION_PRICING_PLAN_QUANTITY')
qty_config.value = 999999  # Unlimited
qty_config.locked = false
qty_config.save!

GlobalConfig.clear_cache

current_plan = ChatwootHub.pricing_plan
puts "   ✓ Pricing plan set to: #{current_plan}".colorize(:green)
puts "   ✓ Agent quantity set to: unlimited (999999)".colorize(:green)
puts ""

# Step 2: Define premium features
premium_features = %w[
  audit_logs
  response_bot
  sla
  custom_roles
  disable_branding
  help_center_embedding_search
]

puts "📦 Step 2: Enabling premium features...".colorize(:cyan)
puts "   Features: #{premium_features.join(', ')}"
puts ""

# Step 3: Enable features for account(s)
if account_id
  puts "🎯 Step 3: Enabling features for account ID #{account_id}...".colorize(:cyan)
  
  account = Account.find_by(id: account_id)
  
  if account.nil?
    puts "   ❌ Error: Account with ID #{account_id} not found!".colorize(:red)
    exit 1
  end
  
  account.enable_features!(*premium_features)
  
  enabled = account.enabled_features.select { |_, v| v }.keys
  puts "   ✓ Enabled features for account: #{account.name} (ID: #{account.id})".colorize(:green)
  puts "   ✓ Enabled: #{enabled.join(', ')}".colorize(:green)
else
  puts "🎯 Step 3: Enabling features for all accounts...".colorize(:cyan)
  
  count = 0
  Account.find_each do |account|
    account.enable_features!(*premium_features)
    count += 1
    puts "   ✓ Enabled features for account: #{account.name} (ID: #{account.id})".colorize(:green)
  end
  
  puts "   ✓ Updated #{count} account(s)".colorize(:green)
end

puts ""

# Step 4: Update default features for new accounts
puts "📝 Step 4: Setting default features for new accounts...".colorize(:cyan)

config = InstallationConfig.find_by(name: 'ACCOUNT_LEVEL_FEATURE_DEFAULTS')
defaults = config&.value || []

# Load feature definitions from features.yml
feature_definitions = YAML.safe_load(File.read(Rails.root.join('config/features.yml')))

# Update or add premium features to defaults
premium_features.each do |feature_name|
  existing = defaults.find { |f| f['name'] == feature_name }
  
  if existing
    existing['enabled'] = true
  else
    # Find feature definition to get additional metadata
    feature_def = feature_definitions.find { |f| f['name'] == feature_name }
    defaults << {
      'name' => feature_name,
      'enabled' => true,
      'help_url' => feature_def&.dig('help_url')
    }
  end
end

config = InstallationConfig.find_or_create_by(name: 'ACCOUNT_LEVEL_FEATURE_DEFAULTS')
config.value = defaults
config.locked = true
config.save!

GlobalConfig.clear_cache

puts "   ✓ Default features configured for new accounts".colorize(:green)
puts ""

# Step 5: Verification
puts "🔍 Step 5: Verifying configuration...".colorize(:cyan)

# Check pricing plan
plan = ChatwootHub.pricing_plan
if plan == 'enterprise' || plan == 'premium'
  puts "   ✓ Pricing plan: #{plan}".colorize(:green)
else
  puts "   ⚠️  Warning: Pricing plan is '#{plan}', expected 'enterprise'".colorize(:yellow)
end

# Check enterprise directory
if ChatwootApp.enterprise?
  puts "   ✓ Enterprise directory found".colorize(:green)
else
  puts "   ⚠️  Warning: Enterprise directory not found".colorize(:yellow)
end

# Check account features (if account_id provided)
if account_id
  account = Account.find(account_id)
  enabled_count = account.enabled_features.select { |_, v| v }.size
  puts "   ✓ Account #{account_id} has #{enabled_count} features enabled".colorize(:green)
end

puts ""
puts "✅ Enterprise Mode Upgrade Complete!".colorize(:green)
puts ""
puts "Next steps:".colorize(:cyan)
puts "1. Restart your Rails application".colorize(:white)
puts "2. Visit /super_admin/settings to verify enterprise plan".colorize(:white)
puts "3. Visit /app/accounts/{id}/settings/features to configure features".colorize(:white)
puts "4. Check /app/accounts/{id}/settings/audit_logs for audit logs".colorize(:white)
puts "5. Check /app/accounts/{id}/settings/sla_policies for SLA management".colorize(:white)
puts ""

