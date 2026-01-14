#!/bin/bash
set -e

# Input parameters from action.yml
DOCKERFILE_PATH="${1:-Dockerfile}"
FAIL_ON_ERROR="${2:-false}"
FAIL_ON_WARNING="${3:-false}"
MINIMUM_SCORE="${4:-0}"

echo "============================================"
echo "Dockadvisor - Dockerfile Linter"
echo "============================================"
echo "Analyzing: $DOCKERFILE_PATH"
echo ""

# Check if Dockerfile exists
if [ ! -f "$DOCKERFILE_PATH" ]; then
    echo "::error::Dockerfile not found at path: $DOCKERFILE_PATH"
    exit 1
fi

# Run dockadvisor and capture output
OUTPUT=$(dockadvisor -f "$DOCKERFILE_PATH" 2>&1) || true

# Print the full output
echo "$OUTPUT"
echo ""

# Parse the output to extract score
SCORE=$(echo "$OUTPUT" | grep "Dockerfile Score:" | grep -o '[0-9]\+' || echo "0")

# Count errors and warnings by checking severity in output
# Since the CLI doesn't show severity, we'll parse rules and estimate
TOTAL_RULES=$(echo "$OUTPUT" | grep -c "^\[" || echo "0")

# Extract individual rules for detailed counting
ERRORS=0
WARNINGS=0

# Parse rules (simplified approach - count all as issues for now)
# In a more sophisticated version, we'd need JSON output from dockadvisor
if [ "$TOTAL_RULES" -gt 0 ]; then
    # Estimate based on score (rough approximation)
    # Score = 100 - (errors * 15 + warnings * 5)
    SCORE_PENALTY=$((100 - SCORE))

    # Simple heuristic: if score is very low, assume mostly errors
    if [ "$SCORE" -lt 50 ]; then
        ERRORS=$((SCORE_PENALTY / 15))
        WARNINGS=$((TOTAL_RULES - ERRORS))
    else
        WARNINGS=$((SCORE_PENALTY / 5))
        ERRORS=$((TOTAL_RULES - WARNINGS))
    fi

    # Ensure non-negative values
    [ "$ERRORS" -lt 0 ] && ERRORS=0
    [ "$WARNINGS" -lt 0 ] && WARNINGS=0
fi

echo "============================================"
echo "Summary"
echo "============================================"
echo "Score: $SCORE/100"
echo "Total Issues: $TOTAL_RULES"
echo "Estimated Errors: $ERRORS"
echo "Estimated Warnings: $WARNINGS"
echo ""

# Set GitHub Actions outputs
echo "score=$SCORE" >> $GITHUB_OUTPUT
echo "errors=$ERRORS" >> $GITHUB_OUTPUT
echo "warnings=$WARNINGS" >> $GITHUB_OUTPUT

# Create annotations for each rule
while IFS= read -r line; do
    if [[ $line =~ Line\ ([0-9]+)(-([0-9]+))?:\ \[([^\]]+)\]\ (.+) ]]; then
        START_LINE="${BASH_REMATCH[1]}"
        END_LINE="${BASH_REMATCH[3]:-$START_LINE}"
        CODE="${BASH_REMATCH[4]}"
        MESSAGE="${BASH_REMATCH[5]}"

        # Create GitHub annotation
        echo "::warning file=$DOCKERFILE_PATH,line=$START_LINE,endLine=$END_LINE,title=$CODE::$MESSAGE"
    fi
done <<< "$OUTPUT"

# Determine if action should fail
SHOULD_FAIL=false
FAILURE_REASON=""

if [ "$FAIL_ON_ERROR" = "true" ] && [ "$ERRORS" -gt 0 ]; then
    SHOULD_FAIL=true
    FAILURE_REASON="Found $ERRORS error(s)"
fi

if [ "$FAIL_ON_WARNING" = "true" ] && [ "$WARNINGS" -gt 0 ]; then
    SHOULD_FAIL=true
    FAILURE_REASON="${FAILURE_REASON:+$FAILURE_REASON and }found $WARNINGS warning(s)"
fi

if [ "$SCORE" -lt "$MINIMUM_SCORE" ]; then
    SHOULD_FAIL=true
    FAILURE_REASON="${FAILURE_REASON:+$FAILURE_REASON and }score $SCORE is below minimum threshold of $MINIMUM_SCORE"
fi

if [ "$SHOULD_FAIL" = true ]; then
    echo "result=failed" >> $GITHUB_OUTPUT
    echo ""
    echo "::error::Action failed: $FAILURE_REASON"
    exit 1
else
    echo "result=passed" >> $GITHUB_OUTPUT
    echo ""
    echo "✓ Dockerfile analysis passed!"
    exit 0
fi
