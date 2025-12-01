# frozen_string_literal: true

#
# Enable All Chatwoot CE Features
# Run: bundle exec rails runner scripts/enable-all-chatwoot-features.rb
#

require 'colorize'

puts "🚀 Enabling All Chatwoot CE Features...".colorize(:green)
puts ""

# Enable all standard features for all accounts
features_to_enable = %w[
  inbound_emails
  channel_email
  channel_facebook
  channel_twitter
  channel_website
  help_center
  macros
  agent_management
  team_management
  inbox_management
  labels
  custom_attributes
  automations
  canned_responses
  integrations
  voice_recorder
  campaigns
  reports
  crm
  auto_resolve_conversations
]

Account.find_each do |account|
  puts "Enabling features for account: #{account.name} (ID: #{account.id})".colorize(:cyan)
  
  account.enable_features!(*features_to_enable)
  
  enabled = account.enabled_features.select { |_, v| v }.keys
  puts "  ✓ Enabled #{enabled.count} features".colorize(:green)
end

puts ""
puts "✅ All Chatwoot CE features enabled!".colorize(:green)
puts ""

# Check installation config defaults
puts "📝 Updating default features for new accounts...".colorize(:cyan)

config = InstallationConfig.find_by(name: 'ACCOUNT_LEVEL_FEATURE_DEFAULTS')
defaults = config&.value || []

# Load feature definitions
feature_definitions = YAML.safe_load(File.read(Rails.root.join('config/features.yml')))

features_to_enable.each do |feature_name|
  existing = defaults.find { |f| f['name'] == feature_name }
  
  if existing
    existing['enabled'] = true
  else
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

puts "  ✓ Default features configured".colorize(:green)
puts ""
puts "✅ Complete!".colorize(:green)

