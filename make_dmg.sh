#!/bin/bash
# Gerçek kurulum DMG'si oluşturur
# Kullanıcı PowerWall.app'i Applications'a sürüklediğinde:
#   1. Ses çalar (uygulama içinden)
#   2. DMG otomatik unmount olur
#   3. Uygulama başlar
set -e
cd "$(dirname "$0")"

APP="build/PowerWall.app"
DMG_NAME="PowerWall-1.0"
DMG_FINAL="build/${DMG_NAME}.dmg"
DMG_TMP="build/${DMG_NAME}-tmp.dmg"
STAGING="build/dmg-staging"
VOLUME_NAME="PowerWall"
BG_IMG="build/dmg_bg.png"

echo "▶ DMG hazırlanıyor..."

# 1. Build
bash build.sh

# 2. Arka plan
echo "  → Arka plan oluşturuluyor..."
python3 make_dmg_bg.py "$BG_IMG"

# 3. Staging
rm -rf "$STAGING"
mkdir -p "$STAGING"
cp -R "$APP" "$STAGING/PowerWall.app"
ln -s /Applications "$STAGING/Applications"
mkdir -p "$STAGING/.background"
cp "$BG_IMG" "$STAGING/.background/background.png"

# 4. Writable DMG
rm -f "$DMG_TMP" "$DMG_FINAL"
hdiutil create \
    -srcfolder "$STAGING" \
    -volname "$VOLUME_NAME" \
    -fs HFS+ \
    -fsargs "-c c=64,a=16,b=16" \
    -format UDRW \
    -size 60m \
    "$DMG_TMP"

echo "  → Mount ediliyor..."
hdiutil detach "/Volumes/${VOLUME_NAME}" 2>/dev/null || true
sleep 1

DEVICE=$(hdiutil attach -readwrite -noverify -noautoopen "$DMG_TMP" | \
         egrep '^/dev/' | sed 1q | awk '{print $1}')
echo "  → Device: $DEVICE"
sleep 2

# 5. Finder görünümü
echo "  → Finder ayarlanıyor..."
/usr/bin/osascript <<APPLESCRIPT
tell application "Finder"
    tell disk "${VOLUME_NAME}"
        open
        set current view of container window to icon view
        set toolbar visible of container window to false
        set statusbar visible of container window to false
        set the bounds of container window to {100, 100, 640, 480}
        set viewOptions to the icon view options of container window
        set arrangement of viewOptions to not arranged
        set icon size of viewOptions to 96
        set background picture of viewOptions to file ".background:background.png"
        set position of item "PowerWall.app" of container window to {152, 185}
        set position of item "Applications" of container window to {388, 185}
        close
        open
        update without registering applications
        delay 2
        close
    end tell
end tell
APPLESCRIPT

sync

# 6. Sıkıştır
hdiutil detach "$DEVICE" -force 2>/dev/null || true
sleep 2

echo "  → Sıkıştırılıyor..."
hdiutil convert "$DMG_TMP" \
    -format UDZO \
    -imagekey zlib-level=9 \
    -o "$DMG_FINAL"

rm -f "$DMG_TMP"
rm -rf "$STAGING"

echo ""
echo "✅  DMG hazır → $DMG_FINAL  ($(du -sh "$DMG_FINAL" | cut -f1))"
