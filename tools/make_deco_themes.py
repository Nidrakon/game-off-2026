"""Erzeugt die Deko-Requisiten der Level-Themen (Doku 2.9, Themen) als
Pixelart im Atlas graphics/sprites/deco/deco_themes.png (+ .json mit den
Ausschnitten). Nur Farben der Palette Resurrect 64 (Doku 1.7).

Aufruf im Projektordner:  python tools/make_deco_themes.py
Danach in Aseprite als Quelle sichern (optional):
  Aseprite -b graphics/sprites/deco/deco_themes.png --save-as graphics/source/deco_themes.aseprite

Jedes Requisit ist eine Funktion draw_<name>(c, frame), die auf eine
Leinwand der Groesse SIZES[name] zeichnet. Animierte Requisiten haben
mehrere Bilder nebeneinander (FRAMES)."""
import json, math, struct, zlib, os

# Palette (Auszug, Namen fuer die Lesbarkeit)
OUT = '2e222f'; DARK = '3e3546'; MID = '625565'; GREY = '7f708a'; LGREY = '9babb2'
PALE = 'c7dcd0'; WHITE = 'ffffff'
RUSTD = '6e2727'; RED = 'b33831'; REDL = 'ea4f36'; CRIM = 'ae2334'; REDB = 'e83b3b'
ORANGE = 'fb6b1d'; AMBER = 'f79617'; YEL = 'f9c22b'; YELL = 'fbff86'
WOODD = '9e4539'; WOOD = 'cd683d'; WOODL = 'e6904e'; WOODLL = 'fbb954'
OLIVED = '4c3e24'; OLIVE = '676633'
GRND = '165a4c'; GRN = '239063'; GRNL = '1ebc73'; GRNLL = '91db69'
TEALD = '0b5e65'; TEAL = '0b8a8f'; TEALL = '0eaf9b'; TEALLL = '30e1b9'; MINT = '8ff8e2'
NAVY = '323353'; BLUED = '484a77'; BLUE = '4d65b4'; BLUEL = '4d9be6'; SKY = '8fd3ff'
PURD = '45293f'; PUR = '6b3e75'; PURL = '905ea9'; LILA = 'a884f3'; PINKL = 'eaaded'
MAG = 'c32454'; PINK = 'f04f78'
SLATE = '313638'; SLATEL = '374e4a'

SIZES = {
    # Fabrik
    'conveyor': (64, 24), 'pallet_stack': (40, 32), 'oil_drums': (40, 32), 'warning_sign': (28, 26),
    # Chemie
    'flask_table': (48, 36), 'chem_barrel': (24, 32), 'fume_hood': (48, 64), 'distiller': (40, 48), 'hazard_sign': (24, 24),
    # Elektro
    'transformer': (40, 48), 'fuse_panel': (36, 40), 'cable_spool': (32, 28), 'volt_sign': (24, 24), 'battery_bank': (40, 40),
    # Magnet
    'horseshoe': (32, 44), 'coil_stack': (32, 48), 'scrap_pile': (40, 24), 'compass': (28, 28), 'iron_weights': (34, 24),
    # Quanten
    'quantum_rack': (40, 64), 'orb_chamber': (36, 56), 'hologram': (36, 48), 'cryo_tank': (28, 56), 'wave_screen': (48, 32),
}
FRAMES = {'conveyor': 2, 'flask_table': 2, 'fume_hood': 2, 'distiller': 2, 'transformer': 2, 'fuse_panel': 2,
          'battery_bank': 2, 'coil_stack': 2, 'compass': 2, 'quantum_rack': 2, 'orb_chamber': 2, 'hologram': 2,
          'cryo_tank': 2, 'wave_screen': 2}


