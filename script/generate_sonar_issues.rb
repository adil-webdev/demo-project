#!/usr/bin/env ruby
# =============================================================================
# Rails Security Scanner - SonarQube Generic Issue Import Generator
# =============================================================================
# This script scans the Rails codebase for common security vulnerabilities
# and generates a JSON report in SonarQube's Generic Issue Import format.
#
# This is the FALLBACK approach for SonarQube Community Edition which may
# not support custom regex-based rule templates for Ruby.
#
# Usage:
#   ruby script/generate_sonar_issues.rb
#
# Output:
#   sonar-issues.json (in project root)
#
# Configure in sonar-project.properties:
#   sonar.externalIssuesReportPaths=sonar-issues.json
# =============================================================================

require "json"

# Define security rules with regex patterns
RULES = [
  # --- VULNERABILITIES ---
  {
    ruleId: "rails-sql-injection",
    name: "Rails: SQL Injection via String Interpolation",
    description: "String interpolation in SQL queries allows SQL injection. Use parameterized queries.",
    severity: "CRITICAL",
    type: "VULNERABILITY",
    engineId: "rails-security",
    patterns: [/where\(["'].*#\{/],
    file_patterns: ["**/*.rb"],
    fix: 'Use parameterized queries: Post.where(status: params[:status])'
  },
  {
    ruleId: "rails-command-injection",
    name: "Rails: Command Injection via system/exec/backticks",
    description: "User input in shell commands allows arbitrary command execution.",
    severity: "CRITICAL",
    type: "VULNERABILITY",
    engineId: "rails-security",
    patterns: [/system\(["'].*#\{/, /exec\(["'].*#\{/, /`[^`]*#\{[^`]*params/],
    file_patterns: ["**/*.rb"],
    fix: 'Use Shellwords.shellescape or avoid shell commands'
  },
  {
    ruleId: "rails-mass-assignment",
    name: "Rails: Mass Assignment of Sensitive Attributes",
    description: "Permitting :role, :admin, or :ssn allows privilege escalation.",
    severity: "MAJOR",
    type: "VULNERABILITY",
    engineId: "rails-security",
    patterns: [/\.permit\(.*:role/, /\.permit\(.*:ssn/, /\.permit\(.*:admin/],
    file_patterns: ["**/*.rb"],
    fix: 'Remove sensitive attributes from permit list'
  },
  {
    ruleId: "rails-open-redirect",
    name: "Rails: Open Redirect via User-Controlled URL",
    description: "Redirecting to user-controlled URL allows phishing attacks.",
    severity: "MAJOR",
    type: "VULNERABILITY",
    engineId: "rails-security",
    patterns: [/redirect_to\s+params\[/],
    file_patterns: ["**/*.rb"],
    fix: 'Validate redirect URL against an allowlist'
  },
  {
    ruleId: "rails-xss-raw",
    name: "Rails: Cross-Site Scripting (XSS) via raw/html_safe",
    description: "Using raw() or .html_safe disables XSS protection.",
    severity: "CRITICAL",
    type: "VULNERABILITY",
    engineId: "rails-security",
    patterns: [/<%=\s*raw\(/, /\.html_safe/],
    file_patterns: ["**/*.erb", "**/*.rb"],
    fix: 'Use sanitize() or simple_format() instead of raw()'
  },
  {
    ruleId: "rails-path-traversal",
    name: "Rails: Path Traversal in File Operations",
    description: "Unsanitized user input in file operations allows reading arbitrary files.",
    severity: "CRITICAL",
    type: "VULNERABILITY",
    engineId: "rails-security",
    patterns: [/send_file\s+params\[/, /send_file\s+.*params\[/],
    file_patterns: ["**/*.rb"],
    fix: 'Use File.basename and restrict to a safe directory'
  },
  {
    ruleId: "rails-insecure-yaml",
    name: "Rails: Insecure Deserialization via YAML.load",
    description: "YAML.load can instantiate arbitrary objects. Use YAML.safe_load.",
    severity: "CRITICAL",
    type: "VULNERABILITY",
    engineId: "rails-security",
    patterns: [/YAML\.load\b(?!_)/],
    file_patterns: ["**/*.rb"],
    fix: 'Replace YAML.load with YAML.safe_load'
  },
  {
    ruleId: "rails-marshal-load",
    name: "Rails: Insecure Deserialization via Marshal.load",
    description: "Marshal.load with untrusted data allows code execution.",
    severity: "CRITICAL",
    type: "VULNERABILITY",
    engineId: "rails-security",
    patterns: [/Marshal\.load/],
    file_patterns: ["**/*.rb"],
    fix: 'Use JSON or YAML.safe_load for deserialization'
  },
  {
    ruleId: "rails-hardcoded-secret",
    name: "Rails: Hardcoded API Key or Secret",
    description: "Hardcoded credentials can be leaked via version control.",
    severity: "MAJOR",
    type: "VULNERABILITY",
    engineId: "rails-security",
    patterns: [/sk_live_[a-zA-Z0-9]+/, /sk_test_[a-zA-Z0-9]+/, /whsec_[a-zA-Z0-9]+/],
    file_patterns: ["**/*.rb"],
    fix: 'Use Rails.application.credentials or environment variables'
  },
  {
    ruleId: "rails-weak-crypto",
    name: "Rails: Weak Cryptographic Hash (MD5/SHA1)",
    description: "MD5 and SHA1 are cryptographically broken for security use.",
    severity: "MAJOR",
    type: "VULNERABILITY",
    engineId: "rails-security",
    patterns: [/Digest::MD5/, /Digest::SHA1/],
    file_patterns: ["**/*.rb"],
    fix: 'Use Digest::SHA256 or BCrypt instead'
  },

  # --- SECURITY HOTSPOTS ---
  {
    ruleId: "rails-sensitive-logging",
    name: "Rails: Sensitive Data in Logs",
    description: "Logging passwords or sensitive data exposes them in log files.",
    severity: "MAJOR",
    type: "SECURITY_HOTSPOT",
    engineId: "rails-security",
    patterns: [/logger.*password/i, /logger.*ssn/i, /logger.*secret/i],
    file_patterns: ["**/*.rb"],
    fix: 'Filter sensitive parameters in config/initializers/filter_parameter_logging.rb'
  },
  {
    ruleId: "rails-eval",
    name: "Rails: Dynamic Code Execution via eval",
    description: "eval() with external input allows arbitrary code execution.",
    severity: "CRITICAL",
    type: "SECURITY_HOTSPOT",
    engineId: "rails-security",
    patterns: [/\beval\(/],
    file_patterns: ["**/*.rb"],
    fix: 'Use a safe expression parser or remove eval'
  },
  {
    ruleId: "rails-skip-csrf",
    name: "Rails: CSRF Protection Disabled",
    description: "Disabling CSRF protection exposes the app to CSRF attacks.",
    severity: "MAJOR",
    type: "SECURITY_HOTSPOT",
    engineId: "rails-security",
    patterns: [/skip_before_action\s+:verify_authenticity_token/],
    file_patterns: ["**/*.rb"],
    fix: 'Use token-based auth for API endpoints instead of disabling CSRF'
  },
  {
    ruleId: "rails-permissive-cors",
    name: "Rails: Permissive CORS Configuration",
    description: "Access-Control-Allow-Origin: * allows any origin.",
    severity: "MINOR",
    type: "SECURITY_HOTSPOT",
    engineId: "rails-security",
    patterns: [/Access-Control-Allow-Origin.*\*/],
    file_patterns: ["**/*.rb"],
    fix: 'Restrict CORS to specific trusted origins'
  }
].freeze

# Collect files to scan
def find_files(base_dirs, file_patterns)
  files = []
  base_dirs.each do |dir|
    next unless File.directory?(dir)
    file_patterns.each do |pattern|
      files += Dir.glob(File.join(dir, pattern))
    end
  end
  files.uniq.reject { |f| f.include?("Zone.Identifier") }
end

# Scan a single file against all rules
def scan_file(filepath, rules)
  issues = []
  lines = File.readlines(filepath)

  lines.each_with_index do |line, index|
    rules.each do |rule|
      rule[:patterns].each do |pattern|
        if line.match?(pattern)
          issues << {
            engineId: rule[:engineId],
            ruleId: rule[:ruleId],
            primaryLocation: {
              message: "#{rule[:name]} — #{rule[:description]} Fix: #{rule[:fix]}",
              filePath: filepath,
              textRange: {
                startLine: index + 1,
                endLine: index + 1,
                startColumn: 0,
                endColumn: line.chomp.length
              }
            },
            type: rule[:type],
            severity: rule[:severity]
          }
          break
        end
      end
    end
  end

  issues
end

# =============================================================================
# Main Execution
# =============================================================================
puts "=" * 60
puts "Rails Security Scanner"
puts "=" * 60
puts ""

base_dirs = %w[app lib]
all_issues = []

# Determine unique file patterns across all rules
all_file_patterns = RULES.flat_map { |r| r[:file_patterns] }.uniq
files = find_files(base_dirs, all_file_patterns)

puts "Scanning #{files.length} files..."
puts ""

files.each do |filepath|
  file_issues = scan_file(filepath, RULES)
  if file_issues.any?
    puts "  #{filepath}: #{file_issues.length} issue(s) found"
    file_issues.each do |issue|
      line = issue[:primaryLocation][:textRange][:startLine]
      puts "    Line #{line}: [#{issue[:severity]}] #{issue[:ruleId]}"
    end
  end
  all_issues.concat(file_issues)
end

# Write output in SonarQube Generic Issue Import format
output = { issues: all_issues }
output_path = "sonar-issues.json"
File.write(output_path, JSON.pretty_generate(output))

puts ""
puts "=" * 60
puts "Scan Complete"
puts "=" * 60
puts ""
puts "Total issues found: #{all_issues.length}"
puts ""

# Group by type
vuln_count = all_issues.count { |i| i[:type] == "VULNERABILITY" }
hotspot_count = all_issues.count { |i| i[:type] == "SECURITY_HOTSPOT" }
puts "  Vulnerabilities:    #{vuln_count}"
puts "  Security Hotspots:  #{hotspot_count}"
puts ""

# Group by severity
%w[CRITICAL MAJOR MINOR].each do |sev|
  count = all_issues.count { |i| i[:severity] == sev }
  puts "  #{sev}: #{count}" if count > 0
end

puts ""
puts "Output written to: #{output_path}"
puts ""
puts "Next steps:"
puts "  1. Run: sonar-scanner"
puts "  2. Check SonarQube dashboard for issues"
puts ""

# Group by rule for summary table
puts "Issues by Rule:"
puts "-" * 60
issue_groups = all_issues.group_by { |i| i[:ruleId] }
issue_groups.sort_by { |_, issues| -issues.length }.each do |rule_id, issues|
  severity = issues.first[:severity]
  type = issues.first[:type]
  puts "  %-30s [%-8s] %-18s %d issue(s)" % [rule_id, severity, type, issues.length]
end
puts "-" * 60
