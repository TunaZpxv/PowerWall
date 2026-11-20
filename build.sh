#!/bin/bash
set -e
cd "$(dirname "$0")"

APP="build/PowerWall.app"
MACOS="$APP/Contents/MacOS"
RESOURCES="$APP/Contents/Resources"
BINARY="PowerWall"
SDK="/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk"
SWIFT="/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/swiftc"

rm -rf build
mkdir -p "$MACOS" "$RESOURCES"
cp PowerWall.icns "$RESOURCES/PowerWall.icns"

$SWIFT \
  Sources/main.swift \
  Sources/PowerMonitor.swift \
  Sources/WallpaperWindow.swift \
  Sources/WallpaperManager.swift \
  Sources/Prefs.swift \
  Sources/SettingsWindow.swift \
  Sources/AppDelegate.swift \
  -o "$MACOS/$BINARY" \
  -framework AppKit \
  -framework AVFoundation \
  -framework AVKit \
  -framework IOKit \
  -swift-version 5 \
  -sdk "$SDK" \
  -target arm64-apple-macos14.0

cat > "$APP/Contents/Info.plist" << 'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleName</key><string>PowerWall</string>
    <key>CFBundleDisplayName</key><string>PowerWall</string>
    <key>CFBundleIdentifier</key><string>com.powerwall.app</string>
    <key>CFBundleExecutable</key><string>PowerWall</string>
    <key>CFBundleIconFile</key><string>PowerWall</string>
    <key>CFBundlePackageType</key><string>APPL</string>
    <key>CFBundleShortVersionString</key><string>1.0</string>
    <key>LSUIElement</key><true/>
    <key>NSHighResolutionCapable</key><true/>
    <key>LSMinimumSystemVersion</key><string>14.0</string>
</dict>
</plist>
PLIST

codesign --force --deep --sign - "$APP" 2>/dev/null || true
echo "✅  Build tamam → $APP"
