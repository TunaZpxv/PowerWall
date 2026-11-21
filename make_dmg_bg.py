"""
DMG background — green gradient, real icons, clean arrow.
Canvas: 540x380
"""
import math, os, sys
from PIL import Image, ImageDraw, ImageFilter, ImageFont

W, H = 540, 380

def lerp_color(c1, c2, t):
    return tuple(int(c1[i] + (c2[i] - c1[i]) * t) for i in range(len(c1)))

def load_font(size):
    candidates = [
        "/System/Library/Fonts/SFCompact.ttf",
        "/System/Library/Fonts/Helvetica.ttc",
        "/System/Library/Fonts/HelveticaNeue.ttc",
    ]
    for p in candidates:
        if os.path.exists(p):
            try: return ImageFont.truetype(p, size)
            except: continue
    return ImageFont.load_default()

# ── Background: deep green gradient ──────────────────────────────────────────
bg = Image.new("RGB", (W, H))
for y in range(H):
    t = y / H
    c = lerp_color((18, 56, 28), (10, 36, 18), t)
    ImageDraw.Draw(bg).line([(0, y), (W, y)], fill=c)

# Vignette
vign = Image.new("RGBA", (W, H), (0,0,0,0))
vd = ImageDraw.Draw(vign)
for i in range(80):
    a = int(100 * (1 - i/80))
    vd.rectangle([i,i,W-i,H-i], outline=(0,0,0,a))
bg = Image.alpha_composite(bg.convert("RGBA"), vign)

# Subtle dot grid
dot = Image.new("RGBA",(W,H),(0,0,0,0))
dd = ImageDraw.Draw(dot)
for gx in range(0,W,24):
    for gy in range(0,H,24):
        dd.ellipse([gx,gy,gx+1,gy+1], fill=(255,255,255,14))
bg = Image.alpha_composite(bg, dot)

# ── Extract real icons ────────────────────────────────────────────────────────
app_path    = "/tmp/_pw_app_icon.png"
folder_path = "/tmp/_pw_folder_icon.png"
os.system(f"sips -s format png /Users/tunasia/Desktop/PoweWall/PoweWall.icns --out {app_path} -z 96 96 >/dev/null 2>&1")
os.system(f"sips -s format png /System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/ApplicationsFolderIcon.icns --out {folder_path} -z 96 96 >/dev/null 2>&1")

app_icon    = Image.open(app_path).convert("RGBA")
folder_icon = Image.open(folder_path).convert("RGBA")

ICON = 96
LEFT_X  = 140 - ICON//2   # 92
RIGHT_X = 400 - ICON//2   # 352
ICON_Y  = H//2 - ICON//2 - 14

bg.paste(app_icon,    (LEFT_X,  ICON_Y), app_icon)
bg.paste(folder_icon, (RIGHT_X, ICON_Y), folder_icon)

# ── Arrow ────────────────────────────────────────────────────────────────────
draw = ImageDraw.Draw(bg)
arrow_y  = ICON_Y + ICON//2
ax_start = LEFT_X + ICON + 16
ax_end   = RIGHT_X - 16

# Shaft
draw.line([(ax_start, arrow_y),(ax_end, arrow_y)], fill=(255,255,255,130), width=2)
# Head
tip = ax_end
draw.polygon([(tip,arrow_y),(tip-13,arrow_y-6),(tip-13,arrow_y+6)],
             fill=(255,255,255,130))

# ── Labels ────────────────────────────────────────────────────────────────────
font_name  = load_font(14)
font_ver   = load_font(10)
LABEL_Y    = ICON_Y + ICON + 10

def centered_at(draw, text, font, cx, y, color):
    bb = draw.textbbox((0,0), text, font=font)
    tw = bb[2]-bb[0]
    draw.text((cx - tw//2, y), text, font=font, fill=color)

centered_at(draw, "PoweWall",   font_name, 140, LABEL_Y,   (255,255,255,220))
centered_at(draw, "Applications",font_name, 400, LABEL_Y,   (255,255,255,220))

ver = "PoweWall 1.0  ·  Requires macOS 14+"
vbb = draw.textbbox((0,0), ver, font=font_ver)
vw = vbb[2]-vbb[0]
draw.text(((W-vw)//2, H-22), ver, font=font_ver, fill=(255,255,255,55))

# ── Save ─────────────────────────────────────────────────────────────────────
out = sys.argv[1] if len(sys.argv)>1 else "/tmp/dmg_bg.png"
bg.convert("RGB").save(out, quality=95)
print(f"  Background saved → {out}  ({W}×{H})")
