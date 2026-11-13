"""Builds Play Store art for Sling Arena from the raw renders.

Inputs : store_assets/raw/*.png (from test/store_screens_test.dart), assets/branding/*.png, assets/fonts/*.ttf
Outputs: fastlane/metadata/android/en-US/images/
           icon.png                      512 x 512
           featureGraphic.png            1024 x 500
           phoneScreenshots/N_en-US.png  1080 x 1920

Run from the project root:  python tool/make_store_art.py
"""
import os

from PIL import Image, ImageDraw, ImageFilter, ImageFont

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
RAW = os.path.join(ROOT, "store_assets", "raw")
OUT = os.path.join(ROOT, "fastlane", "metadata", "android", "en-US", "images")
SHOTS = os.path.join(OUT, "phoneScreenshots")
LILITA = os.path.join(ROOT, "assets", "fonts", "LilitaOne-Regular.ttf")
NUNITO = os.path.join(ROOT, "assets", "fonts", "Nunito.ttf")

NAVY_TOP = (36, 53, 94)
NAVY = (14, 22, 38)
NAVY_DEEP = (9, 14, 25)
GOLD = (255, 181, 71)
CHALK = (243, 241, 234)
MUTED = (178, 188, 208)

SLIDES = [
    ("1_home", "FLICK. SLIDE. WIN!", "The glossy sling puck showdown", (255, 138, 61)),
    ("2_match", "THREAD THE GAP", "Clear your side before the bot does", (61, 214, 245)),
    ("3_modes", "6 WAYS TO PLAY", "Bots, Pass & Play, Cups, Time Attack", (255, 181, 71)),
    ("4_victory", "STARS & CHESTS", "Rewards, level-ups and achievements", (255, 181, 71)),
    ("5_store", "STYLE YOUR ARENA", "Pucks, boards, bands and trail effects", (148, 103, 240)),
    ("6_profile", "CLIMB THE RANKS", "12 achievements, stats and streaks", (61, 214, 245)),
]


def font(path, size, weight=None):
    f = ImageFont.truetype(path, size)
    if weight is not None:
        try:
            f.set_variation_by_axes([weight])
        except Exception:
            pass
    return f


def vgrad(w, h, top, bottom):
    img = Image.new("RGB", (w, h))
    d = ImageDraw.Draw(img)
    for y in range(h):
        t = y / max(1, h - 1)
        d.line((0, y, w, y), fill=tuple(int(top[i] + (bottom[i] - top[i]) * t) for i in range(3)))
    return img


def glow(size, center, radius, color, alpha):
    layer = Image.new("RGBA", size, (0, 0, 0, 0))
    d = ImageDraw.Draw(layer)
    steps = 60
    for i in range(steps, 0, -1):
        r = radius * i / steps
        a = int(alpha * (1 - i / steps) ** 1.6)
        d.ellipse((center[0] - r, center[1] - r, center[0] + r, center[1] + r), fill=color + (a,))
    return layer.filter(ImageFilter.GaussianBlur(radius * 0.08))


def puck(diameter, light, base, dark):
    s = diameter * 2
    layer = Image.new("RGBA", (s, s), (0, 0, 0, 0))
    c = s / 2
    r = diameter / 2
    sh = Image.new("RGBA", (s, s), (0, 0, 0, 0))
    ImageDraw.Draw(sh).ellipse((c - r, c - r + r * 0.3, c + r, c + r + r * 0.3), fill=(0, 0, 0, 140))
    layer.alpha_composite(sh.filter(ImageFilter.GaussianBlur(r * 0.15)))
    body = Image.new("RGBA", (s, s), (0, 0, 0, 0))
    bd = ImageDraw.Draw(body)
    for i in range(int(r * 1.5), 0, -1):
        t = i / (r * 1.5)
        if t < 0.35:
            col = tuple(int(light[k] + (base[k] - light[k]) * t / 0.35) for k in range(3))
        else:
            col = tuple(int(base[k] + (dark[k] - base[k]) * min(1, (t - 0.35) / 0.5)) for k in range(3))
        cx, cy = c - r * 0.25, c - r * 0.4
        bd.ellipse((cx - i, cy - i, cx + i, cy + i), fill=col + (255,))
    mask = Image.new("L", (s, s), 0)
    ImageDraw.Draw(mask).ellipse((c - r, c - r, c + r, c + r), fill=255)
    layer.paste(body, (0, 0), mask)
    hl = Image.new("RGBA", (s, s), (0, 0, 0, 0))
    ImageDraw.Draw(hl).ellipse((c - r * 0.65, c - r * 0.78, c + r * 0.3, c - r * 0.18), fill=(255, 255, 255, 150))
    layer.alpha_composite(hl.filter(ImageFilter.GaussianBlur(r * 0.06)))
    return layer


PUCKS = {
    "ember": ((255, 214, 176), (255, 138, 61), (160, 64, 10)),
    "tide": ((201, 246, 255), (61, 214, 245), (15, 110, 140)),
    "gold": ((255, 243, 196), (255, 181, 71), (138, 90, 12)),
    "void": ((224, 212, 255), (122, 85, 232), (32, 16, 79)),
}


def outlined_text(draw, xy, text, fnt, fill, outline, stroke, shadow=True, anchor="mm"):
    if shadow:
        draw.text((xy[0], xy[1] + stroke * 1.4), text, font=fnt, fill=outline, anchor=anchor,
                  stroke_width=stroke, stroke_fill=outline)
    draw.text(xy, text, font=fnt, fill=fill, anchor=anchor, stroke_width=stroke, stroke_fill=outline)


