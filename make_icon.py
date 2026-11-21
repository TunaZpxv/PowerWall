"""
Generates an aesthetic leaf icon for PoweWall.
Deep green background, bright leaf with midrib, veins, stem, and a soft sheen.
"""
import math
import os
import sys
from PIL import Image, ImageDraw, ImageFilter

def lerp(a, b, t):
    return a + (b - a) * t

def lerp_color(c1, c2, t):
    return tuple(int(lerp(a, b, t)) for a, b in zip(c1, c2))

def rot(px, py, angle):
    ca, sa = math.cos(angle), math.sin(angle)
    return px * ca - py * sa, px * sa + py * ca

def draw_icon(size: int) -> Image.Image:
    img = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)

    s = size
    r = int(s * 0.22)   # corner radius

    # ── Background gradient (dark green) ─────────────────────────────────────
    # Draw top->bottom linear gradient inside rounded rect
    bg = Image.new("RGBA", (s, s), (0, 0, 0, 0))
    bg_draw = ImageDraw.Draw(bg)
    for y in range(s):
        t = y / s
        c = lerp_color((18, 50, 28), (8, 22, 13), t)
        bg_draw.line([(0, y), (s, y)], fill=(*c, 255))

    # Mask to rounded rect
    mask = Image.new("L", (s, s), 0)
    mask_draw = ImageDraw.Draw(mask)
    mask_draw.rounded_rectangle([0, 0, s - 1, s - 1], radius=r, fill=255)
    img.paste(bg, mask=mask)

    # ── Leaf ──────────────────────────────────────────────────────────────────
    cx, cy = s * 0.5, s * 0.5
    angle  = math.radians(-14)   # slight tilt

    lh = s * 0.44   # half-height of leaf
    lw = s * 0.33   # half-width

    def leaf_poly(steps=120):
        pts = []
        for i in range(steps + 1):
            # parametric: t goes 0→2π
            t = 2 * math.pi * i / steps
            # Lemniscate-inspired leaf: r(θ) = sin(θ) variant
            # Use simple ellipse squeezed at tips
            if t <= math.pi:
                u = t / math.pi   # 0→1 for right half
                raw_x =  lw * math.sin(math.pi * u)
                raw_y =  lh * math.cos(math.pi * u - math.pi)  # tip→tip
            else:
                u = (t - math.pi) / math.pi
                raw_x = -lw * math.sin(math.pi * u)
                raw_y =  lh * math.cos(math.pi * (1 - u))
            # taper width near tips
            taper = 1 - (abs(raw_y) / lh) ** 2.5
            px = raw_x * taper
            py = raw_y
            # rotate
            rx, ry = rot(px, py, angle)
            pts.append((cx + rx, cy - ry))
        return pts

    leaf = leaf_poly()
    # Create leaf layer
    leaf_layer = Image.new("RGBA", (s, s), (0, 0, 0, 0))
    leaf_draw = ImageDraw.Draw(leaf_layer)
    # Main fill: vivid emerald
    leaf_draw.polygon(leaf, fill=(52, 211, 100, 255))
    img = Image.alpha_composite(img, leaf_layer)
    draw = ImageDraw.Draw(img)

    # ── Midrib (center vein) ──────────────────────────────────────────────────
    tip_top_x, tip_top_y = cx + rot(0,  lh, angle)[0], cy - rot(0,  lh, angle)[1]
    tip_bot_x, tip_bot_y = cx + rot(0, -lh, angle)[0], cy - rot(0, -lh, angle)[1]

    # Cubic bezier midrib with slight curve
    def cubic_bezier_pts(p0, p1, p2, p3, steps=60):
        pts = []
        for i in range(steps + 1):
            t = i / steps
            x = ((1-t)**3 * p0[0] + 3*(1-t)**2*t * p1[0] +
                 3*(1-t)*t**2 * p2[0] + t**3 * p3[0])
            y = ((1-t)**3 * p0[1] + 3*(1-t)**2*t * p1[1] +
                 3*(1-t)*t**2 * p2[1] + t**3 * p3[1])
            pts.append((x, y))
        return pts

    # Control points for a gently curved midrib
    off1 = rot(s * 0.025,  lh * 0.25, angle)
    off2 = rot(-s * 0.018, -lh * 0.25, angle)
    cp1 = (cx + off1[0], cy - off1[1])
    cp2 = (cx + off2[0], cy - off2[1])
    midrib = cubic_bezier_pts(
        (tip_top_x, tip_top_y), cp1, cp2, (tip_bot_x, tip_bot_y)
    )

    lw_px = max(1, int(s * 0.022))
    for i in range(len(midrib) - 1):
        draw.line([midrib[i], midrib[i+1]], fill=(18, 100, 46, 160), width=lw_px)

    # ── Side veins ────────────────────────────────────────────────────────────
    vw = max(1, int(s * 0.011))
    n_veins = 5
    for vi in range(1, n_veins + 1):
        t = vi / (n_veins + 1)
        # origin on midrib
        mi = int(t * len(midrib))
        mi = min(mi, len(midrib) - 1)
        ox, oy = midrib[mi]
        # spread: wider in middle, narrower near tips
        spread = math.sin(math.pi * t) * lw * 0.72
        vangle = angle + math.radians(35)
        # right vein
        ex_r = ox + spread * math.cos(vangle)
        ey_r = oy + spread * math.sin(vangle)
        draw.line([(ox, oy), (ex_r, ey_r)], fill=(18, 100, 46, 100), width=vw)
        # left vein
        vangle_l = angle - math.radians(35) + math.radians(180)
        ex_l = ox + spread * math.cos(vangle_l)
        ey_l = oy + spread * math.sin(vangle_l)
        draw.line([(ox, oy), (ex_l, ey_l)], fill=(18, 100, 46, 100), width=vw)

    # ── Stem ──────────────────────────────────────────────────────────────────
    stem_end = rot(s * 0.045, -lh * 0.80, angle)
    stem_pts = cubic_bezier_pts(
        (tip_bot_x, tip_bot_y),
        (cx + rot(s * 0.02, -lh * 0.55, angle)[0],
         cy - rot(s * 0.02, -lh * 0.55, angle)[1]),
        (cx + stem_end[0] * 0.9, cy - stem_end[1] * 0.9),
        (cx + stem_end[0], cy - stem_end[1]),
        steps=40
    )
    sw = max(2, int(s * 0.028))
    for i in range(len(stem_pts) - 1):
        draw.line([stem_pts[i], stem_pts[i+1]], fill=(30, 130, 60, 220), width=sw)

    # ── Top-left sheen (soft white highlight) ────────────────────────────────
    sheen = Image.new("RGBA", (s, s), (0, 0, 0, 0))
    s_draw = ImageDraw.Draw(sheen)
    # Polygon covering upper-left quarter of leaf
    sheen_pts = []
    half = len(leaf) // 2
    # take top-left arc of the leaf polygon
    sheen_pts = [leaf[0]]
    for pt in leaf[half // 2 : half]:
        sheen_pts.append(pt)
    sheen_pts.append(leaf[0])
    if len(sheen_pts) >= 3:
        s_draw.polygon(sheen_pts, fill=(255, 255, 255, 36))
    sheen = sheen.filter(ImageFilter.GaussianBlur(radius=s * 0.03))
    img = Image.alpha_composite(img, sheen)

    return img


def main():
    out_dir = sys.argv[1] if len(sys.argv) > 1 else "PoweWall.iconset"
    os.makedirs(out_dir, exist_ok=True)

    sizes = [16, 32, 64, 128, 256, 512, 1024]
    for sz in sizes:
        icon = draw_icon(sz)
        path = os.path.join(out_dir, f"icon_{sz}x{sz}.png")
        icon.save(path)
        print(f"  wrote {path}")

    # @2x variants
    pairs = [
        ("icon_32x32.png",    "icon_16x16@2x.png"),
        ("icon_64x64.png",    "icon_32x32@2x.png"),
        ("icon_256x256.png",  "icon_128x128@2x.png"),
        ("icon_512x512.png",  "icon_256x256@2x.png"),
        ("icon_1024x1024.png","icon_512x512@2x.png"),
    ]
    import shutil
    for src, dst in pairs:
        shutil.copy(os.path.join(out_dir, src), os.path.join(out_dir, dst))

    print("Done. Run:  iconutil -c icns PoweWall.iconset -o PoweWall.icns")


if __name__ == "__main__":
    main()
