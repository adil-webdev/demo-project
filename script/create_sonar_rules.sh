#!/bin/bash
# =============================================================================
# SonarQube Custom Rules Creator for Rails Security
# =============================================================================
# This script creates custom security rules in SonarQube Community Edition
# using the Web API. It creates a custom quality profile with regex-based
# rules to detect common Rails security vulnerabilities and hotspots.
#
# Usage:
#   export SONAR_URL=http://localhost:9000
#   export SONAR_TOKEN=your_token_here
#   bash script/create_sonar_rules.sh
#
# Prerequisites:
#   - SonarQube running and accessible
#   - Admin token with rule creation permissions
#   - curl installed
# =============================================================================

set -e

# Configuration
SONAR_URL="${SONAR_URL:-http://localhost:9000}"
SONAR_TOKEN="${SONAR_TOKEN:-squ_a1e93ae353649750e192aa55e3ee1fb848f330b4}"
LANGUAGE="ruby"
PROFILE_NAME="Rails Security"
PARENT_PROFILE="Sonar way"

echo "=============================================="
echo "SonarQube Custom Rails Security Rules Creator"
echo "=============================================="
echo "SonarQube URL: $SONAR_URL"
echo ""

# Helper function to make authenticated API calls
api_call() {
  local method=$1
  local endpoint=$2
  shift 2
  curl -s -X "$method" \
    -H "Authorization: Bearer $SONAR_TOKEN" \
    "${SONAR_URL}/api/${endpoint}" \
    "$@"
}

# Helper function to create a custom rule
create_rule() {
  local key=$1
  local name=$2
  local description=$3
  local severity=$4
  local type=$5
  local regex=$6

  echo -n "  Creating rule: $name ... "

  # Try using the regex rule template for Ruby
  result=$(api_call POST "rules/create" \
    -d "custom_key=${key}" \
    -d "name=${name}" \
    -d "markdown_description=${description}" \
    -d "severity=${severity}" \
    -d "type=${type}" \
    -d "template_key=ruby:CommentRegularExpression" \
    -d "params=regularExpression=${regex}" \
    2>&1)

  if echo "$result" | grep -q '"rule"'; then
    echo "OK"
    return 0
  fi

  # Fallback: try S100 template (generic regex)
  result=$(api_call POST "rules/create" \
    -d "custom_key=${key}" \
    -d "name=${name}" \
    -d "markdown_description=${description}" \
    -d "severity=${severity}" \
    -d "type=${type}" \
    -d "template_key=ruby:S100" \
    -d "params=format=${regex}" \
    2>&1)

  if echo "$result" | grep -q '"rule"'; then
    echo "OK (via S100)"
    return 0
  fi

  echo "SKIP (template not available - will use external issues)"
  return 1
}

# Helper function to activate a rule in the quality profile
activate_rule() {
  local rule_key=$1
  local severity=$2
  local profile_key=$3

  api_call POST "qualityprofiles/activate_rule" \
    -d "key=${profile_key}" \
    -d "rule=${rule_key}" \
    -d "severity=${severity}" > /dev/null 2>&1
}

# =============================================================================
# Step 1: Create Custom Quality Profile
# =============================================================================
echo ""
echo "Step 1: Creating custom quality profile '${PROFILE_NAME}'..."

# Get the parent profile key
parent_key=$(api_call GET "qualityprofiles/search?language=${LANGUAGE}&qualityProfile=${PARENT_PROFILE}" | \
  python3 -c "import sys,json; profiles=json.load(sys.stdin).get('profiles',[]); print(profiles[0]['key'] if profiles else '')" 2>/dev/null || echo "")

if [ -z "$parent_key" ]; then
  echo "  Warning: Could not find parent profile '${PARENT_PROFILE}'. Creating standalone profile."
  result=$(api_call POST "qualityprofiles/create" \
    -d "name=${PROFILE_NAME}" \
    -d "language=${LANGUAGE}")
else
  echo "  Found parent profile: $parent_key"
  result=$(api_call POST "qualityprofiles/copy" \
    -d "fromKey=${parent_key}" \
    -d "toName=${PROFILE_NAME}")
fi

# Get the new profile key
profile_key=$(api_call GET "qualityprofiles/search?language=${LANGUAGE}&qualityProfile=${PROFILE_NAME}" | \
  python3 -c "import sys,json; profiles=json.load(sys.stdin).get('profiles',[]); print(profiles[0]['key'] if profiles else '')" 2>/dev/null || echo "")

