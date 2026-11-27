"""Deko und Hintergrund der Level nach Themen (Doku 2.9, Level-Themen).

Sechs Themen, passend zu den sechs Rueckwand-Stilen; sie wechseln von
Level zu Level reihum (Level 1 Werkstatt, 2 Fabrik, 3 Chemie, 4 Elektro,
5 Magnet, 6 Quanten, 7 wieder Werkstatt ...). Je Thema eigene Requisiten
fuer Boden, Wand und Decke (Atlas deco_workshop.png und deco_themes.png).
Setzt ausserdem Thema, Saat und Dichte der Hintergrund-Silhouetten und
legt hintere Rohre an, falls ein Level noch keine hat. Aendert nichts am
Spiel: Deko und hintere Rohre haben keine Kollision und halten Abstand zu
Spawn, Ausgang, Gefahren und den Bahnen von Laser, Pendel, Werfern und
Plattformen. Die Musik eines Levels bleibt, wie sie eingetragen ist.

Aufruf im Projektordner:  python tools/decorate_levels.py 02 03 ...
Wiederholbar: alte DecoAuto*-Knoten werden ersetzt. Level 1 (Werkstatt)
ist von Hand dekoriert und wird nicht angefasst.
"""
import re, base64, struct, io, json, random, sys

META = {}
for _f in ('graphics/sprites/deco/deco_workshop.json', 'graphics/sprites/deco/deco_themes.json'):
    META.update(json.load(io.open(_f, encoding='utf-8')))
BASE = io.open('scenes/levels/level_base.tscn', encoding='utf-8').read()
T = 16
ANIMATED = {k for k, v in META.items() if v['frames'] > 1}

# Thema = Index in BackgroundTheme.Kind. Kein grosses Zahnrad (wirkt wie
# ein Saegeblatt), keine Rakete und kein Laser (wirken wie Gefahren).
THEMES = [
    dict(name='Werkstatt',
         floor=['workbench', 'shelf', 'toolbox', 'crate', 'pizza_boxes', 'coffee', 'prototype', 'jetpack', 'cactus', 'trash_can', 'bookshelf', 'microscope'],
         wall=['tool_wall', 'chalkboard', 'blueprint', 'wall_clock'], ceiling=['lamp', 'lamp', 'hanging_cables']),
    dict(name='Fabrik',
         floor=['conveyor', 'pallet_stack', 'oil_drums', 'barrel', 'crate', 'gas_tanks', 'robot_arm', 'generator', 'toolbox'],
         wall=['warning_sign', 'gauges', 'tool_wall'], ceiling=['lamp', 'hanging_cables']),
    dict(name='Chemie',
         floor=['flask_table', 'chem_barrel', 'fume_hood', 'distiller', 'tube', 'brain_jar', 'microscope', 'gas_tanks'],
         wall=['hazard_sign', 'chalkboard', 'gauges'], ceiling=['lamp']),
    dict(name='Elektro',
         floor=['transformer', 'cable_spool', 'battery_bank', 'tesla_coil', 'generator', 'console'],
         wall=['fuse_panel', 'volt_sign', 'gauges'], ceiling=['hanging_cables', 'lamp']),
    dict(name='Magnet',
         floor=['horseshoe', 'coil_stack', 'scrap_pile', 'iron_weights', 'robot_arm', 'console', 'crate'],
         wall=['compass', 'gauges', 'blueprint'], ceiling=['lamp']),
    dict(name='Quanten',
         floor=['quantum_rack', 'orb_chamber', 'hologram', 'cryo_tank', 'teleporter', 'console'],
         wall=['wave_screen', 'blueprint'], ceiling=['lamp', 'hanging_cables']),
]


def theme_for(lv):
    """Thema reihum nach Levelnummer (1 = Werkstatt)."""
    return (int(lv) - 1) % len(THEMES)


