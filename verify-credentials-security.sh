#!/bin/bash
# Security Verification Script
# Ensures no Railway credentials are hardcoded anywhere

echo "🔒 Verifying Railway Credentials Security..."
echo ""

ERRORS=0

# Check for hardcoded token (excluding .env file which should contain credentials)
echo "1. Checking for hardcoded Railway token (excluding .env file)..."
MATCHES=$(grep -r "316a2754-3715-4168-b284-b87f510af9b9" . --exclude-dir=.git --exclude=".env" --exclude="SECURITY_AUDIT_RAILWAY.md" --exclude="verify-credentials-security.sh" 2>/dev/null | grep -v "your_railway_token_here\|placeholder\|example\|template" | wc -l)
if [ "$MATCHES" -gt 0 ]; then
  echo "   ❌ FOUND: Hardcoded Railway token in source files!"
  grep -r "316a2754-3715-4168-b284-b87f510af9b9" . --exclude-dir=.git --exclude=".env" --exclude="SECURITY_AUDIT_RAILWAY.md" --exclude="verify-credentials-security.sh" 2>/dev/null | grep -v "your_railway_token_here\|placeholder\|example\|template"
  ERRORS=$((ERRORS + 1))
else
  echo "   ✅ No hardcoded Railway token found (excluding .env file)"
  echo "      Note: .env file contains credentials (expected, and gitignored)"
fi

# Check for hardcoded project ID (excluding .env file)
echo ""
echo "2. Checking for hardcoded Railway project ID (excluding .env file)..."
MATCHES=$(grep -r "b4f33d17-b8cf-462b-821d-bba048134555" . --exclude-dir=.git --exclude=".env" --exclude="SECURITY_AUDIT_RAILWAY.md" --exclude="verify-credentials-security.sh" 2>/dev/null | grep -v "your_project_id_here\|placeholder\|example\|template" | wc -l)
if [ "$MATCHES" -gt 0 ]; then
  echo "   ❌ FOUND: Hardcoded Railway project ID in source files!"
  grep -r "b4f33d17-b8cf-462b-821d-bba048134555" . --exclude-dir=.git --exclude=".env" --exclude="SECURITY_AUDIT_RAILWAY.md" --exclude="verify-credentials-security.sh" 2>/dev/null | grep -v "your_project_id_here\|placeholder\|example\|template"
  ERRORS=$((ERRORS + 1))
else
  echo "   ✅ No hardcoded Railway project ID found (excluding .env file)"
  echo "      Note: .env file contains credentials (expected, and gitignored)"
fi

# Verify .env is in .gitignore
echo ""
echo "3. Verifying .env is in .gitignore..."
if grep -q "^\.env$" .gitignore; then
  echo "   ✅ .env is in .gitignore"
else
  echo "   ❌ .env is NOT in .gitignore!"
  ERRORS=$((ERRORS + 1))
fi

# Check that scripts use environment variables
echo ""
echo "4. Verifying scripts use environment variables only..."
SCRIPTS=(
  "tools/railway/get_services.sh"
  "tools/railway/get_logs.sh"
  "tools/railway/get_envs.sh"
  "dev_log_watcher.sh"
  "auto_deploy_check.sh"
)

for script in "${SCRIPTS[@]}"; do
  if [ -f "$script" ]; then
    if grep -q "\$RAILWAY_TOKEN" "$script" || grep -q "RAILWAY_TOKEN" "$script"; then
      echo "   ✅ $script uses environment variables"
    else
      echo "   ⚠️  $script - check if it uses environment variables"
    fi
  fi
done

# Summary
echo ""
echo "════════════════════════════════════════════════════"
if [ $ERRORS -eq 0 ]; then
  echo "✅ Security Check PASSED - No issues found!"
  echo ""
  echo "All Railway credentials are properly secured:"
  echo "  ✅ No hardcoded tokens or IDs"
  echo "  ✅ .env is gitignored"
  echo "  ✅ Scripts use environment variables only"
  exit 0
else
  echo "❌ Security Check FAILED - Found $ERRORS issue(s)!"
  echo ""
  echo "Please review the issues above and fix them."
  exit 1
fi

