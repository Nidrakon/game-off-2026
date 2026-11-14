"""Erzeugt alle Soundeffekte des Spiels als WAV (22050 Hz, mono, 16 bit).

Synthese wie bei klassischen Retro-Soundgeneratoren: Sinus, Rechteck,
Saegezahn, Rauschen, Huellkurven, einfache Filter. Schleifen (Endung _loop
bzw. ambient_*) sind nahtlos: Frequenzen passen ganzzahlig in die Laenge,
Ereignisse liegen innerhalb der Schleife.

Aufruf (im Projektordner): python tools/make_sfx.py
Ausgabe: audio/sfx/*.wav  (vorhandene Dateien werden ueberschrieben)
"""
import math
import os
import random
import struct
import wave

RATE = 22050
OUT = os.path.join(os.path.dirname(__file__), '..', 'audio', 'sfx')
rng = random.Random(4711)


def n(sec):
    return int(sec * RATE)


def silence(sec):
    return [0.0] * n(sec)


def env(length, a=0.005, d=0.1, s=0.0, r=0.0, hold=0.0):
    """Huellkurve: Anstieg a, Abfall d auf Sustain s, Halten hold, Ausklang r (Sekunden)."""
    out = []
    for i in range(length):
        t = i / RATE
        if t < a:
            v = t / a if a > 0 else 1.0
        elif t < a + d:
            v = 1.0 - (1.0 - s) * (t - a) / d
        elif t < a + d + hold:
            v = s
        else:
            rt = t - a - d - hold
            v = s * max(0.0, 1.0 - rt / r) if r > 0 else s
        out.append(v)
    return out


def osc(kind, f0, f1, sec, phase=0.0):
    """Oszillator mit linearem Frequenzverlauf f0 -> f1."""
    length = n(sec)
    out = []
    ph = phase
    for i in range(length):
        f = f0 + (f1 - f0) * i / max(1, length - 1)
        ph += f / RATE
        x = ph % 1.0
        if kind == 'sin':
            v = math.sin(2 * math.pi * ph)
        elif kind == 'sq':
            v = 1.0 if x < 0.5 else -1.0
        elif kind == 'saw':
            v = 2.0 * x - 1.0
        elif kind == 'tri':
            v = 4.0 * abs(x - 0.5) - 1.0
        else:
            v = 0.0
        out.append(v)
    return out


def noise(sec):
    return [rng.uniform(-1, 1) for _ in range(n(sec))]


def lowpass(sig, cutoff):
    a = 1.0 - math.exp(-2 * math.pi * cutoff / RATE)
    y = 0.0
    out = []
    for v in sig:
        y += a * (v - y)
        out.append(y)
    return out


def highpass(sig, cutoff):
    low = lowpass(sig, cutoff)
    return [v - l for v, l in zip(sig, low)]


def bandpass(sig, lo, hi):
    return lowpass(highpass(sig, lo), hi)


def mul(a, b):
    return [x * y for x, y in zip(a, b)]


def gain(sig, g):
    return [v * g for v in sig]


def mix(*sigs):
    length = max(len(s) for s in sigs)
    out = [0.0] * length
    for s in sigs:
        for i, v in enumerate(s):
            out[i] += v
    return out


def place(base, sig, at_sec):
    """Mischt sig ab Sekunde at_sec in base (Schleifen: Ueberhang beginnt vorn)."""
    start = n(at_sec)
    for i, v in enumerate(sig):
        base[(start + i) % len(base)] += v
    return base


def concat(*sigs):
    out = []
    for s in sigs:
        out += s
    return out


def tone(kind, f0, f1, sec, a=0.003, d=None, s=0.0, r=0.0, vol=1.0):
    d = sec if d is None else d
    return gain(mul(osc(kind, f0, f1, sec), env(n(sec), a, d, s, r)), vol)


def thud(sec=0.12, f0=140, f1=45, vol=1.0, cutoff=400):
    body = tone('sin', f0, f1, sec, a=0.002, d=sec)
    grit = gain(mul(lowpass(noise(sec), cutoff), env(n(sec), 0.001, sec * 0.6)), 0.8)
    return gain(mix(body, grit), vol)


