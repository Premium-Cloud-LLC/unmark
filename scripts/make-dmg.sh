#!/bin/bash
# make-dmg.sh — Build, sign, notarize, and package Unmark as a DMG.
#
# Prerequisites (one-time setup):
#   1. brew install create-dmg
#   2. Apple Developer Program enrollment ($99/yr)
#   3. A "Developer ID Application" certificate installed in Keychain
#   4. App-specific password for notarytool (see below)
#
# To set up notarytool credentials (one-time):
#   xcrun notarytool store-credentials "AC_NOTARYTOOL" \
#       --apple-id "your-apple-id@example.com" \
#       --team-id "YOUR10CHARID" \
#       --password "your-app-specific-password"
#
# To create an app-specific password:
#   1. Go to appleid.apple.com → Sign-In and Security → App-Specific Passwords
#   2. Generate one labeled "notarytool"
#   3. Use it in the store-credentials call above
#
# Usage: ./scripts/make-dmg.sh

set -euo pipefail
cd "$(dirname "$0")/.."

# === CONFIG — edit these for your account ===
APP_NAME="Unmark"
BUNDLE_ID="com.unmark.Unmark"
DEVELOPER_ID="Developer ID Application: Your Name (YOUR10CHARID)"  # << SET
NOTARY_PROFILE="AC_NOTARYTOOL"  # name from notarytool store-credentials

# === DERIVED PATHS ===
BUILD_DIR="$(pwd)/build"
EXPORT_DIR="$BUILD_DIR/Export"
DIST_DIR="$(pwd)/dist"
APP_PATH="$EXPORT_DIR/$APP_NAME.app"
DMG_PATH="$DIST_DIR/$APP_NAME.dmg"
LOGS_DIR="$BUILD_DIR/Logs"

mkdir -p "$DIST_DIR" "$LOGS_DIR"
rm -rf "$EXPORT_DIR" "$DMG_PATH"

# === 1. ARCHIVE ===
echo "==> Archiving Release build..."
xcodebuild \
    -project Unmark.xcodeproj \
    -scheme Unmark \
    -configuration Release \
    -destination 'generic/platform=macOS' \
    -archivePath "$BUILD_DIR/Unmark.xcarchive" \
    -derivedDataPath "$BUILD_DIR" \
    CODE_SIGN_STYLE=Manual \
    CODE_SIGN_IDENTITY="$DEVELOPER_ID" \
    archive | tee "$LOGS_DIR/archive.log" | grep -E "error:|^\*\*" || true

# === 2. EXPORT (Developer ID, no provisioning profile needed) ===
echo "==> Exporting signed .app..."
EXPORT_PLIST="$BUILD_DIR/ExportOptions.plist"
cat > "$EXPORT_PLIST" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>method</key>
    <string>developer-id</string>
    <key>signingStyle</key>
    <string>manual</string>
    <key>teamID</key>
    <string>YOUR10CHARID</string>
</dict>
</plist>
EOF

xcodebuild \
    -exportArchive \
    -archivePath "$BUILD_DIR/Unmark.xcarchive" \
    -exportPath "$EXPORT_DIR" \
    -exportOptionsPlist "$EXPORT_PLIST" \
    | tee "$LOGS_DIR/export.log" | grep -E "error:|^\*\*" || true

if [ ! -d "$APP_PATH" ]; then
    echo "ERROR: Export did not produce $APP_PATH"
    exit 1
fi

# === 3. NOTARIZE THE .app ===
echo "==> Submitting .app to Apple notary service (this can take 5-15 min)..."
NOTARY_ZIP="$BUILD_DIR/Unmark-notary.zip"
ditto -c -k --sequesterRsrc --keepParent "$APP_PATH" "$NOTARY_ZIP"

xcrun notarytool submit "$NOTARY_ZIP" \
    --keychain-profile "$NOTARY_PROFILE" \
    --wait | tee "$LOGS_DIR/notarize.log"

# === 4. STAPLE THE NOTARIZATION TICKET ===
echo "==> Stapling notarization ticket to .app..."
xcrun stapler staple "$APP_PATH"
xcrun stapler validate "$APP_PATH"

# === 5. BUILD DMG ===
echo "==> Building DMG..."
DMG_BACKGROUND="Logos/DMG Background.png"
DMG_VOLUME_ICON="Logos/DMG Volume Icon.png"

# Convert volume icon to .icns format if create-dmg requires it
# (create-dmg accepts .png natively in newer versions; if yours doesn't, convert with iconutil)

CREATE_DMG_ARGS=(
    --volname "$APP_NAME"
    --window-pos 200 120
    --window-size 600 400
    --icon-size 100
    --icon "$APP_NAME.app" 150 200
    --hide-extension "$APP_NAME.app"
    --app-drop-link 450 200
    --no-internet-enable
)

# Add background if it exists
if [ -f "$DMG_BACKGROUND" ]; then
    CREATE_DMG_ARGS+=(--background "$DMG_BACKGROUND")
fi

# Add volume icon if it exists
if [ -f "$DMG_VOLUME_ICON" ]; then
    CREATE_DMG_ARGS+=(--volicon "$DMG_VOLUME_ICON")
fi

create-dmg \
    "${CREATE_DMG_ARGS[@]}" \
    "$DMG_PATH" \
    "$APP_PATH"

# === 6. SIGN AND NOTARIZE THE DMG ITSELF ===
echo "==> Signing DMG..."
codesign --force --sign "$DEVELOPER_ID" --timestamp "$DMG_PATH"

echo "==> Submitting DMG to Apple notary service..."
xcrun notarytool submit "$DMG_PATH" \
    --keychain-profile "$NOTARY_PROFILE" \
    --wait | tee "$LOGS_DIR/notarize-dmg.log"

echo "==> Stapling DMG..."
xcrun stapler staple "$DMG_PATH"
xcrun stapler validate "$DMG_PATH"

# === 7. DONE ===
echo ""
echo "==========================================="
echo "Done! Distributable DMG ready at:"
echo "  $DMG_PATH"
echo "==========================================="
echo ""
echo "Test it before distributing:"
echo "  1. Move the DMG to a different Mac (or Downloads on this one)"
echo "  2. Double-click to mount"
echo "  3. Verify the install window looks correct"
echo "  4. Drag Unmark.app to Applications"
echo "  5. Launch — Gatekeeper should NOT show any warning"
echo ""
echo "Upload the DMG to GitHub Releases, your S3, or wherever you host."
