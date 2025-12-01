#!/bin/bash

#
# Complete Clinic Features Setup Script
# 
# This script enables all Chatwoot CE features and sets up clinic-specific features
#

set -e

echo "🏥 Chatwoot Clinic Professional Features Setup"
echo "================================================"
echo ""

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Check if Rails is available
if ! command -v bundle &> /dev/null; then
    echo "❌ Error: Ruby/bundler not found. Please run this script from your Chatwoot installation directory."
    exit 1
fi

if [ ! -f "Gemfile" ]; then
    echo "❌ Error: Gemfile not found. Please run this script from your Chatwoot installation directory."
    exit 1
fi

echo -e "${CYAN}Step 1: Enabling All Chatwoot CE Features...${NC}"
bundle exec rails runner scripts/enable-all-chatwoot-features.rb

echo ""
echo -e "${CYAN}Step 2: Running Database Migrations...${NC}"
bundle exec rails db:migrate

echo ""
echo -e "${CYAN}Step 3: Setting Up Security Settings...${NC}"
bundle exec rails runner << 'RUBY'
  # Disable public signup
  config = InstallationConfig.find_or_create_by(name: 'ENABLE_ACCOUNT_SIGNUP')
  config.value = false
  config.locked = false
  config.save!

  # Force super admin email (set your email)
  admin_email = ENV['SUPER_ADMIN_EMAIL'] || 'owner@yourclinic.com'
  puts "Setting super admin email to: #{admin_email}"
  # Note: This requires existing user - you'll need to update manually

  GlobalConfig.clear_cache
  puts "✓ Security settings configured"
RUBY

echo ""
echo -e "${CYAN}Step 4: Configuring Clinic Branding...${NC}"
bundle exec rails runner << 'RUBY'
  clinic_name = ENV['CLINIC_NAME'] || 'YourClinic'
  
  InstallationConfig.find_or_create_by(name: 'INSTALLATION_NAME').update(value: clinic_name)
  InstallationConfig.find_or_create_by(name: 'BRAND_NAME').update(value: clinic_name)
  
  GlobalConfig.clear_cache
  puts "✓ Clinic branding configured: #{clinic_name}"
RUBY

echo ""
echo -e "${GREEN}✅ Clinic Features Setup Complete!${NC}"
echo ""
echo "Next Steps:"
echo "1. Set environment variables:"
echo "   - CLINIC_AI_ENABLED=true"
echo "   - OPENAI_API_KEY=your_key (for AI assistant)"
echo "   - GOOGLE_CALENDAR_CLIENT_ID=... (for calendar sync)"
echo "   - SUPER_ADMIN_EMAIL=your@email.com"
echo ""
echo "2. Create doctors via API:"
echo "   POST /api/v1/accounts/{id}/clinic/doctors"
echo ""
echo "3. Start appointment reminder job:"
echo "   Add to Sidekiq schedule or run: Clinic::SendAppointmentRemindersJob.perform_later"
echo ""
echo "4. Access clinic dashboard:"
echo "   GET /api/v1/accounts/{id}/clinic/dashboard"