# Je Level: Saat, Dichte, hintere Rohre (Reihe der waagrechten Leitung,
# None = keine anlegen), verbotene Requisiten, deco=False = nur Thema setzen
# (z. B. ein Level, das der Nutzer gerade erst baut).
CONFIG = {
    '02': dict(seed=21, density=0.55, pipe_row=4),
    '03': dict(seed=33, density=0.55, pipe_row=6),
    '04': dict(seed=44, density=0.5, pipe_row=5),
    '05': dict(seed=55, density=0.55, pipe_row=4),
    '06': dict(seed=66, density=0.5, pipe_row=None),
    # Keine Wanduhr neben den Zeitschaltuhren (Verwechslung).
    '07': dict(seed=77, density=0.55, pipe_row=5, no_props=['wall_clock']),
    '08': dict(seed=88, density=0.55, pipe_row=6, no_props=['wall_clock']),
    '09': dict(seed=99, density=0.55, pipe_row=None, deco=False),
}


def decode(data):
    b = base64.b64decode(data)
    out = {}
    for i in range((len(b) - 2) // 12):
        x, y = struct.unpack_from('<hh', b, 2 + 12 * i)
        out[(x, y)] = b[2 + 12 * i + 4: 2 + 12 * i + 12]
    return out


def tiles(text, name):
    m = re.search(r'\[node name="%s"[^\n]*\]\n(?:[^\[\n][^\n]*\n)*?tile_map_data = PackedByteArray\("([^"]*)"\)' % name, text)
    return set(decode(m.group(1))) if m else None


def encode_pipes(cells):
    out = bytearray(b'\x00\x00')
    dirs = [(0, -1, 1), (1, 0, 2), (0, 1, 4), (-1, 0, 8)]
    for (x, y) in sorted(cells, key=lambda c: (c[1], c[0])):
        mask = sum(bit for dx, dy, bit in dirs if (x + dx, y + dy) in cells)
        out += struct.pack('<hhHHHH', x, y, 0, 4 + mask % 4, mask // 4, 0)
    return base64.b64encode(bytes(out)).decode()


def node_parts(text):
    parts = re.split(r'\n(?=\[node )', text)
    return parts[0], parts[1:]


def gameplay_zones(parts):
    """Rechtecke (x0, y0, x1, y1), in denen keine Wand-Deko liegen darf,
    und x-Bereiche, in denen keine Boden-Deko stehen darf."""
    rects, floor_block = [], []
    for part in parts:
        name = re.match(r'\[node name="([^"]+)"', part).group(1)
        if name.startswith('Deco') or name in ('Ground', 'PipesBack', 'PipesFront', 'BackWall', 'Launchers'):
            continue
        pos = re.search(r'\nposition = Vector2\(([-\d.e]+), ([-\d.e]+)\)', part)
        if not pos:
            continue
        x, y = float(pos.group(1)), float(pos.group(2))
        rot = re.search(r'\nrotation = ([-\d.e]+)', part)
        rot = float(rot.group(1)) if rot else 0.0
        rects.append((x - 64, y - 64, x + 64, y + 64))
        if y > 330:
            floor_block.append((x - 48, x + 48))
        lname = name.lower()
        if 'laser' in lname or 'barrier' in lname:
            rects.append((x - 28, -1000, x + 28, 2000))
            floor_block.append((x - 28, x + 28))
        if 'pendulum' in lname:
            rects.append((x - 150, -1000, x + 150, 2000))
            floor_block.append((x - 150, x + 150))
        if 'launcher' in lname:
            if abs(abs(rot) - 1.5708) < 0.1:  # senkrecht: Spalte
                rects.append((x - 30, -1000, x + 30, 2000))
            else:  # waagrecht: Band ueber die ganze Breite
                rects.append((-1000, y - 36, 2000, y + 36))
        if 'platform' in lname:
            travel = re.search(r'\ntravel = Vector2\(([-\d.e]+), ([-\d.e]+)\)', part)
            tx, ty = (float(travel.group(1)), float(travel.group(2))) if travel else (0, 0)
            rects.append((min(x, x + tx) - 64, min(y, y + ty) - 48, max(x, x + tx) + 64, max(y, y + ty) + 48))
        if 'block' in lname:
            size = re.search(r'\nsize_tiles = Vector2i\((\d+), (\d+)\)', part)
            w, h = (int(size.group(1)), int(size.group(2))) if size else (2, 1)
            rects.append((x - 24, y - 40, x + w * T + 24, y + h * T + 24))
    return rects, floor_block


def overlaps(a, b):
    return a[0] < b[2] and b[0] < a[2] and a[1] < b[3] and b[1] < a[3]


def decorate(lv):
    cfg = CONFIG.get(lv, dict(seed=int(lv) * 11, density=0.55, pipe_row=5))
    theme = THEMES[theme_for(lv)]
    FLOOR_PROPS, WALL_PROPS, CEILING_PROPS = theme['floor'], theme['wall'], theme['ceiling']
    path = 'scenes/levels/level_%s.tscn' % lv
    raw = io.open(path, encoding='utf-8', newline='').read()
    nl = '\r\n' if '\r\n' in raw else '\n'
    s = raw.replace('\r\n', '\n')
    rng = random.Random(cfg['seed'])
    head, parts = node_parts(s)
    parts = [p for p in parts if not re.match(r'\[node name="DecoAuto', p)]
    ground = tiles(s, 'Ground') or tiles(BASE, 'Ground')
    front = tiles(s, 'PipesFront') or set()
    solid = ground | front
    rects, floor_block = gameplay_zones(parts)
    # Spawn (Klonstation) und Ausgang freihalten
    spawn = re.search(r'name="CloneStation"[^\n]*\]\n(?:[^\[\n][^\n]*\n)*?position = Vector2\(([-\d.]+), ([-\d.]+)\)', s)
    floor_block.append((48 - 56, 48 + 56) if not spawn else (float(spawn.group(1)) - 56, float(spawn.group(1)) + 56))
    exit_ = re.search(r'name="LevelExit"[^\n]*\]\n(?:[^\[\n][^\n]*\n)*?position = Vector2\(([-\d.]+), ([-\d.]+)\)', s)
    ex = float(exit_.group(1)) if exit_ else 912.0
    floor_block.append((ex - 48, ex + 48))
    rects.append((ex - 40, 380, ex + 40, 500))
    xs = [c[0] for c in ground]
    min_x, max_x = (min(xs) + 1) * T, max(xs) * T
    used = []  # belegte Rechtecke der neuen Deko
    banned = set(cfg.get('no_props', []))
    bags = {}

    def pick(pool):
        # Ohne Wiederholung, bis alle einmal dran waren.
        key = id(pool)
        if not bags.get(key):
            bags[key] = [p for p in pool if p not in banned]
            rng.shuffle(bags[key])
        return bags[key][-1]

    def take(pool, prop):
        bags[id(pool)].remove(prop)
    new_nodes = []

    def free_cells(r):
        for cx in range(int(r[0] // T), int((r[2] - 1) // T) + 1):
            for cy in range(int(r[1] // T), int((r[3] - 1) // T) + 1):
                if (cx, cy) in solid:
                    return False
        return True

    def add(prop, x, y, flip=False):
        n = len(new_nodes) + 1
        lines = ['[node name="DecoAuto%d" parent="." instance=ExtResource("90_deco")]' % n,
                 'z_index = -8', 'position = Vector2(%d, %d)' % (x, y), 'prop = "%s"' % prop]
        if flip:
            lines.append('flip = true')
        if prop in ANIMATED:
            lines.append('start_offset = %.1f' % rng.uniform(0, 1.5))
        new_nodes.append('\n'.join(lines) + '\n')

    # Boden: Oberkante des Hauptbodens (Zeile 31), darueber frei
    floor_y = 31
    x = min_x + rng.randint(40, 80)
    while x < max_x - 30:
        prop = pick(FLOOR_PROPS)
        w, h = META[prop]['w'], META[prop]['h']
        r = (x - w / 2, floor_y * T - h, x + w / 2, floor_y * T)
        ok = all((c, floor_y) in ground for c in range(int(r[0] // T), int((r[2] - 1) // T) + 1))
        ok = ok and free_cells((r[0], r[1], r[2], r[3] - 1))
        ok = ok and not any(r[0] < b1 and b0 < r[2] for b0, b1 in floor_block)
        ok = ok and not any(overlaps(r, u) for u in used)
        if ok and rng.random() < cfg['density'] + 0.25:
            add(prop, x, floor_y * T, rng.random() < 0.4)
            take(FLOOR_PROPS, prop)
            used.append((r[0] - 6, r[1], r[2] + 6, r[3]))
            x += w / 2 + rng.randint(30, 110)
        else:
            x += 24

    # Wand: mittlere Hoehe, weit weg vom Spielgeschehen
    tries = 0
    walls = 0
    # Hoechstens ein Wand-Requisit mehr als der Vorrat (sonst viele gleiche).
    wall_pool = [x for x in WALL_PROPS if x not in banned]
    max_walls = min(int(4 + cfg['density'] * 6), len(wall_pool) + 1)
    while walls < max_walls and tries < 400:
        tries += 1
        prop = pick(WALL_PROPS)
        w, h = META[prop]['w'], META[prop]['h']
        x = rng.randint(int(min_x + w), int(max_x - w))
        y = rng.randint(140, 400)
        r = (x - w / 2, y - h, x + w / 2, y)
        if not free_cells(r) or any(overlaps(r, z) for z in rects) or any(overlaps(r, (u[0] - 40, u[1] - 30, u[2] + 40, u[3] + 30)) for u in used):
            continue
        add(prop, x, y, rng.random() < 0.3)
        take(WALL_PROPS, prop)
        used.append(r)
        walls += 1

    # Decke: Lampen und Kabel unter der Decke (Zeile 1 frei, Zeile 0 Decke)
    x = min_x + rng.randint(60, 120)
    while x < max_x - 40:
        prop = rng.choice(CEILING_PROPS)
        w, h = META[prop]['w'], META[prop]['h']
        r = (x - w / 2, T, x + w / 2, T + h)
        if free_cells(r) and not any(overlaps(r, z) for z in rects) and not any(overlaps(r, u) for u in used):
            add(prop, x, T + h)
            used.append(r)
            x += rng.randint(140, 220)
        else:
            x += 32

    # Hintere Rohre: eine Leitung unter der Decke mit Abzweigen nach unten
    pipes_part = None
    if cfg['pipe_row'] is not None and tiles(s, 'PipesBack') is None:
        row = cfg['pipe_row']
        cells = set()
        x0, x1 = min(xs) + 1, max(xs) - 1
        for cx in range(x0, x1 + 1):
            cells.add((cx, row))
        # Senkrechte Rohre nicht hinter Spielelementen (Abstand 40 px).
        busy = [(x0_ - 40, x1_ + 40) for x0_, y0_, x1_, y1_ in [(r[0] + 64, 0, r[2] - 64, 0) for r in rects if r[2] - r[0] <= 128]]
        busy += [(r[0], r[2]) for r in rects if 128 < r[2] - r[0] < 400]
        cx = x0 + rng.randint(3, 6)
        while cx < x1 - 2:
            px = cx * T + T / 2
            if any(b0 <= px <= b1 for b0, b1 in busy):
                cx += 2
                continue
            bottom = rng.choice([row + 4, row + 7, 30])
            for cy in range(row + 1, bottom + 1):
                if (cx, cy) in solid:
                    break
                cells.add((cx, cy))
            cx += rng.randint(8, 14)
        cells = {c for c in cells if c not in solid}
        pipes_part = '[node name="PipesBack" parent="." index="8"]\ntile_map_data = PackedByteArray("%s")\n' % encode_pipes(cells)

    if not cfg.get('deco', True):
        new_nodes = []
        pipes_part = None

    # Thema, Saat, Dichte an der Wurzel (Musik bleibt, wie eingetragen)
    root = parts[0]
    root = re.sub(r'\n(background_theme|background_seed|background_density) = [^\n]*', '', root)
    lines = root.rstrip('\n').split('\n')
    lines.insert(1, 'background_density = %s' % cfg['density'])
    lines.insert(1, 'background_seed = %d' % cfg['seed'])
    if theme_for(lv):
        lines.insert(1, 'background_theme = %d' % theme_for(lv))
    parts[0] = '\n'.join(lines) + '\n'
    if pipes_part:
        parts.insert(1, pipes_part)
    if new_nodes and 'id="90_deco"' not in head:
        head = head.rstrip('\n') + '\n[ext_resource type="PackedScene" path="res://scenes/objects/deco_prop.tscn" id="90_deco"]\n'
    out = head.rstrip('\n') + '\n\n' + '\n'.join(p.rstrip('\n') + '\n' for p in parts + new_nodes)
    io.open(path, 'w', encoding='utf-8', newline='').write(out.replace('\n', nl))
    print(lv, 'deko', len(new_nodes), 'rohre', bool(pipes_part))


for lv in sys.argv[1:]:
    decorate(lv)
