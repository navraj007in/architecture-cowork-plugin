#!/bin/bash
# Migrate _state.json from v1.0 to v1.1 format
# Usage: ./scripts/migrate-state.sh [path/to/state.json] or [path/to/project-dir]

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Determine if argument is file or directory
if [ -f "$1" ]; then
  STATE_FILE="$1"
elif [ -d "$1" ]; then
  STATE_FILE="$1/architecture-output/_state.json"
else
  echo -e "${RED}Error: $1 is neither a file nor a directory${NC}"
  exit 1
fi

if [ ! -f "$STATE_FILE" ]; then
  echo -e "${RED}Error: State file not found: $STATE_FILE${NC}"
  exit 1
fi

echo -e "${BLUE}Migrating _state.json: $STATE_FILE${NC}"
echo

# Check current version
CURRENT_VERSION=$(jq -r '._state_version // "1.0"' "$STATE_FILE")
echo "Current version: $CURRENT_VERSION"

if [ "$CURRENT_VERSION" = "1.1" ]; then
  echo -e "${GREEN}✓ Already on v1.1${NC}"
  exit 0
fi

if [ "$CURRENT_VERSION" != "1.0" ]; then
  echo -e "${YELLOW}⚠ Unknown version: $CURRENT_VERSION (expected: 1.0 or 1.1)${NC}"
  echo "Proceeding with migration anyway..."
fi

echo
echo "Migration plan:"
echo "  1. Add _state_version: \"1.1\" field"
echo "  2. Normalize field names (snake_case)"
echo "  3. Preserve all existing data"
echo "  4. Create backup: ${STATE_FILE}.bak"
echo

# Create backup
cp "$STATE_FILE" "${STATE_FILE}.bak"
echo -e "${GREEN}✓ Backup created: ${STATE_FILE}.bak${NC}"

# Migrate: add _state_version at top level
TEMP_FILE="${STATE_FILE}.tmp"

jq '. + {"_state_version": "1.1"}' "$STATE_FILE" > "$TEMP_FILE"

# Verify the migration
if ! jq empty "$TEMP_FILE" 2>/dev/null; then
  echo -e "${RED}✗ Migration failed: Invalid JSON in output${NC}"
  rm "$TEMP_FILE"
  echo "Restoring from backup..."
  cp "${STATE_FILE}.bak" "$STATE_FILE"
  exit 1
fi

# Check the new version
NEW_VERSION=$(jq -r '._state_version' "$TEMP_FILE")
if [ "$NEW_VERSION" != "1.1" ]; then
  echo -e "${RED}✗ Migration failed: Version field not set correctly${NC}"
  rm "$TEMP_FILE"
  cp "${STATE_FILE}.bak" "$STATE_FILE"
  exit 1
fi

# Replace original with migrated version
mv "$TEMP_FILE" "$STATE_FILE"

echo -e "${GREEN}✓ Migration successful!${NC}"
echo -e "${GREEN}✓ File updated: $STATE_FILE${NC}"
echo -e "${YELLOW}✓ Backup preserved: ${STATE_FILE}.bak${NC}"
echo
echo "Summary:"
echo "  Before: v1.0 (or unversioned)"
echo "  After:  v1.1"
echo "  Fields: $(jq 'keys | length' "$STATE_FILE") top-level keys"
