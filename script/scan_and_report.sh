#!/bin/bash
# =============================================================================
# Rails SonarQube Demo - Full Scan & Report
# =============================================================================
# Single command to run the custom security scanner and SonarQube analysis.
#
# Usage:
#   bash script/scan_and_report.sh
#
# Options:
#   --setup    Also create custom rules in SonarQube (first-time setup)
#   --scan     Only run the scanner without SonarQube analysis
# =============================================================================

set -e

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$PROJECT_ROOT"

echo "=============================================="
echo "Rails SonarQube Demo - Scan & Report"
echo "=============================================="
echo "Project: $PROJECT_ROOT"
echo ""

# Parse arguments
SETUP=false
SCAN_ONLY=false
for arg in "$@"; do
  case $arg in
    --setup) SETUP=true ;;
    --scan) SCAN_ONLY=true ;;
  esac
done

# Step 1: Setup custom rules (optional, first-time only)
if [ "$SETUP" = true ]; then
  echo "Step 1: Creating custom SonarQube rules..."
  echo ""
  bash script/create_sonar_rules.sh
  echo ""
fi

# Step 2: Run custom Rails security scanner
echo "Step 2: Running Rails security scanner..."
echo ""
ruby script/generate_sonar_issues.rb
echo ""

if [ "$SCAN_ONLY" = true ]; then
  echo "Scan complete. Skipping SonarQube analysis (--scan flag)."
  exit 0
fi

# Step 3: Run SonarQube scanner
echo "Step 3: Running SonarQube scanner..."
echo ""

if command -v sonar-scanner &> /dev/null; then
  sonar-scanner
elif [ -f "./bin/sonar-scanner" ]; then
  ./bin/sonar-scanner
else
  echo "ERROR: sonar-scanner not found in PATH."
  echo ""
  echo "Install it with:"
  echo "  brew install sonar-scanner    # macOS"
  echo "  apt install sonar-scanner     # Ubuntu"
  echo "  choco install sonar-scanner   # Windows"
  echo ""
  echo "Or download from: https://docs.sonarqube.org/latest/analyzing-source-code/scanners/sonarscanner/"
  exit 1
fi

echo ""
echo "=============================================="
echo "Done! Check your SonarQube dashboard:"
echo "  ${SONAR_URL:-http://localhost:9000}/dashboard?id=rails8-sonarqube-demo"
echo "=============================================="