if [ -z "$profile_key" ]; then
  echo "  ERROR: Could not create or find quality profile. Continuing with rule creation only..."
else
  echo "  Profile key: $profile_key"
fi

# =============================================================================
# Step 2: Create Custom Security Rules
# =============================================================================
echo ""
echo "Step 2: Creating custom security rules..."
echo ""

rules_created=0

# --- VULNERABILITIES ---

echo "  [VULNERABILITIES]"

create_rule "rails-sql-injection" \
  "Rails: SQL Injection via String Interpolation" \
  "String interpolation in SQL WHERE clauses allows SQL injection attacks. Use parameterized queries instead.\n\n**Vulnerable:** \`Post.where(\"status = '\#{params[:status]}'\")\`\n\n**Fix:** \`Post.where(status: params[:status])\`" \
  "CRITICAL" \
  "VULNERABILITY" \
  'where\(["'"'"'].*#\{' && ((rules_created++)) || true

create_rule "rails-command-injection" \
  "Rails: Command Injection via system/exec/backticks" \
  "User input passed to system commands allows arbitrary command execution.\n\n**Vulnerable:** \`system(\"grep \#{params[:query]} log/\")\`\n\n**Fix:** Use \`Shellwords.shellescape\` or avoid shell commands entirely." \
  "CRITICAL" \
  "VULNERABILITY" \
  'system\(.*#\{.*params\|exec\(.*#\{.*params\|`.*#\{.*params' && ((rules_created++)) || true

create_rule "rails-mass-assignment" \
  "Rails: Mass Assignment of Sensitive Attributes" \
  "Permitting sensitive attributes like :role, :admin, or :ssn in strong parameters allows privilege escalation.\n\n**Vulnerable:** \`params.permit(:name, :email, :role, :ssn)\`\n\n**Fix:** Remove sensitive attributes from permit list." \
  "MAJOR" \
  "VULNERABILITY" \
  'permit\(.*:role\|permit\(.*:ssn\|permit\(.*:admin' && ((rules_created++)) || true

create_rule "rails-open-redirect" \
  "Rails: Open Redirect via User-Controlled URL" \
  "Redirecting to a user-controlled URL allows phishing attacks.\n\n**Vulnerable:** \`redirect_to params[:return_to]\`\n\n**Fix:** Validate the URL against an allowlist of trusted domains." \
  "MAJOR" \
  "VULNERABILITY" \
  'redirect_to\s*params\[' && ((rules_created++)) || true

create_rule "rails-xss-raw" \
  "Rails: Cross-Site Scripting (XSS) via raw/html_safe" \
  "Using \`raw()\` or \`.html_safe\` on user content disables Rails XSS protection.\n\n**Vulnerable:** \`<%= raw(@post.content) %>\`\n\n**Fix:** Use \`<%= sanitize(@post.content) %>\` or \`<%= simple_format(@post.content) %>\`" \
  "CRITICAL" \
  "VULNERABILITY" \
  'raw(\|\.html_safe' && ((rules_created++)) || true

create_rule "rails-path-traversal" \
  "Rails: Path Traversal in File Operations" \
  "Passing user input directly to file operations allows reading arbitrary system files.\n\n**Vulnerable:** \`send_file params[:file]\`\n\n**Fix:** Use \`File.basename\` and restrict to a safe directory." \
  "CRITICAL" \
  "VULNERABILITY" \
  'send_file.*params\[' && ((rules_created++)) || true

create_rule "rails-insecure-yaml" \
  "Rails: Insecure Deserialization via YAML.load" \
  "YAML.load can instantiate arbitrary Ruby objects, leading to Remote Code Execution.\n\n**Vulnerable:** \`YAML.load(user_data)\`\n\n**Fix:** Use \`YAML.safe_load(user_data)\`" \
  "CRITICAL" \
  "VULNERABILITY" \
  'YAML\.load[^_]' && ((rules_created++)) || true

create_rule "rails-hardcoded-secret" \
  "Rails: Hardcoded API Key or Secret" \
  "Hardcoded credentials in source code can be leaked via version control.\n\n**Vulnerable:** \`API_KEY = \"sk_live_...\"\`\n\n**Fix:** Use \`Rails.application.credentials\` or environment variables." \
  "MAJOR" \
  "VULNERABILITY" \
  'sk_live_\|sk_test_\|whsec_' && ((rules_created++)) || true