def bell(freqs, sec, vol=1.0, decay=None):
    decay = decay or sec
    return gain(mix(*[tone('sin', f, f, sec, a=0.002, d=decay, vol=1.0 / (k + 1)) for k, f in enumerate(freqs)]), vol)


def normalize(sig, peak=0.85):
    m = max(1e-9, max(abs(v) for v in sig))
    return [v * peak / m for v in sig]


def fade_edges(sig, sec=0.004):
    k = min(n(sec), len(sig) // 2)
    for i in range(k):
        f = i / k
        sig[i] *= f
        sig[-1 - i] *= f
    return sig


def save(name, sig, peak=0.85, loop=False):
    sig = normalize(sig, peak)
    if not loop:
        sig = fade_edges(sig)
    path = os.path.join(OUT, name + '.wav')
    with wave.open(path, 'wb') as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(RATE)
        w.writeframes(b''.join(struct.pack('<h', int(max(-1, min(1, v)) * 32767)) for v in sig))
    print('ok', name, round(len(sig) / RATE, 2), 's')


def loop_noise(sec, cutoff_lo, cutoff_hi):
    """Gefiltertes Rauschen, nahtlos: Ueberblendung von Ende in Anfang."""
    sig = bandpass(noise(sec + 0.3), cutoff_lo, cutoff_hi)
    over = n(0.3)
    body = sig[:n(sec)]
    tail = sig[n(sec):n(sec) + over]
    for i in range(len(tail)):
        f = i / len(tail)
        body[i] = body[i] * f + tail[i] * (1 - f)
    return body


def build():
    os.makedirs(OUT, exist_ok=True)
    # --- Spielfigur ---------------------------------------------------------------------
    for i, (cut, f0) in enumerate([(900, 170), (700, 150), (1100, 190)]):
        save('step_%d' % (i + 1), concat(thud(0.07, f0, 60, 1.0, cut), silence(0.02)), peak=0.5)
    save('jump', mix(tone('sq', 260, 620, 0.12, d=0.12, vol=0.35), gain(mul(bandpass(noise(0.16), 800, 3000), env(n(0.16), 0.01, 0.15)), 0.4)), peak=0.6)
    save('land', concat(thud(0.14, 150, 45, 1.0, 500), silence(0.02)), peak=0.7)
    save('land_hard', mix(thud(0.3, 120, 30, 1.0, 600), gain(mul(lowpass(noise(0.35), 250), env(n(0.35), 0.002, 0.33)), 0.9)), peak=0.85)
    save('death', mix(tone('saw', 900, 70, 0.45, d=0.45, vol=0.5), gain(mul(highpass(noise(0.45), 2000), env(n(0.45), 0.001, 0.3)), 0.6), tone('sq', 440, 110, 0.3, d=0.3, vol=0.25)), peak=0.75)
    spawn = silence(0.7)
    for k, f in enumerate([392, 523, 659, 784, 1046]):
        place(spawn, mul(tone('sin', f, f * 1.01, 0.3, a=0.01, d=0.29), osc('sin', 18, 18, 0.3)), k * 0.08)
    place(spawn, gain(mul(highpass(noise(0.7), 4000), env(n(0.7), 0.05, 0.6)), 0.25), 0)
    save('spawn', spawn, peak=0.6)
    save('exit_door', mix(gain(mul(bandpass(noise(0.5), 300, 1500), env(n(0.5), 0.05, 0.4)), 0.6), tone('sin', 200, 520, 0.5, a=0.05, d=0.45, vol=0.4)), peak=0.6)
    save('transition', gain(mul(bandpass(noise(0.45), 200, 2500), env(n(0.45), 0.2, 0.25)), 1.0), peak=0.45)

    # --- Time Shifter -------------------------------------------------------------------
    save('panel_open', mix(thud(0.08, 300, 120, 0.8, 1500), tone('sin', 180, 420, 0.18, a=0.01, d=0.17, vol=0.5)), peak=0.55)
    save('panel_close', mix(thud(0.08, 260, 100, 0.8, 1200), tone('sin', 420, 160, 0.16, a=0.005, d=0.15, vol=0.45)), peak=0.5)
    save('stage_slow', mix(tone('sin', 700, 110, 0.5, a=0.01, d=0.49, vol=0.6), gain(mul(lowpass(noise(0.5), 700), env(n(0.5), 0.05, 0.45)), 0.5)), peak=0.6)
    save('stage_fast', mix(tone('sin', 180, 1300, 0.35, a=0.01, d=0.34, vol=0.5), tone('sq', 360, 2600, 0.25, d=0.25, vol=0.15), gain(mul(highpass(noise(0.35), 1500), env(n(0.35), 0.02, 0.33)), 0.4)), peak=0.6)
    save('stage_normal', mix(tone('sin', 660, 660, 0.12, d=0.12, vol=0.6), tone('sin', 990, 990, 0.1, d=0.1, vol=0.3)), peak=0.5)
    save('knob_tick', concat(mix(gain(mul(highpass(noise(0.015), 3000), env(n(0.015), 0.0005, 0.014)), 1.0), tone('sin', 2200, 2200, 0.015, d=0.015, vol=0.4)), silence(0.01)), peak=0.35)
    save('cursor_tick', concat(tone('sin', 1700, 1500, 0.02, d=0.02), silence(0.01)), peak=0.25)
    slow = mix(mul(osc('sin', 70, 70, 2.0), [0.6] * n(2.0)), gain(osc('sin', 72, 72, 2.0), 0.5), gain(osc('sin', 140.5, 140.5, 2.0), 0.15), gain(loop_noise(2.0, 60, 300), 0.3))
    save('bubble_slow_loop', slow, peak=0.5, loop=True)
    trem = [0.6 + 0.4 * math.sin(2 * math.pi * 8 * i / RATE) for i in range(n(1.0))]
    fast = mix(mul(lowpass(osc('saw', 220, 220, 1.0), 1800), trem), gain(osc('sin', 440, 440, 1.0), 0.2), gain(loop_noise(1.0, 2000, 6000), 0.15))
    save('bubble_fast_loop', fast, peak=0.45, loop=True)

    # --- Objekte --------------------------------------------------------------------------
    wob = [0.8 + 0.2 * math.sin(2 * math.pi * 2 * i / RATE) for i in range(n(1.0))]
    save('platform_loop', mul(mix(osc('sin', 110, 110, 1.0), gain(osc('sin', 220, 220, 1.0), 0.3)), wob), peak=0.3, loop=True)
    save('barrier_beep', concat(tone('sin', 1000, 1000, 0.07, d=0.07), tone('sin', 1500, 1500, 0.09, d=0.09)), peak=0.5)
    save('laser_warn', concat(tone('sq', 900, 900, 0.05, d=0.05, vol=0.5), silence(0.05), tone('sq', 900, 900, 0.05, d=0.05, vol=0.5)), peak=0.35)
    save('laser_on', mix(tone('saw', 200, 1600, 0.2, d=0.2, vol=0.5), gain(mul(highpass(noise(0.2), 2500), env(n(0.2), 0.001, 0.18)), 0.7)), peak=0.6)
    save('laser_loop', mix(gain(lowpass(osc('saw', 120, 120, 1.0), 900), 0.6), gain(loop_noise(1.0, 3000, 8000), 0.25), gain(osc('sin', 240, 240, 1.0), 0.2)), peak=0.35, loop=True)
    crack = gain(loop_noise(1.5, 1500, 7000), 0.08)
    for _ in range(26):
        at = rng.uniform(0, 1.45)
        place(crack, gain(mul(highpass(noise(0.02), 2000), env(n(0.02), 0.0005, 0.019)), rng.uniform(0.4, 1.0)), at)
    save('electric_loop', crack, peak=0.4, loop=True)
    save('launcher_fire', mix(thud(0.22, 110, 35, 1.0, 700), gain(mul(lowpass(noise(0.25), 1800), env(n(0.25), 0.001, 0.2)), 0.6)), peak=0.75)
    save('projectile_loop', mix(gain(loop_noise(1.0, 400, 2500), 0.8), gain(osc('sin', 90, 90, 1.0), 0.2)), peak=0.3, loop=True)
    save('projectile_hit', mix(gain(mul(lowpass(noise(0.6), 900), env(n(0.6), 0.001, 0.55)), 1.0), tone('sin', 80, 30, 0.4, d=0.4, vol=0.8)), peak=0.8)
    save('impact_switch', bell([1320, 2640, 3960], 0.6, decay=0.55), peak=0.5)
    save('door_open', mix(tone('saw', 140, 230, 0.4, a=0.02, d=0.38, vol=0.35), gain(mul(bandpass(noise(0.4), 300, 1200), env(n(0.4), 0.02, 0.38)), 0.4)), peak=0.5)
    save('door_close', concat(mix(tone('saw', 230, 140, 0.35, a=0.02, d=0.33, vol=0.35), gain(mul(bandpass(noise(0.35), 300, 1200), env(n(0.35), 0.02, 0.33)), 0.4)), thud(0.1, 160, 60, 0.8, 600)), peak=0.55)
    tick = silence(1.0)
    place(tick, concat(mix(gain(mul(highpass(noise(0.012), 3000), env(n(0.012), 0.0005, 0.011)), 1.0), tone('sin', 2600, 2600, 0.012, d=0.012, vol=0.5))), 0.0)
    place(tick, concat(mix(gain(mul(highpass(noise(0.012), 2000), env(n(0.012), 0.0005, 0.011)), 0.8), tone('sin', 1900, 1900, 0.012, d=0.012, vol=0.4))), 0.5)
    save('timer_loop', tick, peak=0.35, loop=True)
    ring = mix(*[gain(mul(bell([2100, 3150, 4720], 0.25, decay=0.2), [1.0] * n(0.25)), 1.0)])
    save('timer_ring', concat(ring, ring, ring), peak=0.45)
    save('pendulum_swoosh', gain(mul(bandpass(noise(0.3), 300, 1600), env(n(0.3), 0.12, 0.17)), 1.0), peak=0.35)
    mag_trem = [0.75 + 0.25 * math.sin(2 * math.pi * 3 * i / RATE) for i in range(n(1.0))]
    save('magnet_loop', mul(mix(osc('sin', 60, 60, 1.0), gain(osc('sin', 120, 120, 1.0), 0.5), gain(lowpass(osc('saw', 180, 180, 1.0), 600), 0.3)), mag_trem), peak=0.4, loop=True)
    save('steam_hiss', gain(mul(highpass(noise(0.7), 2500), env(n(0.7), 0.04, 0.2, 0.5, 0.4, 0.06)), 1.0), peak=0.3)
    save('elevator_denied', concat(tone('sq', 150, 150, 0.14, d=0.14, vol=0.5), silence(0.06), tone('sq', 120, 120, 0.2, d=0.2, vol=0.5)), peak=0.4)
    save('elevator_ding', bell([880, 1320, 1760], 0.9, decay=0.85), peak=0.5)

    # --- Einsammeln, Oberflaeche --------------------------------------------------------
    clank = bell([830, 1230, 1870, 2650], 0.35, decay=0.3)
    sparkle = silence(0.6)
    for k, f in enumerate([1568, 2093, 2637, 3136]):
        place(sparkle, tone('sin', f, f, 0.18, d=0.17, vol=0.5), 0.12 + k * 0.06)
    save('scrap_pickup', mix(clank, sparkle), peak=0.6)
    fan = silence(1.0)
    for k, f in enumerate([523, 659, 784, 1046]):
        place(fan, lowpass(tone('sq', f, f, 0.35 if k == 3 else 0.14, d=0.3 if k == 3 else 0.12, vol=0.4), 3000), k * 0.12)
    save('upgrade', fan, peak=0.55)
    save('coin', concat(tone('sq', 988, 988, 0.07, d=0.07, s=1.0, vol=0.4), tone('sq', 1319, 1319, 0.25, d=0.24, vol=0.4)), peak=0.45)
    for i, f in enumerate([520, 610, 700]):
        save('speech_blip_%d' % (i + 1), concat(lowpass(tone('sq', f, f * 0.95, 0.04, d=0.04, vol=0.5), 2500), silence(0.01)), peak=0.25)
    save('ui_hover', concat(tone('sin', 1200, 1200, 0.025, d=0.025), silence(0.01)), peak=0.2)
    save('ui_click', mix(gain(mul(highpass(noise(0.02), 2000), env(n(0.02), 0.0005, 0.019)), 0.6), tone('sin', 880, 1320, 0.08, d=0.08, vol=0.5)), peak=0.4)
    save('page_flip', gain(mul(bandpass(noise(0.22), 1500, 6000), env(n(0.22), 0.03, 0.18)), 1.0), peak=0.35)

    # --- Umgebung (8 s, nahtlos) --------------------------------------------------------
    L = 8.0

    def hum(base, vol=1.0):
        return mix(gain(osc('sin', base, base, L), 0.6 * vol), gain(osc('sin', base * 2, base * 2, L), 0.25 * vol), gain(osc('sin', base * 3, base * 3, L), 0.08 * vol))

    lab = mix(hum(55), gain(loop_noise(L, 80, 600), 0.25))
    for at, f in [(1.3, 1320), (1.45, 1760), (4.7, 990), (6.2, 1480), (6.32, 1480)]:
        place(lab, tone('sin', f, f, 0.08, d=0.08, vol=0.06), at)
    save('ambient_workshop', lab, peak=0.35, loop=True)
    fac = mix(hum(45, 0.8), gain(loop_noise(L, 100, 800), 0.3))
    for k in range(8):
        place(fac, gain(thud(0.25, 90, 35, 1.0, 400), 0.5), k * 1.0)
        place(fac, gain(mul(bandpass(noise(0.15), 2000, 5000), env(n(0.15), 0.01, 0.14)), 0.12), k * 1.0 + 0.5)
    save('ambient_factory', fac, peak=0.4, loop=True)
    chem = mix(hum(50, 0.5), gain(loop_noise(L, 200, 1200), 0.15))
    for _ in range(40):
        f = rng.uniform(300, 900)
        place(chem, tone('sin', f, f * 1.6, 0.06, d=0.06, vol=0.12), rng.uniform(0, L))
    save('ambient_chemical', chem, peak=0.35, loop=True)
    ele = mix(hum(60), gain(lowpass(osc('saw', 120, 120, L), 500), 0.15), gain(loop_noise(L, 2500, 7000), 0.06))
    for _ in range(14):
        place(ele, gain(mul(highpass(noise(0.03), 2500), env(n(0.03), 0.001, 0.028)), 0.35), rng.uniform(0, L))
    save('ambient_electro', ele, peak=0.35, loop=True)
    mtrem = [0.7 + 0.3 * math.sin(2 * math.pi * 0.25 * i / RATE) for i in range(n(L))]
    mag = mul(mix(hum(40, 1.0), gain(osc('sin', 80.5, 80.5, L), 0.3)), mtrem)
    save('ambient_magnet', mix(mag, gain(loop_noise(L, 60, 300), 0.2)), peak=0.35, loop=True)
    q = mix(gain(osc('sin', 220, 220, L), 0.25), gain(osc('sin', 220.5, 220.5, L), 0.25), gain(osc('sin', 330, 330, L), 0.15), gain(osc('sin', 331, 331, L), 0.15), gain(loop_noise(L, 3000, 9000), 0.04))
    for _ in range(18):
        f = rng.choice([1760, 2093, 2349, 2637, 3136])
        place(q, tone('sin', f, f, 0.4, a=0.02, d=0.38, vol=0.05), rng.uniform(0, L))
    save('ambient_quantum', q, peak=0.3, loop=True)


if __name__ == '__main__':
    build()
