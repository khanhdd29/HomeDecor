#!/usr/bin/env python3
"""Compose App Store *marketing* screenshots for Abodi.

Each frame = branded Coral-Glass background + a bold two-tone headline + the
real app screenshot inside a phone mockup. Output 1206x2622 (iPhone Dynamic
Island "medium display" slot). Re-run after recapturing the raw app screens:

    python3 scripts/store/make_screenshots.py

Raw app screens (1206x2622) are read from scripts/store/shots/ ; put recaptured
ones there (xcrun simctl io "iPhone 17 Pro" screenshot <name>.png).
"""
import pathlib
from PIL import Image, ImageDraw, ImageFont, ImageFilter

ROOT = pathlib.Path(__file__).resolve().parents[2]
SHOTS = pathlib.Path(__file__).resolve().parent / "shots"
OUT = ROOT / "AppStore" / "screenshots" / "en"
SRC = ROOT / "AppStore" / "screenshots" / "src-1290x2796"

W, H = 1206, 2622
INK = (43, 39, 36)
CORAL = (239, 91, 58)

# Background gradient (top warm peach -> soft light), matching Coral Glass.
TOP = (251, 227, 214)
BOT = (236, 231, 227)


def load_font(size, bold=True):
    # Prefer SF Pro (matches iOS); fall back to Arial Bold.
    try:
        f = ImageFont.truetype("/System/Library/Fonts/SFNS.ttf", size)
        if bold:
            try: f.set_variation_by_name("Bold")
            except Exception:
                try: f.set_variation_by_axes([700])
                except Exception: pass
        return f
    except Exception:
        p = "/System/Library/Fonts/Supplemental/Arial Bold.ttf" if bold \
            else "/System/Library/Fonts/Supplemental/Arial.ttf"
        return ImageFont.truetype(p, size)


def background():
    bg = Image.new("RGB", (W, H))
    px = bg.load()
    for y in range(H):
        t = y / H
        px0 = tuple(round(TOP[i] + (BOT[i] - TOP[i]) * t) for i in range(3))
        for x in range(W):
            px[x, y] = px0
    # Soft coral glow blobs for depth.
    glow = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    gd = ImageDraw.Draw(glow)
    gd.ellipse([-260, -200, 520, 560], fill=(255, 158, 120, 70))
    gd.ellipse([820, 120, 1500, 820], fill=(239, 91, 58, 45))
    glow = glow.filter(ImageFilter.GaussianBlur(170))
    bg = Image.alpha_composite(bg.convert("RGBA"), glow)
    return bg.convert("RGB")


def rounded_mask(size, radius):
    m = Image.new("L", size, 0)
    ImageDraw.Draw(m).rounded_rectangle([0, 0, size[0] - 1, size[1] - 1], radius=radius, fill=255)
    return m


def draw_centered(draw, text, font, y, fill):
    w = draw.textbbox((0, 0), text, font=font)[2]
    draw.text(((W - w) / 2, y), text, font=font, fill=fill)


def fit_font(draw, lines, max_size=112, min_size=66, margin=130):
    """Largest font (<= max_size) where every line fits within W - margin."""
    size = max_size
    while size > min_size:
        f = load_font(size)
        if all(draw.textbbox((0, 0), ln, font=f)[2] <= W - margin for ln in lines):
            return f, size
        size -= 2
    return load_font(min_size), min_size


def render(shot_name, line1, line2, out_name):
    canvas = background()
    draw = ImageDraw.Draw(canvas)

    # Headline (two lines, two-tone) — auto-fit so long lines never clip.
    font, size = fit_font(draw, [line1, line2])
    lh = round(size * 1.18)
    top = 150
    draw_centered(draw, line1, font, top, INK)
    draw_centered(draw, line2, font, top + lh, CORAL)

    # Phone mockup with the real screenshot.
    shot = Image.open(SHOTS / shot_name).convert("RGB")
    screen_w = 726
    screen_h = round(screen_w * H / W)          # keep the 1206:2622 aspect
    shot = shot.resize((screen_w, screen_h), Image.LANCZOS)
    s_rad = 96
    shot.putalpha(rounded_mask((screen_w, screen_h), s_rad))

    bezel = 22
    pw, ph = screen_w + 2 * bezel, screen_h + 2 * bezel
    phone = Image.new("RGBA", (pw, ph), (0, 0, 0, 0))
    ImageDraw.Draw(phone).rounded_rectangle([0, 0, pw - 1, ph - 1], radius=s_rad + bezel,
                                            fill=(26, 26, 28, 255))
    phone.alpha_composite(shot, (bezel, bezel))

    px = (W - pw) // 2
    py = 470
    # Drop shadow.
    shadow = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    ImageDraw.Draw(shadow).rounded_rectangle([px, py + 26, px + pw, py + ph + 26],
                                             radius=s_rad + bezel, fill=(80, 40, 25, 90))
    shadow = shadow.filter(ImageFilter.GaussianBlur(44))
    canvas = Image.alpha_composite(canvas.convert("RGBA"), shadow)
    canvas.alpha_composite(phone, (px, py))

    OUT.mkdir(parents=True, exist_ok=True)
    SRC.mkdir(parents=True, exist_ok=True)
    final = canvas.convert("RGB")
    final.save(OUT / out_name)
    # 6.9" source copy at 1290x2796.
    final.resize((1290, 2796), Image.LANCZOS).save(SRC / out_name)
    print("wrote", OUT / out_name)


FRAMES = [
    ("home.png",        "Reimagine",   "any room",        "01_reimagine.png"),
    ("upload.png",      "Start with",  "your own room",   "02_yourroom.png"),
    ("choosestyle.png", "Pick any",    "style",           "03_pickstyle.png"),
    ("result.png",      "See it",      "before & after",  "04_beforeafter.png"),
    ("chat.png",        "Your own",    "AI Designer",     "05_aidesigner.png"),
    ("detail.png",      "A look for",  "every space",     "06_styles.png"),
]

if __name__ == "__main__":
    # Clear the old raw captures so only the marketing set remains.
    for old in OUT.glob("*.png"):
        old.unlink()
    for src, l1, l2, out in FRAMES:
        render(src, l1, l2, out)
    print("done:", len(FRAMES), "frames")
