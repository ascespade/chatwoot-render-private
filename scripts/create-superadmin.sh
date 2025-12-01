#!/bin/bash

#
# Create SuperAdmin Account Script
# 
# Creates a superadmin account for managing the Chatwoot installation
#

set -e

echo "👤 Creating SuperAdmin Account"
echo "==============================="
echo ""

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Check if Rails is available
if ! command -v bundle &> /dev/null; then
    echo -e "${RED}❌ Error: Ruby/bundler not found.${NC}"
    exit 1
fi

if [ ! -f "Gemfile" ]; then
    echo -e "${RED}❌ Error: Gemfile not found.${NC}"
    exit 1
fi

# Get email from environment or prompt
SUPER_ADMIN_EMAIL="${SUPER_ADMIN_EMAIL:-}"
SUPER_ADMIN_NAME="${SUPER_ADMIN_NAME:-}"
SUPER_ADMIN_PASSWORD="${SUPER_ADMIN_PASSWORD:-}"

if [ -z "$SUPER_ADMIN_EMAIL" ]; then
    read -p "Enter SuperAdmin email: " SUPER_ADMIN_EMAIL
fi

if [ -z "$SUPER_ADMIN_NAME" ]; then
    read -p "Enter SuperAdmin name: " SUPER_ADMIN_NAME
fi

if [ -z "$SUPER_ADMIN_PASSWORD" ]; then
    read -sp "Enter SuperAdmin password: " SUPER_ADMIN_PASSWORD
    echo ""
    read -sp "Confirm password: " PASSWORD_CONFIRM
    echo ""
    
    if [ "$SUPER_ADMIN_PASSWORD" != "$PASSWORD_CONFIRM" ]; then
        echo -e "${RED}❌ Error: Passwords do not match${NC}"
        exit 1
    fi
fi

# Validate email format (basic)
if [[ ! "$SUPER_ADMIN_EMAIL" =~ ^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]]; then
    echo -e "${RED}❌ Error: Invalid email format${NC}"
    exit 1
fi

# Validate password strength (basic)
if [ ${#SUPER_ADMIN_PASSWORD} -lt 8 ]; then
    echo -e "${YELLOW}⚠️  Warning: Password should be at least 8 characters${NC}"
    read -p "Continue anyway? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

echo ""
echo -e "${CYAN}Creating SuperAdmin account...${NC}"

# Create superadmin via Rails
bundle exec rails runner << RUBY
  email = ENV['SUPER_ADMIN_EMAIL'] || '$SUPER_ADMIN_EMAIL'
  name = ENV['SUPER_ADMIN_NAME'] || '$SUPER_ADMIN_NAME'
  password = ENV['SUPER_ADMIN_PASSWORD'] || '$SUPER_ADMIN_PASSWORD'

  # Check if superadmin already exists
  existing = SuperAdmin.find_by(email: email)
  
  if existing
    puts "⚠️  SuperAdmin with email #{email} already exists"
    puts "   Updating password..."
    existing.password = password
    existing.password_confirmation = password
    existing.skip_confirmation!
    existing.save!
    puts "✅ SuperAdmin password updated"
  else
    # Check if user exists with different type
    user = User.find_by(email: email)
    
    if user
      puts "⚠️  User with email #{email} exists but is not SuperAdmin"
      puts "   Converting to SuperAdmin..."
      user.type = 'SuperAdmin'
      user.password = password
      user.password_confirmation = password
      user.skip_confirmation!
      user.save!
      puts "✅ User converted to SuperAdmin"
    else
      # Create new superadmin
      super_admin = SuperAdmin.new(
        name: name,
        email: email,
        password: password,
        password_confirmation: password
      )
      super_admin.skip_confirmation!
      super_admin.save!
      
      if super_admin.persisted?
        puts "✅ SuperAdmin created successfully"
        puts "   Email: #{email}"
        puts "   Name: #{name}"
      else
        puts "❌ Error creating SuperAdmin:"
        super_admin.errors.full_messages.each do |error|
          puts "   - #{error}"
        end
        exit 1
      end
    end
  end
  
  puts ""
  puts "📋 SuperAdmin Details:"
  admin = SuperAdmin.find_by(email: email)
  puts "   ID: #{admin.id}"
  puts "   Email: #{admin.email}"
  puts "   Name: #{admin.name}"
  puts "   Confirmed: #{admin.confirmed? ? 'Yes' : 'No'}"
  puts "   Last Login: #{admin.last_sign_in_at || 'Never'}"
  puts ""
  puts "🔗 Login URL: /super_admin"
RUBY

if [ $? -eq 0 ]; then
    echo ""
    echo -e "${GREEN}✅ SuperAdmin account setup complete!${NC}"
    echo ""
    echo "Next steps:"
    echo "1. Login at: https://your-instance.com/super_admin"
    echo "2. Configure installation settings"
    echo "3. Create/manage accounts"
    echo ""
else
    echo -e "${RED}❌ Failed to create SuperAdmin account${NC}"
    exit 1
fi