class Canvas:
    def __init__(self, w, h):
        self.w, self.h = w, h
        self.px = [[None] * w for _ in range(h)]

    def set(self, x, y, c):
        x, y = int(x), int(y)
        if 0 <= x < self.w and 0 <= y < self.h:
            self.px[y][x] = c

    def rect(self, x, y, w, h, c):
        for yy in range(int(y), int(y + h)):
            for xx in range(int(x), int(x + w)):
                self.set(xx, yy, c)

    def hline(self, x, y, w, c):
        self.rect(x, y, w, 1, c)

    def vline(self, x, y, h, c):
        self.rect(x, y, 1, h, c)

    def box(self, x, y, w, h, base, light=None, dark=None, outline=OUT):
        """Kasten mit Umriss, heller Kante oben/links, Schatten unten/rechts."""
        self.rect(x, y, w, h, outline)
        self.rect(x + 1, y + 1, w - 2, h - 2, base)
        if light:
            self.hline(x + 1, y + 1, w - 2, light)
            self.vline(x + 1, y + 1, h - 2, light)
        if dark:
            self.hline(x + 1, y + h - 2, w - 2, dark)
            self.vline(x + w - 2, y + 1, h - 2, dark)

    def disc(self, cx, cy, r, c):
        for yy in range(int(cy - r - 1), int(cy + r + 2)):
            for xx in range(int(cx - r - 1), int(cx + r + 2)):
                if (xx - cx) ** 2 + (yy - cy) ** 2 <= r * r + 0.5:
                    self.set(xx, yy, c)

    def ring(self, cx, cy, r, c):
        for yy in range(int(cy - r - 1), int(cy + r + 2)):
            for xx in range(int(cx - r - 1), int(cx + r + 2)):
                d = math.sqrt((xx - cx) ** 2 + (yy - cy) ** 2)
                if r - 0.6 <= d <= r + 0.4:
                    self.set(xx, yy, c)

    def line(self, x0, y0, x1, y1, c):
        n = int(max(abs(x1 - x0), abs(y1 - y0))) + 1
        for i in range(n):
            t = i / max(n - 1, 1)
            self.set(round(x0 + (x1 - x0) * t), round(y0 + (y1 - y0) * t), c)

    def outline_shape(self, c=OUT):
        """Umriss um alle gesetzten Pixel (aussen)."""
        add = []
        for y in range(self.h):
            for x in range(self.w):
                if self.px[y][x] is None:
                    for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)):
                        xx, yy = x + dx, y + dy
                        if 0 <= xx < self.w and 0 <= yy < self.h and self.px[yy][xx] not in (None, c):
                            add.append((x, y))
                            break
        for x, y in add:
            self.px[y][x] = c


# ---------------------------------------------------------------- Fabrik
def draw_conveyor(c, f):
    for lx in (6, 54):
        c.box(lx, 14, 5, 10, MID, GREY, DARK)
    c.box(0, 6, 64, 10, MID, LGREY, DARK)
    c.hline(1, 7, 62, SLATE)
    for x in range(1, 63):
        if (x + f * 3) % 6 == 0:
            c.set(x, 7, LGREY)
    for rx in (6, 57):
        c.disc(rx, 11, 3, LGREY)
        c.ring(rx, 11, 3, OUT)
        c.set(rx, 11, DARK)
    c.box(24 + f, 0, 14, 7, WOODL, WOODLL, WOOD)
    c.hline(25 + f, 3, 12, PALE)


def draw_pallet_stack(c, f):
    c.rect(0, 26, 40, 6, OUT)
    for x in (1, 13, 26):
        c.rect(x, 27, 12, 4, WOOD)
        c.hline(x, 27, 12, WOODL)
    c.hline(1, 29, 38, WOODD)
    c.box(2, 12, 20, 15, WOODL, WOODLL, WOOD)
    c.box(20, 8, 18, 19, WOODL, WOODLL, WOOD)
    c.box(7, 0, 16, 13, WOODL, WOODLL, WOOD)
    for x0, y0, w in ((2, 18, 20), (20, 16, 18), (7, 5, 16)):
        c.hline(x0 + 1, y0, w - 2, PALE)
    c.rect(26, 12, 6, 4, OUT)
    c.rect(27, 13, 4, 2, YEL)


