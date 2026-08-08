#!/bin/bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

VERSION=$(/usr/libexec/PlistBuddy -c "Print :CFBundleShortVersionString" "build/Build/Products/Release/K-Tech PowerGuard.app/Contents/Info.plist" 2>/dev/null || echo "1.0.0")

echo "Building K-Tech PowerGuard..."
xcodebuild \
  -project "K-Tech PowerGuard.xcodeproj" \
  -scheme "K-Tech PowerGuard" \
  -configuration Release \
  -derivedDataPath build \
  CODE_SIGN_IDENTITY="-" \
  CODE_SIGNING_ALLOWED=YES \
  build

APP="build/Build/Products/Release/K-Tech PowerGuard.app"
if [[ ! -d "$APP" ]]; then
  echo "Build failed: app not found" >&2
  exit 1
fi

VERSION=$(/usr/libexec/PlistBuddy -c "Print :CFBundleShortVersionString" "$APP/Contents/Info.plist")
DMG_DIR="$ROOT/dist"
mkdir -p "$DMG_DIR"
STAGE="$DMG_DIR/stage"
DMG_NAME="K-Tech-PowerGuard-${VERSION}.dmg"
rm -rf "$STAGE" "$DMG_DIR/$DMG_NAME"
mkdir -p "$STAGE"
cp -R "$APP" "$STAGE/"
ln -s /Applications "$STAGE/Applications"

hdiutil create -volname "K-Tech PowerGuard" -srcfolder "$STAGE" -ov -format UDZO "$DMG_DIR/$DMG_NAME"
rm -rf "$STAGE"
echo "Created $DMG_DIR/$DMG_NAME"
