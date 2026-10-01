#!/bin/bash

# Target date: October 10, 2026 at 11:59 UTC
TARGET_DATE="2026-10-01 11:59:00"

# Convert target date to epoch seconds (UTC)
if date --version >/dev/null 2>&1; then
    # GNU date (Linux)
    TARGET_EPOCH=$(date -u -d "$TARGET_DATE" +%s)
else
    # BSD date (macOS)
    TARGET_EPOCH=$(date -u -j -f "%Y-%m-%d %H:%M:%S" "$TARGET_DATE" +%s)
fi

echo "Waiting until $TARGET_DATE UTC..."

while true; do
    CURRENT_EPOCH=$(date -u +%s)
    NOW_REMAINING=$((TARGET_EPOCH - CURRENT_EPOCH))

    if [ "$NOW_REMAINING" -le 0 ]; then
        break
    fi

    # Sleep in chunks so we can print a countdown occasionally
    # and handle system clock adjustments gracefully
    if [ "$NOW_REMAINING" -gt 3600 ]; then
        SLEEP_TIME=3600
    elif [ "$NOW_REMAINING" -gt 60 ]; then
        SLEEP_TIME=60
    else
        SLEEP_TIME=$NOW_REMAINING
    fi

    DAYS=$((NOW_REMAINING / 86400))
    HOURS=$(( (NOW_REMAINING % 86400) / 3600 ))
    MINUTES=$(( (NOW_REMAINING % 3600) / 60 ))
    SECONDS_REMAINING=$((NOW_REMAINING % 60))
    printf "\rTime remaining: %dd %02dh %02dm %02ds" \
        "$DAYS" "$HOURS" "$MINUTES" "$SECONDS_REMAINING"

    sleep "$SLEEP_TIME"
done

echo ""
echo "Target time reached. Running git push..."

# Run the git command
git push -u origin main
