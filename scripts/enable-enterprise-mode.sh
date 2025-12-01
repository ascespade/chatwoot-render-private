#!/bin/bash

#
# Enable Enterprise Mode for Chatwoot
# 
# This script enables enterprise features via environment variables
# and InstallationConfig updates. No source code modifications required.
#

set -e

echo "🚀 Enabling Chatwoot Enterprise Mode..."

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if Rails is available
if ! command -v bundle &> /dev/null; then
    echo "❌ Error: Ruby/bundler not found. Please run this script from your Chatwoot installation directory."
    exit 1
fi

# Check if we're in a Rails app
if [ ! -f "Gemfile" ]; then
    echo "❌ Error: Gemfile not found. Please run this script from your Chatwoot installation directory."
    exit 1
fi

echo "📋 Checking current configuration..."

# Get current pricing plan
CURRENT_PLAN=$(bundle exec rails runner "puts ChatwootHub.pricing_plan" 2>/dev/null || echo "community")

echo "Current plan: $CURRENT_PLAN"

if [ "$CURRENT_PLAN" = "enterprise" ] || [ "$CURRENT_PLAN" = "premium" ]; then
    echo -e "${GREEN}✓ Enterprise mode is already enabled!${NC}"
    read -p "Do you want to proceed anyway? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 0
    fi
fi

echo ""
echo "🔧 Enabling enterprise mode via InstallationConfig..."

# Enable enterprise mode
bundle exec rails runner << 'RUBY'
  # Set pricing plan to enterprise
  config = InstallationConfig.find_or_create_by(name: 'INSTALLATION_PRICING_PLAN')
  config.value = 'enterprise'
  config.locked = false
  config.save!
  
  # Set unlimited quantity
  qty_config = InstallationConfig.find_or_create_by(name: 'INSTALLATION_PRICING_PLAN_QUANTITY')
  qty_config.value = 999999
  qty_config.locked = false
  qty_config.save!
  
  # Clear cache
  GlobalConfig.clear_cache
  
  puts "✓ Enterprise mode enabled"
  puts "✓ Pricing plan set to: enterprise"
  puts "✓ Agent quantity set to: unlimited (999999)"
RUBY

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Enterprise mode enabled successfully!${NC}"
else
    echo "❌ Error: Failed to enable enterprise mode. Please check the error messages above."
    exit 1
fi

echo ""
echo "🎯 Enabling premium features for all accounts..."

# Enable premium features for all accounts
bundle exec rails runner << 'RUBY'
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
    puts "✓ Enabled premium features for account: #{account.name} (ID: #{account.id})"
  end
RUBY

echo ""
echo "📝 Setting default features for new accounts..."

# Update account-level feature defaults
bundle exec rails runner << 'RUBY'
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
  
  # Get feature list from features.yml
  feature_list = YAML.safe_load(File.read(Rails.root.join('config/features.yml')))
  
  # Update or add premium features
  premium_features.each do |feature_name|
    existing = defaults.find { |f| f['name'] == feature_name }
    if existing
      existing['enabled'] = true
    else
      defaults << { 'name' => feature_name, 'enabled' => true }
    end
  end
  
  config.value = defaults
  config.save!
  GlobalConfig.clear_cache
  
  puts "✓ Default features updated for new accounts"
RUBY

echo ""
echo -e "${GREEN}✅ Enterprise Mode Upgrade Complete!${NC}"
echo ""
echo "Next steps:"
echo "1. Restart your Rails application (if not using Railway auto-restart)"
echo "2. Visit /super_admin/settings to verify enterprise plan"
echo "3. Visit /app/accounts/{id}/settings/features to configure features per account"
echo "4. Check /app/accounts/{id}/settings/audit_logs for audit logs"
echo "5. Check /app/accounts/{id}/settings/sla_policies for SLA management"
echo ""
echo "For Railway deployments:"
echo "- Set INSTALLATION_PRICING_PLAN=enterprise in Railway environment variables"
echo "- Application will auto-restart and load enterprise features"
echo ""

