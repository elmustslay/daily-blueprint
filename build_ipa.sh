#!/bin/bash
###############################################################################
# build_ipa.sh — Build a sideload-ready (AltStore) .ipa WITHOUT a paid
#                Apple Developer account.
#
# HOW IT WORKS:
# Flutter's --no-codesign wrapper produces a 0-byte binary in newer Xcode.
# This script calls xcodebuild directly with CODE_SIGNING_ALLOWED=NO which
# still links the Runner binary properly.  The resulting unsigned .app is
# packaged into a Payload/ zip (.ipa) for AltStore/Sideloadly.
#
# USAGE:
#   chmod +x build_ipa.sh
#   ./build_ipa.sh
###############################################################################
set -euo pipefail

red()   { printf '\033[1;31m%s\033[0m\n' "$*"; }
green() { printf '\033[1;32m%s\033[0m\n' "$*"; }
cyan()  { printf '\033[1;36m%s\033[0m\n' "$*"; }

# ── Locate Xcode ──────────────────────────────────────────────────────────
XCODE_APP="/Applications/Xcode.app"
if [[ ! -d "$XCODE_APP" ]]; then
  red "ERROR: Xcode.app not found at $XCODE_APP"
  exit 1
fi

XCODE_DEV="$XCODE_APP/Contents/Developer"

# Switch xcode-select if needed
CURRENT_DEV=$(xcode-select -p 2>/dev/null || true)
if [[ "$CURRENT_DEV" != "$XCODE_DEV" ]]; then
  cyan "Switching xcode-select → $XCODE_DEV (needs your password once) ..."
  sudo xcode-select -s "$XCODE_DEV"
fi

export DEVELOPER_DIR="$XCODE_DEV"

SDK_VERSION=$(xcrun --sdk iphoneos --show-sdk-version)
cyan "Using iphoneos SDK $SDK_VERSION"

# ── Flutter pub get ────────────────────────────────────────────────────────
cyan "Running flutter pub get ..."
flutter pub get

# ── Ensure sandboxing is off ──────────────────────────────────────────────
sed -i '' 's/ENABLE_USER_SCRIPT_SANDBOXING = YES;/ENABLE_USER_SCRIPT_SANDBOXING = NO;/g' \
  ios/Runner.xcodeproj/project.pbxproj 2>/dev/null || true

# ── Pod install ───────────────────────────────────────────────────────────
cyan "Running pod install ..."
(cd ios && pod install --repo-update)

# ── Clean old artefacts ───────────────────────────────────────────────────
cyan "Cleaning previous build ..."
rm -rf build/ios_ipa Blueprint.ipa Payload

# ── Build with xcodebuild ────────────────────────────────────────────────
cyan "Building Runner.app (this may take a few minutes) ..."

xcodebuild build \
  -workspace ios/Runner.xcworkspace \
  -scheme Runner \
  -configuration Release \
  -sdk iphoneos \
  -arch arm64 \
  -derivedDataPath build/ios_ipa \
  -quiet \
  CODE_SIGNING_ALLOWED=NO \
  CODE_SIGNING_REQUIRED=NO \
  CODE_SIGN_IDENTITY="" \
  ENABLE_USER_SCRIPT_SANDBOXING=NO \
  COMPILER_INDEX_STORE_ENABLE=NO

APP_PATH="build/ios_ipa/Build/Products/Release-iphoneos/Runner.app"

if [[ ! -f "$APP_PATH/Runner" ]]; then
  red "ERROR: Runner binary not found at $APP_PATH/Runner"
  red "The build did not produce a linked executable."
  ls -laR "$APP_PATH/" 2>/dev/null || true
  exit 1
fi

BINARY_SIZE=$(stat -f%z "$APP_PATH/Runner" 2>/dev/null \
  || stat --printf="%s" "$APP_PATH/Runner")
if [[ "$BINARY_SIZE" -lt 1000 ]]; then
  red "ERROR: Runner binary is suspiciously small (${BINARY_SIZE} bytes)."
  exit 1
fi

green "Runner binary built OK ($(( BINARY_SIZE / 1024 )) KB)"

# ── Strip ad-hoc signature (AltStore will re-sign) ───────────────────────
if command -v codesign &>/dev/null; then
  cyan "Removing ad-hoc signature (AltStore will re-sign) ..."
  codesign --remove-signature "$APP_PATH/Runner" 2>/dev/null || true
  find "$APP_PATH/Frameworks" -name "*.framework" -type d 2>/dev/null \
    | while read -r fw; do
        fw_bin="$fw/$(basename "$fw" .framework)"
        [[ -f "$fw_bin" ]] && codesign --remove-signature "$fw_bin" 2>/dev/null || true
      done
fi

# ── Package into IPA ─────────────────────────────────────────────────────
cyan "Packaging Blueprint.ipa ..."
mkdir -p Payload
cp -R "$APP_PATH" Payload/

# Drop any leftover _CodeSignature dirs
find Payload -name "_CodeSignature" -type d -exec rm -rf {} + 2>/dev/null || true

zip -rq Blueprint.ipa Payload
rm -rf Payload

IPA_SIZE=$(stat -f%z Blueprint.ipa 2>/dev/null \
  || stat --printf="%s" Blueprint.ipa)
green "============================================"
green "  Blueprint.ipa created ($(( IPA_SIZE / 1024 / 1024 )) MB)"
green "  Sideload with AltStore or Sideloadly"
green "============================================"