def fit_font(path, text, max_w, start, weight=None):
    size = start
    while size > 20:
        f = font(path, size, weight)
        if f.getbbox(text)[2] - f.getbbox(text)[0] <= max_w:
            return f
        size -= 4
    return font(path, size, weight)


def phone_frame(shot, height):
    """Metal-rimmed phone with the screenshot inside, rounded, with soft shadow."""
    w = int(shot.width * height / shot.height)
    screen = shot.convert("RGB").resize((w, height), Image.LANCZOS)
    rim = 16
    radius = 64
    fw, fh = w + rim * 2, height + rim * 2
    frame = Image.new("RGBA", (fw + 120, fh + 160), (0, 0, 0, 0))
    ox, oy = 60, 40
    shadow = Image.new("RGBA", frame.size, (0, 0, 0, 0))
    ImageDraw.Draw(shadow).rounded_rectangle((ox + 10, oy + 40, ox + fw - 10, oy + fh + 40), radius=radius, fill=(0, 0, 0, 170))
    frame.alpha_composite(shadow.filter(ImageFilter.GaussianBlur(34)))
    metal = vgrad(fw, fh, (244, 247, 251), (91, 101, 119)).convert("RGBA")
    m = Image.new("L", (fw, fh), 0)
    ImageDraw.Draw(m).rounded_rectangle((0, 0, fw - 1, fh - 1), radius=radius, fill=255)
    frame.paste(metal, (ox, oy), m)
    sm = Image.new("L", (w, height), 0)
    ImageDraw.Draw(sm).rounded_rectangle((0, 0, w - 1, height - 1), radius=radius - rim, fill=255)
    frame.paste(screen, (ox + rim, oy + rim), sm)
    return frame


def background(w, h, accent):
    bg = vgrad(w, h, NAVY_TOP, NAVY_DEEP).convert("RGBA")
    bg.alpha_composite(glow((w, h), (w * 0.5, h * 0.62), w * 0.75, accent, 120))
    bg.alpha_composite(glow((w, h), (w * 0.5, h * 0.05), w * 0.6, (255, 255, 255), 25))
    return bg


def screenshot(raw_name, title, subtitle, accent, index):
    W, H = 1080, 1920
    img = background(W, H, accent)
    # Floating decorative pucks
    for name, x, y, d in [("ember", 70, 300, 120), ("tide", 980, 470, 96), ("gold", 1010, 1640, 130), ("void", 40, 1500, 90)]:
        p = puck(d, *PUCKS[name])
        img.alpha_composite(p, (int(x - p.width / 2), int(y - p.height / 2)))
    d = ImageDraw.Draw(img)
    tfont = fit_font(LILITA, title, W - 120, 118)
    outlined_text(d, (W / 2, 150), title, tfont, CHALK if index % 2 else GOLD, (60, 24, 4) if index % 2 == 0 else (24, 34, 60), 6)
    sfont = font(NUNITO, 46, 800)
    d.text((W / 2, 262), subtitle, font=sfont, fill=MUTED, anchor="mm")
    shot = Image.open(os.path.join(RAW, raw_name + ".png"))
    frame = phone_frame(shot, 1500)
    img.alpha_composite(frame, (int((W - frame.width) / 2), 330))
    return img.convert("RGB")


def feature_graphic():
    W, H = 1024, 500
    img = vgrad(W, H, NAVY_TOP, NAVY_DEEP).convert("RGBA")
    img.alpha_composite(glow((W, H), (300, 260), 420, (255, 138, 61), 140))
    img.alpha_composite(glow((W, H), (820, 120), 300, (61, 214, 245), 70))
    logo = Image.open(os.path.join(ROOT, "assets", "branding", "logo.png")).convert("RGBA").resize((330, 330), Image.LANCZOS)
    sh = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    ImageDraw.Draw(sh).rounded_rectangle((95, 110, 425, 440), radius=76, fill=(0, 0, 0, 160))
    img.alpha_composite(sh.filter(ImageFilter.GaussianBlur(22)))
    img.alpha_composite(logo, (90, 85))
    for name, x, y, dmt in [("gold", 960, 430, 90), ("tide", 470, 60, 60), ("ember", 985, 70, 70)]:
        p = puck(dmt, *PUCKS[name])
        img.alpha_composite(p, (int(x - p.width / 2), int(y - p.height / 2)))
    d = ImageDraw.Draw(img)
    big = font(LILITA, 112)
    outlined_text(d, (720, 168), "SLING", big, CHALK, (120, 50, 12), 5)
    outlined_text(d, (720, 282), "ARENA", big, GOLD, (100, 52, 6), 5)
    d.text((720, 378), "FLICK · SLIDE · CLEAR YOUR SIDE", font=font(NUNITO, 26, 900), fill=MUTED, anchor="mm")
    return img.convert("RGB")


def main():
    os.makedirs(SHOTS, exist_ok=True)
    icon = Image.open(os.path.join(ROOT, "assets", "branding", "icon.png")).convert("RGB").resize((512, 512), Image.LANCZOS)
    icon.save(os.path.join(OUT, "icon.png"))
    feature_graphic().save(os.path.join(OUT, "featureGraphic.png"))
    for i, (raw, title, sub, accent) in enumerate(SLIDES):
        screenshot(raw, title, sub, accent, i).save(os.path.join(SHOTS, f"{i + 1}_en-US.png"))
    print("Store art written to", OUT)


if __name__ == "__main__":
    main()
