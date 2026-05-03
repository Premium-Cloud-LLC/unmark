#!/bin/bash
# Build and launch Unmark for local development.
# Usage: ./run.sh

set -e
cd "$(dirname "$0")"

BUILD_DIR="$(pwd)/build"
APP_PATH="$BUILD_DIR/Build/Products/Debug/Unmark.app"

echo "Building Unmark..."
xcodebuild \
    -project Unmark.xcodeproj \
    -scheme Unmark \
    -configuration Debug \
    -destination 'platform=macOS' \
    -derivedDataPath "$BUILD_DIR" \
    build > /tmp/unmark-build.log 2>&1 || { tail -50 /tmp/unmark-build.log; exit 1; }

echo "Stopping any running instance..."
pkill -x Unmark 2>/dev/null || true
sleep 0.3

echo "Launching..."
open "$APP_PATH"
echo "Look for the Unmark 'U' icon in your menu bar (top-right)."
