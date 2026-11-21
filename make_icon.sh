#!/bin/bash
# Generates an aesthetic leaf app icon (PoweWall.icns)
set -e
cd "$(dirname "$0")"

ICONSET="PoweWall.iconset"
rm -rf "$ICONSET"
mkdir "$ICONSET"

# Draw the icon at a given size using Python + Quartz
draw_icon() {
    local SIZE=$1
    local OUT=$2
    python3 - "$SIZE" "$OUT" <<'PYEOF'
import sys, math
import Quartz
from Quartz import (
    CGColorSpaceCreateDeviceRGB, CGBitmapContextCreate,
    CGBitmapContextCreateImage, kCGBitmapByteOrder32Host,
    kCGImageAlphaPremultipliedFirst, CGContextSaveGState,
    CGContextRestoreGState, CGContextTranslateCTM, CGContextScaleCTM,
    CGContextSetFillColorWithColor, CGContextFillRect,
    CGContextBeginPath, CGContextMoveToPoint, CGContextAddCurveToPoint,
    CGContextClosePath, CGContextFillPath, CGContextSetAlpha,
    CGContextAddLineToPoint, CGContextStrokePath,
    CGContextSetStrokeColorWithColor, CGContextSetLineWidth,
    CGContextSetLineCap, CGContextSetLineJoin,
    CGContextAddArcToPoint,
)
from Quartz import CGRectMake
import CoreGraphics as CG

size = int(sys.argv[1])
out  = sys.argv[2]

cs = CGColorSpaceCreateDeviceRGB()
ctx = CGBitmapContextCreate(
    None, size, size, 8, 0, cs,
    kCGBitmapByteOrder32Host | kCGImageAlphaPremultipliedFirst
)

s = size

# ── Background: rounded rect with deep green gradient ──────────────────────
# Draw rounded rect as a path
pad = s * 0.12
r   = s * 0.22   # corner radius

def rounded_rect(ctx, x, y, w, h, r):
    CGContextBeginPath(ctx)
    CGContextMoveToPoint(ctx, x + r, y)
    CGContextAddLineToPoint(ctx, x + w - r, y)
    CGContextAddArcToPoint(ctx, x + w, y, x + w, y + r, r)
    CGContextAddLineToPoint(ctx, x + w, y + h - r)
    CGContextAddArcToPoint(ctx, x + w, y + h, x + w - r, y + h, r)
    CGContextAddLineToPoint(ctx, x + r, y + h)
    CGContextAddArcToPoint(ctx, x, y + h, x, y + h - r, r)
    CGContextAddLineToPoint(ctx, x, y + r)
    CGContextAddArcToPoint(ctx, x, y, x + r, y, r)
    CGContextClosePath(ctx)

# Gradient via two-pass fill trick
# Dark bg first
rounded_rect(ctx, 0, 0, s, s, r)
CGContextSetFillColorWithColor(ctx, CG.CGColorCreate(cs, [0.04, 0.12, 0.07, 1.0]))
CGContextFillPath(ctx)

# Lighter overlay at top
rounded_rect(ctx, 0, s * 0.5, s, s * 0.5, r)
CGContextSetFillColorWithColor(ctx, CG.CGColorCreate(cs, [0.07, 0.22, 0.13, 0.6]))
CGContextFillPath(ctx)

# ── Leaf shape (centered, slight tilt) ──────────────────────────────────────
CGContextSaveGState(ctx)

cx, cy = s * 0.5, s * 0.5
CGContextTranslateCTM(ctx, cx, cy)
# tilt 15 degrees
angle = -15 * math.pi / 180
CGContextScaleCTM(ctx, 1, 1)

lw = s * 0.34   # leaf half-width
lh = s * 0.44   # leaf half-height

# Leaf is a symmetric lens shape drawn with two cubic curves
# Rotate coordinate system
import math
ca, sa = math.cos(angle), math.sin(angle)
def rot(px, py):
    return px * ca - py * sa, px * sa + py * ca

# Points in leaf-local coords (0,0 = center)
tip_top = rot(0,  lh)
tip_bot = rot(0, -lh)
ctrl_r1 = rot( lw,  lh * 0.3)
ctrl_r2 = rot( lw, -lh * 0.3)
ctrl_l1 = rot(-lw,  lh * 0.3)
ctrl_l2 = rot(-lw, -lh * 0.3)

CGContextBeginPath(ctx)
CGContextMoveToPoint(ctx, tip_top[0], tip_top[1])
CGContextAddCurveToPoint(ctx,
    ctrl_r1[0], ctrl_r1[1],
    ctrl_r2[0], ctrl_r2[1],
    tip_bot[0], tip_bot[1]
)
CGContextAddCurveToPoint(ctx,
    ctrl_l2[0], ctrl_l2[1],
    ctrl_l1[0], ctrl_l1[1],
    tip_top[0], tip_top[1]
)
CGContextClosePath(ctx)

# Fill leaf: bright green
CGContextSetFillColorWithColor(ctx, CG.CGColorCreate(cs, [0.22, 0.85, 0.42, 1.0]))
CGContextFillPath(ctx)

# ── Leaf highlight (top-left sheen) ───────────────────────────────────────
CGContextBeginPath(ctx)
CGContextMoveToPoint(ctx, tip_top[0], tip_top[1])
CGContextAddCurveToPoint(ctx,
    ctrl_l1[0] * 0.5, ctrl_l1[1] * 0.5,
    0, lh * 0.1,
    0, 0
)
CGContextAddCurveToPoint(ctx,
    0, lh * 0.4,
    tip_top[0] * 0.6, tip_top[1] * 0.8,
    tip_top[0], tip_top[1]
)
CGContextClosePath(ctx)
CGContextSetFillColorWithColor(ctx, CG.CGColorCreate(cs, [1.0, 1.0, 1.0, 0.18]))
CGContextFillPath(ctx)

# ── Midrib (center vein line) ─────────────────────────────────────────────
CGContextBeginPath(ctx)
CGContextMoveToPoint(ctx, tip_top[0], tip_top[1])
# slight curve to bottom tip
mx1, my1 = rot(s * 0.03, lh * 0.2)
mx2, my2 = rot(-s * 0.02, -lh * 0.3)
CGContextAddCurveToPoint(ctx, mx1, my1, mx2, my2, tip_bot[0], tip_bot[1])
CGContextSetStrokeColorWithColor(ctx, CG.CGColorCreate(cs, [0.05, 0.40, 0.18, 0.55]))
CGContextSetLineWidth(ctx, s * 0.022)
CGContextSetLineCap(ctx, 1)   # kCGLineCapRound
CGContextStrokePath(ctx)

# ── Side veins ────────────────────────────────────────────────────────────
vein_alpha = 0.30
CGContextSetStrokeColorWithColor(ctx, CG.CGColorCreate(cs, [0.05, 0.40, 0.18, vein_alpha]))
CGContextSetLineWidth(ctx, s * 0.012)
# 3 veins on each side
for i in range(1, 4):
    t = i / 4.5
    # vein origin on midrib
    ox, oy = rot(0, lh * (0.6 - t * 1.0))
    # vein tip on right edge
    ex, ey = rot(lw * 0.7 * (1 - abs(t - 0.4)), lh * (0.5 - t * 1.1))
    CGContextBeginPath(ctx)
    CGContextMoveToPoint(ctx, ox, oy)
    CGContextAddLineToPoint(ctx, ex, ey)
    CGContextStrokePath(ctx)
    # mirror on left
    ox2, oy2 = rot(0, lh * (0.6 - t * 1.0))
    ex2, ey2 = rot(-lw * 0.7 * (1 - abs(t - 0.4)), lh * (0.5 - t * 1.1))
    CGContextBeginPath(ctx)
    CGContextMoveToPoint(ctx, ox2, oy2)
    CGContextAddLineToPoint(ctx, ex2, ey2)
    CGContextStrokePath(ctx)

# ── Stem ──────────────────────────────────────────────────────────────────
stem_x, stem_y = rot(s * 0.04, -lh * 0.72)
CGContextBeginPath(ctx)
CGContextMoveToPoint(ctx, tip_bot[0], tip_bot[1])
CGContextAddCurveToPoint(ctx,
    rot(s * 0.02, -lh * 0.55)[0], rot(s * 0.02, -lh * 0.55)[1],
    stem_x * 0.9, stem_y * 0.9,
    stem_x, stem_y
)
CGContextSetStrokeColorWithColor(ctx, CG.CGColorCreate(cs, [0.14, 0.60, 0.28, 0.9]))
CGContextSetLineWidth(ctx, s * 0.030)
CGContextSetLineCap(ctx, 1)
CGContextStrokePath(ctx)

CGContextRestoreGState(ctx)

# ── Write PNG ─────────────────────────────────────────────────────────────
img = CGBitmapContextCreateImage(ctx)
url = CG.CFURLCreateWithFileSystemPath(None, out, 0, False)
dest = CG.CGImageDestinationCreateWithURL(url, "public.png", 1, None)
CG.CGImageDestinationAddImage(dest, img, None)
CG.CGImageDestinationFinalize(dest)
print(f"  wrote {out} ({size}x{size})")
PYEOF
}

SIZES=(16 32 64 128 256 512 1024)
for SZ in "${SIZES[@]}"; do
    draw_icon $SZ "$ICONSET/icon_${SZ}x${SZ}.png"
done

# Also create @2x versions
cp "$ICONSET/icon_32x32.png"   "$ICONSET/icon_16x16@2x.png"
cp "$ICONSET/icon_64x64.png"   "$ICONSET/icon_32x32@2x.png"
cp "$ICONSET/icon_256x256.png" "$ICONSET/icon_128x128@2x.png"
cp "$ICONSET/icon_512x512.png" "$ICONSET/icon_256x256@2x.png"
cp "$ICONSET/icon_1024x1024.png" "$ICONSET/icon_512x512@2x.png"

iconutil -c icns "$ICONSET" -o PoweWall.icns
rm -rf "$ICONSET"
echo "✅  PoweWall.icns oluşturuldu"
