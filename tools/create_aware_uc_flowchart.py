from pathlib import Path

from PIL import Image, ImageDraw, ImageFont


ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "manuscript" / "aware_uc_flowchart.png"


def font(size=24, bold=False):
    candidates = [
        "C:/Windows/Fonts/arialbd.ttf" if bold else "C:/Windows/Fonts/arial.ttf",
        "C:/Windows/Fonts/calibrib.ttf" if bold else "C:/Windows/Fonts/calibri.ttf",
    ]
    for item in candidates:
        if Path(item).exists():
            return ImageFont.truetype(item, size)
    return ImageFont.load_default()


def wrapped(draw, text, fnt, width):
    words = text.split()
    lines = []
    current = ""
    for word in words:
        trial = (current + " " + word).strip()
        if draw.textbbox((0, 0), trial, font=fnt)[2] <= width:
            current = trial
        else:
            if current:
                lines.append(current)
            current = word
    if current:
        lines.append(current)
    return lines


def box(draw, xy, text, fill="#eef6ff", outline="#2b5d8f"):
    x1, y1, x2, y2 = xy
    draw.rounded_rectangle(xy, radius=14, fill=fill, outline=outline, width=3)
    fnt = font(24, bold=True)
    lines = wrapped(draw, text, fnt, x2 - x1 - 30)
    line_h = 30
    total_h = line_h * len(lines)
    y = y1 + ((y2 - y1) - total_h) / 2
    for line in lines:
        tw = draw.textbbox((0, 0), line, font=fnt)[2]
        draw.text((x1 + (x2 - x1 - tw) / 2, y), line, fill="#12324f", font=fnt)
        y += line_h


def arrow(draw, start, end):
    draw.line([start, end], fill="#30465c", width=4)
    x1, y1 = start
    x2, y2 = end
    if y2 > y1:
        pts = [(x2, y2), (x2 - 9, y2 - 16), (x2 + 9, y2 - 16)]
    elif y2 < y1:
        pts = [(x2, y2), (x2 - 9, y2 + 16), (x2 + 9, y2 + 16)]
    elif x2 > x1:
        pts = [(x2, y2), (x2 - 16, y2 - 9), (x2 - 16, y2 + 9)]
    else:
        pts = [(x2, y2), (x2 + 16, y2 - 9), (x2 + 16, y2 + 9)]
    draw.polygon(pts, fill="#30465c")


def main():
    img = Image.new("RGB", (1600, 1100), "white")
    draw = ImageDraw.Draw(img)
    title = "AWARE-UC Round-Level Decision Flow"
    title_font = font(38, bold=True)
    tw = draw.textbbox((0, 0), title, font=title_font)[2]
    draw.text(((1600 - tw) / 2, 32), title, fill="#1f2933", font=title_font)

    boxes = [
        ((540, 110, 1060, 190), "Deploy nodes and set BS position"),
        ((540, 240, 1060, 320), "For each round r, update BS if dynamic"),
        ((540, 370, 1060, 450), "Compute adaptive threshold E_th(r)"),
        ((540, 500, 1060, 580), "Screen available nodes: E_i(r) > E_th(r)"),
        ((540, 630, 1060, 710), "Compute weighted CH score"),
        ((540, 760, 1060, 840), "Select CHs using uneven competition radius"),
        ((120, 760, 470, 840), "Assign members by minimum energy cost"),
        ((1130, 760, 1480, 840), "Forward CH data directly or through relay CH"),
        ((540, 910, 1060, 990), "Record packets, energy, FND, HND, AND"),
    ]
    for idx, (xy, text) in enumerate(boxes):
        fill = "#e8f5e9" if idx in (6, 7) else "#eef6ff"
        box(draw, xy, text, fill=fill)

    centers = [((x1 + x2) / 2, (y1 + y2) / 2) for (x1, y1, x2, y2), _ in boxes]
    for a, b in [(0, 1), (1, 2), (2, 3), (3, 4), (4, 5)]:
        arrow(draw, (centers[a][0], centers[a][1] + 40), (centers[b][0], centers[b][1] - 40))
    arrow(draw, (540, 800), (470, 800))
    arrow(draw, (1060, 800), (1130, 800))
    arrow(draw, (295, 840), (720, 910))
    arrow(draw, (1305, 840), (880, 910))
    arrow(draw, (800, 990), (800, 1040))
    draw.text((630, 1045), "Next round until R_max or no available nodes", fill="#30465c", font=font(22))

    OUT.parent.mkdir(parents=True, exist_ok=True)
    img.save(OUT)
    print(OUT)


if __name__ == "__main__":
    main()
