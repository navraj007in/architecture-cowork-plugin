#!/bin/bash
# Analyze _activity.jsonl to reveal project health trends
# Usage: ./scripts/analyze-activity.sh [path/to/project-dir]

set -euo pipefail

PROJECT_DIR="${1:-.}"
ACTIVITY_FILE="$PROJECT_DIR/architecture-output/_activity.jsonl"

if [ ! -f "$ACTIVITY_FILE" ]; then
  echo "Activity log not found: $ACTIVITY_FILE"
  exit 1
fi

echo "╔════════════════════════════════════════════════════════════════╗"
echo "║ ACTIVITY TREND ANALYSIS                                        ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo

# Extract timestamps and calculate date range
FIRST_TIMESTAMP=$(jq -r '.ts' "$ACTIVITY_FILE" | head -1)
LAST_TIMESTAMP=$(jq -r '.ts' "$ACTIVITY_FILE" | tail -1)

echo "📊 Timeline"
echo "  First activity: $FIRST_TIMESTAMP"
echo "  Last activity:  $LAST_TIMESTAMP"
echo "  Total entries:  $(jq -s 'length' "$ACTIVITY_FILE")"
echo

# Count by outcome
echo "📈 Outcome Distribution"
echo "  Success:  $(jq -sr 'select(.outcome=="success")' "$ACTIVITY_FILE" | wc -l) commands completed"
echo "  Partial:  $(jq -sr 'select(.outcome=="partial")' "$ACTIVITY_FILE" | wc -l) commands with incomplete results"
echo "  Failed:   $(jq -sr 'select(.outcome=="failed")' "$ACTIVITY_FILE" | wc -l) command failures"
echo "  Warning:  $(jq -sr 'select(.outcome=="warning")' "$ACTIVITY_FILE" | wc -l) warnings"
echo

# Top commands run
echo "🔥 Most Frequently Used Commands"
jq -sr '.phase' "$ACTIVITY_FILE" | sort | uniq -c | sort -rn | head -10 | awk '{printf "  %2d×  %s\n", $1, $2}'
echo

# Failure analysis
FAILURES=$(jq -sr 'select(.outcome=="failed")' "$ACTIVITY_FILE")
if [ -n "$FAILURES" ]; then
  echo "⚠️  Recent Failures"
  echo "$FAILURES" | tail -5 | jq -r '"  [" + .ts + "] " + .phase + ": " + (.summary // "no summary")'
  echo
fi

# Stale commands (no runs in 7+ days)
echo "🕐 Command Activity"
echo "  Blueprint runs: $(jq -sr 'select(.phase=="blueprint")' "$ACTIVITY_FILE" | wc -l)"
echo "  Scaffold runs:  $(jq -sr 'select(.phase=="scaffold")' "$ACTIVITY_FILE" | wc -l)"
echo "  Review runs:    $(jq -sr 'select(.phase=="review")' "$ACTIVITY_FILE" | wc -l)"
echo "  Design runs:    $(jq -sr 'select(.phase=="design-system")' "$ACTIVITY_FILE" | wc -l)"
echo

# Success rate
TOTAL=$(jq -s 'length' "$ACTIVITY_FILE")
SUCCESS=$(jq -sr 'select(.outcome=="success")' "$ACTIVITY_FILE" | wc -l)
if [ "$TOTAL" -gt 0 ]; then
  RATE=$((SUCCESS * 100 / TOTAL))
  echo "📊 Success Rate"
  if [ "$RATE" -ge 90 ]; then
    echo "  ✅ $RATE% ($SUCCESS/$TOTAL) — Excellent project health"
  elif [ "$RATE" -ge 75 ]; then
    echo "  ⚠️  $RATE% ($SUCCESS/$TOTAL) — Good, but some issues need attention"
  else
    echo "  ❌ $RATE% ($SUCCESS/$TOTAL) — Many failures; project may be unstable"
  fi
  echo
fi

# Recommendations
echo "💡 Recommendations"
if [ "$RATE" -lt 75 ]; then
  echo "  • High failure rate detected. Run /architect:check-state to diagnose"
fi
LAST_SCAFFOLD=$(jq -sr 'select(.phase=="scaffold").ts' "$ACTIVITY_FILE" | tail -1)
if [ -z "$LAST_SCAFFOLD" ]; then
  echo "  • No scaffold runs found. Start with /architect:scaffold"
fi
LAST_DESIGN=$(jq -sr 'select(.phase=="design-system").ts' "$ACTIVITY_FILE" | tail -1)
if [ -z "$LAST_DESIGN" ]; then
  echo "  • No design-system runs. Run /architect:design-system to seed tokens"
fi
echo
