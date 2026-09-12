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
cyan "Building the app (this takes ~90 seconds)..."

# Build the release bundle explicitly
flutter build ios --release

cyan "Installing the app to your iPhone via devicectl..."
cyan "Keep your phone UNLOCKED during installation."

# Use devicectl to directly push the .app bundle, avoiding flutter run's flaky wireless debugger
xcrun devicectl device install app --device "$DEVICE_ID" build/ios/iphoneos/Runner.app

green ""
green "============================================"
green "  ✅ App installed on your iPhone!"
green ""
green "  The app will work for 7 days."
green "  Re-run this script to refresh."
green "============================================"
