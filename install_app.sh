#!/bin/bash
###############################################################################
# install_app.sh — Build & install directly to your iPhone via USB.
#
# This uses Xcode's proper code signing (free Apple ID), which means
# HealthKit and other entitlements work correctly.
#
# REQUIREMENTS:
#   - iPhone connected via USB cable
#   - Apple ID configured in Xcode (one-time setup)
#   - Developer Mode enabled on iPhone
#
# NOTE: The app expires every 7 days with a free Apple ID.
#       Just re-run this script to refresh it.
#
# USAGE:
#   ./install_app.sh
###############################################################################
set -euo pipefail

export PATH="$HOME/development/flutter/bin:$HOME/flutter/bin:/opt/homebrew/bin:/usr/local/bin:$HOME/.pub-cache/bin:$PATH"
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

red()   { printf '\033[1;31m%s\033[0m\n' "$*"; }
green() { printf '\033[1;32m%s\033[0m\n' "$*"; }
cyan()  { printf '\033[1;36m%s\033[0m\n' "$*"; }

# ── Check for connected iOS device ────────────────────────────────────────
cyan "Checking for connected iPhone..."

DEVICE_ID=$(flutter devices 2>/dev/null | grep -i "ios" | grep -v "simulator" | head -1 | sed -E 's/.*• ([A-Fa-f0-9-]+) •.*/\1/')

if [[ -z "$DEVICE_ID" ]]; then
  red "═══════════════════════════════════════════════════"
  red "  ERROR: No iPhone detected!"
  red ""
  red "  Make sure:"
  red "    1. Your iPhone is plugged in via USB"
  red "    2. Your iPhone is unlocked"
  red "    3. You tapped 'Trust' on the phone"
  red "═══════════════════════════════════════════════════"
  exit 1
fi

green "Found device: $DEVICE_ID"

# ── Build & install ───────────────────────────────────────────────────────
cyan "Building and installing to iPhone (this takes ~90 seconds)..."
cyan "Keep your phone UNLOCKED during installation."

flutter run --release -d "$DEVICE_ID" &
FLUTTER_PID=$!

# Wait for the app to be installed and launched, then kill flutter run
# (flutter run stays open for hot-reload, but we don't need that in release)
while kill -0 "$FLUTTER_PID" 2>/dev/null; do
  if grep -q "Installing and launching" /tmp/flutter_install_$$.log 2>/dev/null; then
    sleep 3
    break
  fi
  sleep 2
done

# Give it a moment to finish launching, then terminate flutter run
sleep 5
kill "$FLUTTER_PID" 2>/dev/null || true
wait "$FLUTTER_PID" 2>/dev/null || true

green ""
green "============================================"
green "  ✅ App installed on your iPhone!"
green ""
green "  The app will work for 7 days."
green "  Re-run this script to refresh."
green "============================================"
