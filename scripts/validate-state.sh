#!/bin/bash
set -euo pipefail

# Validate _state.json schema compliance
# Usage: ./scripts/validate-state.sh [path/to/project-dir]

PROJECT_DIR="${1:-.}"
STATE_FILE="$PROJECT_DIR/architecture-output/_state.json"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "Validating: $STATE_FILE"
echo

# Check file exists
if [ ! -f "$STATE_FILE" ]; then
  echo -e "${RED}✗ State file not found: $STATE_FILE${NC}"
  exit 1
fi

# Check JSON validity
if ! jq empty "$STATE_FILE" 2>/dev/null; then
  echo -e "${RED}✗ Invalid JSON in $STATE_FILE${NC}"
  echo "Error details:"
  jq empty "$STATE_FILE" 2>&1 || true
  exit 1
fi

echo -e "${GREEN}✓ Valid JSON${NC}"

# Extract stage
STAGE=$(jq -r '.project.stage // "unknown"' "$STATE_FILE")
echo "Project stage: $STAGE"
echo

# Define required fields by stage
case "$STAGE" in
  concept)
    REQUIRED_FIELDS="project"
    EXPECTED_FIELDS="project.name project.description project.type project.stage"
    ;;
  mvp)
    REQUIRED_FIELDS="project tech_stack components design"
    EXPECTED_FIELDS="project tech_stack components design project.name project.stage"
    ;;
  growth|enterprise)
    REQUIRED_FIELDS="project tech_stack components entities design blueprint"
    EXPECTED_FIELDS="project tech_stack components entities design blueprint project.name project.stage"
    ;;
  *)
    echo -e "${YELLOW}⚠ Unknown stage: $STAGE (expected: concept|mvp|growth|enterprise)${NC}"
    REQUIRED_FIELDS="project"
    EXPECTED_FIELDS="project.name project.stage"
    ;;
esac

# Check required fields exist
MISSING_FIELDS=()
for field in $REQUIRED_FIELDS; do
  if ! jq -e ".$field" "$STATE_FILE" >/dev/null 2>&1; then
    MISSING_FIELDS+=("$field")
  fi
done

if [ ${#MISSING_FIELDS[@]} -gt 0 ]; then
  echo -e "${RED}✗ Missing required fields for stage '$STAGE':${NC}"
  for field in "${MISSING_FIELDS[@]}"; do
    echo "  - $field"
  done
  exit 1
else
  echo -e "${GREEN}✓ All required fields present${NC}"
fi

# Check project.name and project.stage exist
if ! jq -e '.project.name' "$STATE_FILE" >/dev/null 2>&1; then
  echo -e "${RED}✗ Missing project.name${NC}"
  exit 1
fi

if ! jq -e '.project.stage' "$STATE_FILE" >/dev/null 2>&1; then
  echo -e "${RED}✗ Missing project.stage${NC}"
  exit 1
fi

# Validate design colors if present
if jq -e '.design.primary' "$STATE_FILE" >/dev/null 2>&1; then
  PRIMARY=$(jq -r '.design.primary' "$STATE_FILE")
  if ! [[ "$PRIMARY" =~ ^#[0-9A-Fa-f]{6}$ ]]; then
    echo -e "${RED}✗ Invalid hex color for design.primary: $PRIMARY (expected: #RRGGBB)${NC}"
    exit 1
  fi

  # Check other color fields if primary is valid
  for COLOR_FIELD in secondary accent surface surface_elevated text_primary text_secondary; do
    if jq -e ".design.$COLOR_FIELD" "$STATE_FILE" >/dev/null 2>&1; then
      COLOR=$(jq -r ".design.$COLOR_FIELD" "$STATE_FILE")
      if ! [[ "$COLOR" =~ ^#[0-9A-Fa-f]{6}$ ]]; then
        echo -e "${YELLOW}⚠ Invalid hex color for design.$COLOR_FIELD: $COLOR${NC}"
      fi
    fi
  done

  echo -e "${GREEN}✓ Design colors valid${NC}"
fi

# Validate _state_version if present
if jq -e '._state_version' "$STATE_FILE" >/dev/null 2>&1; then
  VERSION=$(jq -r '._state_version' "$STATE_FILE")
  if ! [[ "$VERSION" =~ ^1\.[0-9]$ ]]; then
    echo -e "${YELLOW}⚠ Unexpected _state_version: $VERSION (expected: 1.x format)${NC}"
  fi
fi

# Check for common field names violations (e.g., camelCase instead of snake_case)
POTENTIAL_ALIASES=$(jq 'keys[] | select(. | test("^[a-z]+[A-Z]"))' "$STATE_FILE" 2>/dev/null || echo "")
if [ -n "$POTENTIAL_ALIASES" ]; then
  echo -e "${YELLOW}⚠ Potential camelCase fields found (should be snake_case):${NC}"
  echo "$POTENTIAL_ALIASES" | while read -r alias; do
    echo "  - $alias"
  done
fi

# Final validation
VALIDATION_PASSED=true

# Check that at least one of the known command-owned fields exists
HAS_OUTPUT=false
OUTPUT_FIELDS="tech_stack components entities personas market_research mvp_scope top_risks design blueprint prototype backlog_sync roadmap cost_estimate test_suite monitoring compliance cost_estimate documentation"

for field in $OUTPUT_FIELDS; do
  if jq -e ".$field" "$STATE_FILE" >/dev/null 2>&1; then
    HAS_OUTPUT=true
    break
  fi
done

if [ "$HAS_OUTPUT" = false ]; then
  echo -e "${YELLOW}⚠ No recognized output fields found (state may be empty)${NC}"
fi

echo
if [ "$VALIDATION_PASSED" = true ]; then
  echo -e "${GREEN}✓ State file valid: $STATE_FILE${NC}"
  exit 0
else
  echo -e "${RED}✗ State file validation failed${NC}"
  exit 1
fi