def drum(c, x, y, w, h, base, light, dark):
    c.box(x, y, w, h, base, light, dark)
    for yy in (y + 6, y + h - 7):
        c.hline(x + 1, yy, w - 2, dark)
    c.rect(x + 3, y + 9, w - 6, 6, YEL)
    c.rect(x + w // 2 - 1, y + 10, 2, 4, OUT)


def draw_oil_drums(c, f):
    drum(c, 2, 4, 16, 28, RED, REDL, RUSTD)
    drum(c, 21, 6, 16, 26, BLUED, BLUE, NAVY)
    c.rect(4, 2, 12, 3, OUT)
    c.rect(5, 3, 10, 1, GREY)


def triangle_sign(c, w, fill, symbol):
    h = c.h
    for y in range(h):
        half = (y * (w - 1)) / (2 * (h - 1))
        x0 = round((w - 1) / 2 - half)
        x1 = round((w - 1) / 2 + half)
        c.hline(x0, y, x1 - x0 + 1, OUT)
        if 1 < y < h - 1:
            c.hline(x0 + 2, y, x1 - x0 - 3, fill)
    symbol(c)


def draw_warning_sign(c, f):
    def mark(c):
        c.rect(13, 8, 2, 9, OUT)
        c.rect(13, 19, 2, 2, OUT)
    triangle_sign(c, 28, YEL, mark)


# ---------------------------------------------------------------- Chemie
def flask(c, x, y, liquid, light, f, bubbles):
    # Erlenmeyer: Hals oben, Kegel unten (10 x 14)
    c.rect(x + 3, y, 4, 5, PALE)
    for i in range(9):
        half = 1 + i * 4 / 8
        c.hline(round(x + 5 - half), y + 5 + i, round(half * 2), PALE)
    for i in range(4, 9):
        half = 1 + i * 4 / 8
        c.hline(round(x + 5 - half) + 1, y + 5 + i, round(half * 2) - 2, liquid)
    c.set(x + 3, y + 10, light)
    if bubbles:
        c.set(x + 4 + f, y - 2 - f, light)
        c.set(x + 6 - f, y - 4 + f, light)


def draw_flask_table(c, f):
    c.box(0, 18, 48, 4, GREY, LGREY, DARK)
    for lx in (3, 42):
        c.rect(lx, 22, 3, 14, OUT)
        c.vline(lx + 1, 22, 13, MID)
    flask(c, 3, 4, GRNL, GRNLL, f, True)
    flask(c, 18, 4, PINK, PINKL, 1 - f, True)
    flask(c, 33, 4, BLUEL, SKY, f, False)
    c.outline_shape()


def draw_chem_barrel(c, f):
    c.box(2, 2, 20, 30, GRN, GRNL, GRND)
    for yy in (8, 24):
        c.hline(3, yy, 18, GRND)
    c.rect(6, 12, 12, 10, YEL)
    c.rect(11, 14, 2, 2, OUT)
    c.rect(10, 16, 4, 4, OUT)
    c.rect(5, 0, 14, 3, OUT)
    c.rect(6, 1, 12, 1, GRNLL)


def draw_fume_hood(c, f):
    c.box(0, 0, 48, 64, LGREY, PALE, GREY)
    c.box(5, 8, 38, 28, TEALD, TEAL, OUT)
    c.line(9, 10, 15, 16, MINT)
    c.line(10, 10, 16, 16, TEALL)
    glow = TEALLL if f == 0 else MINT
    flask(c, 26, 18, glow, WHITE, f, True)
    c.rect(5, 38, 38, 2, OUT)
    c.box(5, 42, 18, 20, GREY, LGREY, MID)
    c.box(25, 42, 18, 20, GREY, LGREY, MID)
    c.rect(20, 50, 2, 4, OUT)
    c.rect(26, 50, 2, 4, OUT)
    c.rect(18, 2, 12, 4, OUT)
    c.rect(19, 3, 10, 2, MID)


def draw_distiller(c, f):
    c.rect(4, 44, 32, 4, OUT)
    c.rect(5, 45, 30, 2, MID)
    c.rect(9, 10, 2, 34, OUT)
    c.disc(10, 32, 7, PALE)
    c.disc(10, 34, 5, ORANGE if f else AMBER)
    c.ring(10, 32, 7, OUT)
    c.rect(9, 22, 3, 4, PALE)
    for i in range(5):
        c.line(12 + i * 4, 18 + i, 15 + i * 4, 21 + i, PALE)
    c.line(11, 18, 31, 24, OUT)
    c.rect(27, 32, 10, 12, OUT)
    c.rect(28, 33, 8, 10, PALE)
    c.rect(28, 38, 8, 5, AMBER)
    c.set(32, 27 + f * 3, ORANGE)


def draw_hazard_sign(c, f):
    for y in range(24):
        half = 11 - abs(11.5 - y)
        x0 = round(11.5 - half)
        c.hline(x0, y, round(half * 2) + 1, OUT)
        if 1 < y < 22:
            c.hline(x0 + 2, y, max(round(half * 2) - 3, 0), TEALL)
    c.rect(11, 7, 2, 3, WHITE)
    c.rect(10, 10, 4, 5, WHITE)
    c.rect(11, 15, 2, 1, WHITE)


# ---------------------------------------------------------------- Elektro
def bolt(c, x, y, col):
    for dx, dy in ((3, 0), (2, 1), (2, 2), (1, 3), (0, 4), (1, 4), (2, 4), (3, 4), (2, 5), (2, 6), (1, 7), (1, 8)):
        c.set(x + dx, y + dy, col)


def draw_transformer(c, f):
    c.box(2, 14, 36, 34, BLUED, BLUE, NAVY)
    for x in range(6, 36, 4):
        c.vline(x, 18, 24, NAVY)
    for x in (8, 18, 28):
        c.box(x, 4, 6, 11, PALE, WHITE, LGREY)
        c.hline(x, 7, 6, LGREY)
        c.hline(x, 10, 6, LGREY)
    c.box(14, 26, 12, 12, YEL, YELL, AMBER)
    bolt(c, 17, 28, OUT)
    c.rect(31, 17, 4, 4, OUT)
    c.rect(32, 18, 2, 2, REDB if f == 0 else GRNL)


def draw_fuse_panel(c, f):
    c.box(0, 0, 36, 40, LGREY, PALE, GREY)
    c.box(3, 3, 30, 34, DARK, MID, OUT)
    for i in range(6):
        x = 6 + (i % 3) * 9
        y = 7 + (i // 3) * 14
        c.box(x, y, 6, 10, GREY, LGREY, MID)
        on = (i + f) % 3 != 0
        c.rect(x + 2, y + (2 if on else 5), 2, 3, PALE)
        c.set(x + 2, y - 2, GRNL if on else REDB)


def draw_cable_spool(c, f):
    c.disc(16, 14, 13, WOOD)
    c.ring(16, 14, 13, OUT)
    c.ring(16, 14, 11, WOODD)
    c.disc(16, 14, 8, NAVY)
    for r in (3, 5, 7):
        c.ring(16, 14, r, BLUED)
    c.disc(16, 14, 2, OUT)
    c.line(28, 18, 31, 27, NAVY)
    c.rect(4, 26, 24, 2, OUT)


def draw_volt_sign(c, f):
    def mark(c):
        bolt(c, 9, 8, OUT)
        bolt(c, 10, 9, OUT)
    triangle_sign(c, 24, YEL, mark)


def draw_battery_bank(c, f):
    for i, x in enumerate((2, 21)):
        c.box(x, 6, 17, 34, SLATE, SLATEL, OUT)
        c.rect(x + 5, 2, 7, 5, OUT)
        c.rect(x + 6, 3, 5, 3, LGREY if i == 0 else REDB)
        level = 4 + ((f + i) % 2) * 2
        for k in range(6):
            col = GRNL if k < level else DARK
            c.rect(x + 4, 35 - k * 4, 9, 3, col)


# ---------------------------------------------------------------- Magnet
def draw_horseshoe(c, f):
    c.rect(4, 38, 24, 6, OUT)
    c.rect(5, 39, 22, 4, MID)
    c.rect(14, 30, 4, 9, OUT)
    c.rect(15, 30, 2, 8, GREY)
    # Hufeisen: Bogen oben, Schenkel nach unten
    for y in range(0, 26):
        for x in range(2, 30):
            cx, cy = 16, 14
            if y <= 14:
                d = math.sqrt((x + 0.5 - cx) ** 2 + (y + 0.5 - cy) ** 2)
                inside = 6 <= d <= 13
            else:
                inside = (3 <= x <= 9) or (22 <= x <= 28)
            if inside:
                c.set(x, y, RED if y < 22 else LGREY)
    c.outline_shape()
    for y in range(2, 22):
        c.set(5, y, REDL)


def draw_coil_stack(c, f):
    c.rect(2, 42, 28, 6, OUT)
    c.rect(3, 43, 26, 4, MID)
    c.rect(13, 0, 6, 42, OUT)
    c.rect(14, 1, 4, 41, GREY)
    for i in range(4):
        y = 4 + i * 10
        c.box(4, y, 24, 8, WOOD, WOODLL, WOODD)
        for x in range(6, 26, 3):
            c.vline(x, y + 2, 4, WOODL)
    if f:
        for x, y in ((2, 8), (29, 18), (2, 28), (29, 38)):
            c.set(x, y, SKY)


def draw_scrap_pile(c, f):
    for x in range(40):
        top = 24 - round(12 * math.sin(math.pi * x / 39)) - (3 if 14 < x < 24 else 0)
        c.vline(x, top, 24 - top, MID)
    c.outline_shape()
    for x0, y0, w in ((6, 16, 9), (20, 9, 10), (26, 17, 8)):
        c.rect(x0, y0, w, 3, LGREY)
        c.hline(x0, y0 + 2, w, GREY)
    for cx, cy in ((14, 12), (31, 13), (10, 20)):
        c.disc(cx, cy, 2, PALE)
        c.set(cx, cy, OUT)


def draw_compass(c, f):
    c.disc(14, 14, 13, OUT)
    c.disc(14, 14, 12, WOODLL)
    c.disc(14, 14, 10, PALE)
    for a in range(0, 360, 45):
        r = math.radians(a)
        c.set(round(14 + math.cos(r) * 9), round(14 + math.sin(r) * 9), MID)
    ang = math.radians(-60 + (8 if f else -8))
    for t in range(1, 8):
        c.set(round(14 + math.cos(ang) * t), round(14 + math.sin(ang) * t), REDB)
        c.set(round(14 - math.cos(ang) * t), round(14 - math.sin(ang) * t), GREY)
    c.disc(14, 14, 1, OUT)


def draw_iron_weights(c, f):
    for x0, w, h in ((1, 16, 16), (19, 14, 13)):
        y0 = 24 - h
        for i in range(h):
            inset = round((h - 1 - i) * 2 / h)
            c.hline(x0 + inset, y0 + i, w - inset * 2, SLATE)
        c.rect(x0 + w // 2 - 3, y0 - 4, 6, 4, OUT)
        c.rect(x0 + w // 2 - 2, y0 - 3, 4, 3, SLATE if True else None)
        c.rect(x0 + w // 2 - 1, y0 - 3, 2, 2, MID)
    c.outline_shape()
    c.rect(5, 15, 8, 3, LGREY)
    c.rect(22, 17, 8, 2, LGREY)


# ---------------------------------------------------------------- Quanten
def draw_quantum_rack(c, f):
    c.box(0, 0, 40, 64, PURD, PUR, OUT)
    for row in range(7):
        y = 4 + row * 8
        c.box(4, y, 32, 7, NAVY, BLUED, OUT)
        for k in range(5):
            on = (row * 3 + k + f) % 4 != 0
            col = (TEALLL if (row + k) % 2 else LILA) if on else DARK
            c.set(7 + k * 3, y + 3, col)
        c.hline(24, y + 3, 9, BLUED)


def draw_orb_chamber(c, f):
    c.box(2, 48, 32, 8, MID, GREY, DARK)
    c.box(4, 0, 28, 6, MID, GREY, DARK)
    c.rect(5, 6, 26, 42, OUT)
    c.rect(6, 6, 24, 42, PURD)
    c.vline(9, 8, 38, PUR)
    r = 7 if f == 0 else 8
    c.disc(18, 27, r, PURL)
    c.disc(18, 27, r - 3, LILA)
    c.disc(18, 26, 2, PINKL)
    c.ring(18, 27, 11, PUR if f else PURL)


def draw_hologram(c, f):
    c.box(4, 40, 28, 8, DARK, MID, OUT)
    c.rect(12, 38, 12, 3, TEALLL)
    for i in range(3):
        a = math.radians(i * 60 + f * 30)
        for t in range(-10, 11):
            x = 18 + math.cos(a) * t
            y = 18 + math.sin(a) * t * 0.45
            c.set(round(x), round(y), SKY)
    c.disc(18, 18, 2, MINT)
    c.line(13, 37, 6, 6, TEAL)
    c.line(23, 37, 30, 6, TEAL)


def draw_cryo_tank(c, f):
    c.box(0, 48, 28, 8, MID, GREY, DARK)
    c.box(2, 0, 24, 6, MID, GREY, DARK)
    c.rect(3, 6, 22, 42, OUT)
    c.rect(4, 6, 20, 42, BLUEL)
    c.rect(4, 6, 20, 42, BLUE)
    for y in range(8, 46, 2):
        x = 6 + ((y * 7 + f * 5) % 15)
        c.set(x, y, SKY)
    c.vline(6, 8, 36, SKY)
    c.rect(4, 40, 20, 8, SKY)
    c.hline(4, 40, 20, WHITE)


def draw_wave_screen(c, f):
    c.box(0, 0, 48, 32, MID, GREY, DARK)
    c.rect(3, 3, 42, 24, OUT)
    c.rect(4, 4, 40, 22, NAVY)
    for x in range(4, 44):
        y = 15 + round(6 * math.sin((x + f * 5) * 0.35) * math.exp(-((x - 24) / 14) ** 2))
        c.set(x, y, TEALLL)
    c.hline(4, 15, 40, BLUED)
    c.rect(20, 28, 8, 4, OUT)


# ---------------------------------------------------------------- Atlas
PALETTE = set(l.strip().lower() for l in open('graphics/palettes/resurrect_64.hex') if l.strip())


def build():
    names = list(SIZES)
    atlas_w = 512
    placed = {}
    x = y = row_h = 0
    for n in names:
        w, h = SIZES[n]
        fr = FRAMES.get(n, 1)
        if x + w * fr > atlas_w:
            x = 0
            y += row_h + 2
            row_h = 0
        placed[n] = {'x': x, 'y': y, 'w': w, 'h': h, 'frames': fr}
        x += w * fr + 2
        row_h = max(row_h, h)
    atlas_h = y + row_h
    atlas_h = (atlas_h + 15) // 16 * 16
    img = [[None] * atlas_w for _ in range(atlas_h)]
    for n, info in placed.items():
        for f in range(info['frames']):
            c = Canvas(info['w'], info['h'])
            globals()['draw_' + n](c, f)
            for yy in range(info['h']):
                for xx in range(info['w']):
                    col = c.px[yy][xx]
                    if col is not None:
                        assert col.lower() in PALETTE, (n, col)
                        img[info['y'] + yy][info['x'] + f * info['w'] + xx] = col
    raw = b''
    for row in img:
        line = b'\x00'
        for col in row:
            if col is None:
                line += b'\x00\x00\x00\x00'
            else:
                line += bytes.fromhex(col) + b'\xff'
        raw += line

    def chunk(t, d):
        return struct.pack('>I', len(d)) + t + d + struct.pack('>I', zlib.crc32(t + d) & 0xffffffff)
    png = b'\x89PNG\r\n\x1a\n' + chunk(b'IHDR', struct.pack('>IIBBBBB', atlas_w, atlas_h, 8, 6, 0, 0, 0)) \
        + chunk(b'IDAT', zlib.compress(raw, 9)) + chunk(b'IEND', b'')
    os.makedirs('graphics/sprites/deco', exist_ok=True)
    open('graphics/sprites/deco/deco_themes.png', 'wb').write(png)
    lines = ['{']
    items = list(placed.items())
    for i, (n, v) in enumerate(items):
        lines.append('\t"%s": {"x": %d, "y": %d, "w": %d, "h": %d, "frames": %d}%s' % (
            n, v['x'], v['y'], v['w'], v['h'], v['frames'], ',' if i < len(items) - 1 else ''))
    lines.append('}')
    open('graphics/sprites/deco/deco_themes.json', 'w', newline='\n').write('\n'.join(lines) + '\n')
    print('deco_themes.png', atlas_w, 'x', atlas_h, len(placed), 'Requisiten')


if __name__ == '__main__':
    build()