create_rule "rails-weak-crypto" \
  "Rails: Weak Cryptographic Hash (MD5/SHA1)" \
  "MD5 and SHA1 are cryptographically broken. Do not use for security-sensitive operations.\n\n**Vulnerable:** \`Digest::MD5.hexdigest(email)\`\n\n**Fix:** Use \`Digest::SHA256\` or \`BCrypt\`" \
  "MAJOR" \
  "VULNERABILITY" \
  'Digest::MD5\|Digest::SHA1' && ((rules_created++)) || true

create_rule "rails-marshal-load" \
  "Rails: Insecure Deserialization via Marshal.load" \
  "Marshal.load with untrusted data allows arbitrary code execution.\n\n**Vulnerable:** \`Marshal.load(Base64.decode64(data))\`\n\n**Fix:** Use JSON or YAML.safe_load for serialization." \
  "CRITICAL" \
  "VULNERABILITY" \
  'Marshal\.load' && ((rules_created++)) || true

# --- SECURITY HOTSPOTS ---

echo ""
echo "  [SECURITY HOTSPOTS]"

create_rule "rails-sensitive-logging" \
  "Rails: Sensitive Data in Logs" \
  "Logging passwords, SSNs, or secrets exposes sensitive data in log files.\n\n**Vulnerable:** \`Rails.logger.info(\"password=\#{params[:password]}\")\`\n\n**Fix:** Filter sensitive parameters in \`config/initializers/filter_parameter_logging.rb\`" \
  "MAJOR" \
  "SECURITY_HOTSPOT" \
  'logger.*password\|logger.*ssn\|logger.*secret' && ((rules_created++)) || true

create_rule "rails-eval" \
  "Rails: Dynamic Code Execution via eval" \
  "Using \`eval()\` with any external input allows arbitrary code execution.\n\n**Vulnerable:** \`eval(params[:formula])\`\n\n**Fix:** Use a safe expression parser or predefined calculations." \
  "CRITICAL" \
  "SECURITY_HOTSPOT" \
  '\beval(' && ((rules_created++)) || true

create_rule "rails-skip-csrf" \
  "Rails: CSRF Protection Disabled" \
  "Disabling CSRF protection exposes the application to Cross-Site Request Forgery attacks.\n\n**Review:** Ensure this is only done for stateless API endpoints that use token-based auth." \
  "MAJOR" \
  "SECURITY_HOTSPOT" \
  'skip_before_action.*verify_authenticity_token' && ((rules_created++)) || true

create_rule "rails-permissive-cors" \
  "Rails: Permissive CORS Configuration" \
  "Setting \`Access-Control-Allow-Origin: *\` allows any website to make cross-origin requests.\n\n**Review:** Restrict to specific trusted origins." \
  "MINOR" \
  "SECURITY_HOTSPOT" \
  'Access-Control-Allow-Origin.*\*' && ((rules_created++)) || true

# =============================================================================
# Step 3: Activate rules in profile
# =============================================================================
if [ -n "$profile_key" ]; then
  echo ""
  echo "Step 3: Activating custom rules in profile '${PROFILE_NAME}'..."

  for rule_key in rails-sql-injection rails-command-injection rails-mass-assignment \
    rails-open-redirect rails-xss-raw rails-path-traversal rails-insecure-yaml \
    rails-hardcoded-secret rails-weak-crypto rails-marshal-load \
    rails-sensitive-logging rails-eval rails-skip-csrf rails-permissive-cors; do

    activate_rule "ruby:${rule_key}" "MAJOR" "$profile_key"
  done

  echo "  Rules activated."

  # Set as default profile
  echo ""
  echo "Step 4: Setting '${PROFILE_NAME}' as default profile..."
  api_call POST "qualityprofiles/set_default" \
    -d "qualityProfile=${PROFILE_NAME}" \
    -d "language=${LANGUAGE}" > /dev/null 2>&1
  echo "  Done."
fi

# =============================================================================
# Summary
# =============================================================================
echo ""
echo "=============================================="
echo "Summary"
echo "=============================================="
echo "Rules created via API: $rules_created"
echo ""
echo "NOTE: SonarQube Community Edition may not support regex rule"
echo "templates for Ruby. If rules were skipped, the fallback"
echo "generic issue scanner will be used instead."
echo ""
echo "Run the fallback scanner:"
echo "  ruby script/generate_sonar_issues.rb"
echo ""
echo "Then run the SonarQube scanner:"
echo "  sonar-scanner"
echo "=============================================="
