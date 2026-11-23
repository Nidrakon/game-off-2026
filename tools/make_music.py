"""Erzeugt die Musik des Spiels als nahtlose OGG-Schleifen (44,1 kHz, Stereo).

Laeuft im Python von Blender (bringt numpy und einen OGG-Vorbis-Encoder mit,
Modul "aud"). Aufruf im Projektordner:

    blender -b --factory-startup --python tools/make_music.py -- [IDs] [--wav ORDNER]

Ohne IDs werden alle Songs geschrieben (audio/music/music_XX_name.ogg).
"--wav ORDNER" schreibt zusaetzlich WAV-Dateien (zum Pruefen).

Aufbau: kleiner Sequenzer (Takte, Akkorde, Melodien als Text), Instrumente
aus Obertoenen (additive Synthese, FM), Schlagzeug aus Rauschen und Sinus,
Hall per Faltung. Alles wird ringfoermig in die Schleifenlaenge gelegt
(Ausklang am Ende landet vorn), deshalb springt die Schleife nicht.
Songs und IDs: projektdokumentation.md, Kapitel 1.7.
"""
import math
import os
import sys
import wave

import numpy as np

SR = 44100
ROOT = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..')
OUT = os.path.join(ROOT, 'audio', 'music')
BITRATE = 112000
rng = np.random.default_rng(2026)

# --- Grundbausteine ------------------------------------------------------------------------

NOTE_PC = {'C': 0, 'D': 2, 'E': 4, 'F': 5, 'G': 7, 'A': 9, 'B': 11}
CHORD_TYPES = {'maj9': [0, 4, 7, 11, 14], 'm9': [0, 3, 7, 10, 14], '9': [0, 4, 7, 10, 14], 'maj7': [0, 4, 7, 11], 'm7': [0, 3, 7, 10], 'm6': [0, 3, 7, 9], 'm': [0, 3, 7], '7': [0, 4, 7, 10], '': [0, 4, 7]}


def midi_of(name):
    """'C#5' -> 73."""
    pc = NOTE_PC[name[0]]
    rest = name[1:]
    while rest and rest[0] in '#b':
        pc += 1 if rest[0] == '#' else -1
        rest = rest[1:]
    return 12 * (int(rest) + 1) + pc


def hz(midi):
    return 440.0 * 2 ** ((midi - 69) / 12.0)


def chord(sym):
    """'Ebmaj7' -> (Grundton-Tonklasse, Intervalle)."""
    pc = NOTE_PC[sym[0]]
    rest = sym[1:]
    if rest[:1] in ('#', 'b'):
        pc += 1 if rest[0] == '#' else -1
        rest = rest[1:]
    return pc % 12, CHORD_TYPES[rest]


def env_adsr(dur, a=0.01, d=0.1, s=0.7, r=0.1):
    """Huellkurve: Anstieg a, Abfall (Zeitkonstante d) auf s, nach dur Ausklang r."""
    n_on = max(1, int(dur * SR))
    n = n_on + int(r * 5 * SR)
    t = np.arange(n) / SR
    e = np.where(t < a, t / max(a, 1e-4), s + (1 - s) * np.exp(-(t - a) / max(d, 1e-4)))
    level = e[n_on - 1]
    e[n_on:] = level * np.exp(-(t[n_on:] - dur) / max(r, 1e-4))
    return e


def phase(f, n, vib=None):
    """Phase (Radiant) eines Tons mit optionalem Vibrato (Rate, Tiefe, Einsatz)."""
    t = np.arange(n) / SR
    if vib is None:
        return 2 * np.pi * f * t
    rate, depth, delay = vib
    inst = f * (1 + depth * np.sin(2 * np.pi * rate * t) * np.clip(t / max(delay, 1e-3), 0, 1))
    return 2 * np.pi * np.cumsum(inst) / SR


def partials(ph, n, ratios, amps, decays=None):
    t = np.arange(n) / SR
    out = np.zeros(n)
    for i, (k, a) in enumerate(zip(ratios, amps)):
        if a == 0:
            continue
        p = np.sin(k * ph + rng.uniform(0, 6.283))
        if decays is not None and decays[i]:
            p *= np.exp(-t / decays[i])
        out += a * p
    return out


def harmonics_below(f, limit=9000.0, kmax=20):
    return [k for k in range(1, kmax + 1) if k * f < limit]


def noise(n):
    return rng.uniform(-1, 1, n)


def hp(x, times=1):
    for _ in range(times):
        x = np.diff(x, prepend=0.0)
    return x


# --- Instrumente: f (Hz), dur (Sekunden gehalten), vel (0..1) -> Mono-Signal --------------

def inst_lead(f, dur, vel):
    """Weicher Puls-Lead mit Vibrato."""
    e = env_adsr(dur, 0.012, 0.18, 0.72, 0.09)
    ks = harmonics_below(f, 8000, 16)
    amps = [(1.0 / k if k % 2 else 0.3 / k) * math.exp(-k / 6.0) for k in ks]
    return partials(phase(f, len(e), (5.5, 0.006, 0.3)), len(e), ks, amps) * e * vel


def inst_chip(f, dur, vel):
    """Kurzer Rechteck-Ton fuer Arpeggios."""
    e = env_adsr(dur, 0.003, 0.08, 0.25, 0.05)
    ks = [k for k in harmonics_below(f, 7000, 13) if k % 2]
    amps = [math.exp(-k / 4.0) / k for k in ks]
    return partials(phase(f, len(e)), len(e), ks, amps) * e * vel


def inst_pluck(f, dur, vel):
    """Gezupft (Gitarre/Harfe): helle Obertoene klingen schneller ab."""
    e = env_adsr(dur, 0.002, 0.6, 0.0, 0.08)
    ks = harmonics_below(f, 8000, 14)
    amps = [1.0 / k for k in ks]
    decays = [0.5 / (1 + 0.45 * (k - 1)) for k in ks]
    return partials(phase(f, len(e)), len(e), ks, amps, decays) * e * vel


def inst_marimba(f, dur, vel):
    e = env_adsr(max(dur, 0.3), 0.001, 0.4 * min(1.0, 440.0 / f) + 0.12, 0.0, 0.1)
    n = len(e)
    s = partials(phase(f, n), n, [1, 3.93, 9.2], [1.0, 0.3, 0.1], [0.6, 0.1, 0.03])
    click = noise(n) * np.exp(-np.arange(n) / (0.002 * SR)) * 0.15
    return (s + hp(click)) * e * vel


def inst_vibes(f, dur, vel):
    e = env_adsr(max(dur, 0.4), 0.002, 1.4, 0.0, 0.35)
    n = len(e)
    t = np.arange(n) / SR
    s = partials(phase(f, n), n, [1, 4.0, 10.0], [1.0, 0.25, 0.06], [1.6, 0.3, 0.08])
    trem = 1 - 0.22 * (0.5 + 0.5 * np.sin(2 * np.pi * 5.2 * t))
    return s * trem * e * vel


def inst_rhodes(f, dur, vel):
    """E-Piano (2-Operator-FM): glockiger Anschlag, warmer Ausklang."""
    e = env_adsr(dur, 0.003, 1.1, 0.2, 0.22)
    n = len(e)
    t = np.arange(n) / SR
    ph = phase(f, n)
    index = 1.6 * np.exp(-t / 0.22) + 0.35
    s = np.sin(ph + index * np.sin(ph)) + 0.12 * np.sin(2 * ph) * np.exp(-t / 0.5)
    tine = 0.1 * np.sin(14 * ph) * np.exp(-t / 0.015)
    return (s + tine) * e * vel


def inst_bass(f, dur, vel):
    """Runder Synth-Bass, kurz heller Anschlag."""
    e = env_adsr(dur, 0.004, 0.22, 0.65, 0.05)
    n = len(e)
    ks = harmonics_below(f, 3000, 10)
    ph = phase(f, n)
    body = partials(ph, n, ks, [1.0 / k ** 1.7 for k in ks])
    bite = partials(ph, n, ks[1:], [0.6 / k for k in ks[1:]], [0.06] * (len(ks) - 1))
    return (body + bite) * e * vel


def inst_pad(f, dur, vel):
    """Weiche Flaeche aus drei leicht verstimmten Saegezaehnen."""
    e = env_adsr(dur, 0.35, 0.6, 0.85, 0.6)
    n = len(e)
    ks = harmonics_below(f, 5000, 10)
    amps = [math.exp(-k / 3.0) / k for k in ks]
    out = np.zeros(n)
    for cents in (-7, 0, 7):
        out += partials(phase(f * 2 ** (cents / 1200), n), n, ks, amps)
    return out / 3 * e * vel


def inst_flute(f, dur, vel):
    e = env_adsr(dur, 0.06, 0.15, 0.85, 0.12)
    n = len(e)
    s = partials(phase(f, n, (5.0, 0.007, 0.25)), n, [1, 2, 3], [1.0, 0.18, 0.06])
    breath = hp(noise(n), 2) * 0.04 * np.exp(-np.arange(n) / (0.08 * SR)) + hp(noise(n), 2) * 0.012
    return (s + breath) * e * vel


def inst_lofi_keys(f, dur, vel):
    """Lo-Fi-E-Piano: weicher als das Rhodes, leicht leiernd (Band)."""
    e = env_adsr(dur, 0.006, 1.4, 0.25, 0.35)
    n = len(e)
    t = np.arange(n) / SR
    ph = phase(f, n, (0.7, 0.0025, 0.01))
    index = 0.9 * np.exp(-t / 0.18) + 0.2
    s = np.sin(ph + index * np.sin(ph)) + 0.08 * np.sin(2 * ph) * np.exp(-t / 0.6)
    return s * e * vel


def inst_lofi_bass(f, dur, vel):
    """Runder, dunkler Bass (fast nur Grundton)."""
    e = env_adsr(dur, 0.008, 0.4, 0.7, 0.08)
    n = len(e)
    ks = harmonics_below(f, 1200, 5)
    return partials(phase(f, n), n, ks, [1.0 / k ** 2.2 for k in ks]) * e * vel


def inst_lofi_pluck(f, dur, vel):
    """Gedaempfte Gitarre: kurz, dunkel."""
    e = env_adsr(dur, 0.002, 0.25, 0.0, 0.06)
    ks = harmonics_below(f, 4000, 10)
    decays = [0.3 / (1 + 0.8 * (k - 1)) for k in ks]
    return partials(phase(f, len(e)), len(e), ks, [1.0 / k for k in ks], decays) * e * vel


# Schlagzeug (f wird ignoriert)
def drum_kick(f, dur, vel):
    n = int(0.35 * SR)
    t = np.arange(n) / SR
    fr = 45 + 75 * np.exp(-t / 0.03)
    s = np.sin(2 * np.pi * np.cumsum(fr) / SR) * np.exp(-t / 0.13)
    click = hp(noise(n)) * np.exp(-t / 0.002) * 0.2
    return (s + click) * vel


def drum_snare(f, dur, vel):
    n = int(0.25 * SR)
    t = np.arange(n) / SR
    tone = np.sin(2 * np.pi * 190 * t) * np.exp(-t / 0.04) * 0.5
    sn = hp(noise(n)) * np.exp(-t / 0.09) * 0.7
    return (tone + sn) * vel


def drum_hat(f, dur, vel):
    n = int(0.08 * SR)
    t = np.arange(n) / SR
    return hp(noise(n), 2) * np.exp(-t / 0.018) * 0.5 * vel


def drum_shaker(f, dur, vel):
    n = int(0.09 * SR)
    t = np.arange(n) / SR
    e = np.minimum(t / 0.012, 1) * np.exp(-t / 0.035)
    return hp(noise(n), 2) * e * 0.4 * vel


def drum_rim(f, dur, vel):
    n = int(0.06 * SR)
    t = np.arange(n) / SR
    return (np.sin(2 * np.pi * 1700 * t) * 0.6 + np.sin(2 * np.pi * 820 * t) * 0.4) * np.exp(-t / 0.012) * vel


def drum_tick(f, dur, vel):
    """Uhr: "tick" (hoch)."""
    n = int(0.05 * SR)
    t = np.arange(n) / SR
    return (np.sin(2 * np.pi * 3100 * t) + 0.6 * np.sin(2 * np.pi * 4700 * t)) * np.exp(-t / 0.006) * vel


def drum_tock(f, dur, vel):
    """Uhr: "tack" (tiefer, holziger)."""
    n = int(0.06 * SR)
    t = np.arange(n) / SR
    return (np.sin(2 * np.pi * 1350 * t) + 0.5 * np.sin(2 * np.pi * 2250 * t)) * np.exp(-t / 0.01) * vel


def drum_lofi_kick(f, dur, vel):
    """Weiche, runde Kick (Boom-Bap, leise)."""
    n = int(0.4 * SR)
    t = np.arange(n) / SR
    fr = 50 + 45 * np.exp(-t / 0.04)
    return np.sin(2 * np.pi * np.cumsum(fr) / SR) * np.exp(-t / 0.16) * vel


def drum_lofi_snare(f, dur, vel):
    """Dumpfe Snare mit langem Rauschen (wie vom Sampler)."""
    n = int(0.35 * SR)
    t = np.arange(n) / SR
    body = np.sin(2 * np.pi * 180 * t) * np.exp(-t / 0.05) * 0.4
    sn = hp(noise(n)) * np.exp(-t / 0.13) * 0.5
    spec = np.fft.rfft(sn)
    freqs = np.fft.rfftfreq(n, 1 / SR)
    sn = np.fft.irfft(spec / (1 + (freqs / 3500.0) ** 2), n)
    return (body + sn * 3.0) * vel


def drum_clank(f, dur, vel):
    """Werkstatt: kurzer Schlag auf Metall."""
    n = int(0.4 * SR)
    t = np.arange(n) / SR
    base = 520
    s = sum(a * np.sin(2 * np.pi * base * r * t + rng.uniform(0, 6.28)) * np.exp(-t / d) for r, a, d in [(1, 1, 0.12), (2.76, 0.5, 0.06), (5.4, 0.25, 0.03), (1.5, 0.4, 0.08)])
    hit = hp(noise(n)) * np.exp(-t / 0.004) * 0.4
    return (s * 0.6 + hit) * vel


# Pegelausgleich je Instrument (nach Messung der Spurpegel; Bass klingt sonst
# zu dick, kurze Klicks gehen unter).
TRIM = {'bass': 0.55, 'lofi_bass': 0.5, 'lofi_snare': 2.2, 'tick': 2.5, 'tock': 2.5, 'hat': 2.0, 'rim': 2.2, 'snare': 1.5, 'clank': 1.6}

INSTRUMENTS = {
    'lead': inst_lead, 'chip': inst_chip, 'pluck': inst_pluck, 'marimba': inst_marimba, 'vibes': inst_vibes,
    'rhodes': inst_rhodes, 'bass': inst_bass, 'pad': inst_pad, 'flute': inst_flute,
    'kick': drum_kick, 'snare': drum_snare, 'hat': drum_hat, 'shaker': drum_shaker, 'rim': drum_rim,
    'tick': drum_tick, 'tock': drum_tock, 'clank': drum_clank,
    'lofi_keys': inst_lofi_keys, 'lofi_bass': inst_lofi_bass, 'lofi_pluck': inst_lofi_pluck,
    'lofi_kick': drum_lofi_kick, 'lofi_snare': drum_lofi_snare,
}


# --- Sequenzer -----------------------------------------------------------------------------

class Score:
    """Ein Song: Takte zu 4 Schlaegen, Spuren mit Noten. Schlag 0 = Takt 1."""

    def __init__(self, bpm, bars, swing=0.0):
        self.bpm = bpm
        self.bars = bars
        self.beat = 60.0 / bpm
        self.length = int(round(bars * 4 * self.beat * SR))
        self.swing = swing
        self.tracks = {}
        # Lo-Fi (seit v0.64): Schlaege leicht ungenau (Schlaege), Hoehen
        # gedaempft (Hz), Band-Leiern (Tonhoehe, Anteil), Vinyl-Knistern,
        # Zielpegel des Masters (dB).
        self.humanize = 0.0
        self.lowpass = 0.0
        self.wow = 0.0
        self.crackle = 0.0
        self.target_db = -19.0

    def track(self, name, inst, gain=1.0, pan=0.0, send=0.2, duck=0.0):
        self.tracks[name] = {'inst': inst, 'gain': gain, 'pan': pan, 'send': send, 'duck': duck, 'events': []}

    def note(self, name, beat, midi, beats, vel=0.8):
        if abs(beat % 1.0 - 0.5) < 1e-6:
            beat += self.swing
        if self.humanize:
            beat += float(rng.normal(0.0, self.humanize))
            vel *= 1.0 + float(rng.uniform(-0.15, 0.15))
        self.tracks[name]['events'].append((beat * self.beat, hz(midi) if midi else 0.0, beats * self.beat, vel))

    def melody(self, name, text, bar, transpose=0, vel=0.8):
        """Text "G4:1.5 C5:0.5 r:1" (Note:Schlaege) ab Takt bar (1-basiert)."""
        beat = (bar - 1) * 4
        for token in text.split():
            n, d = token.split(':')
            d = float(d)
            if n != 'r':
                self.note(name, beat, midi_of(n) + transpose, d * 0.95, vel)
            beat += d

    def chord_notes(self, sym, octave, with_octave=False):
        pc, ints = chord(sym)
        root = 12 * (octave + 1) + pc
        notes = [root + i for i in ints]
        if with_octave:
            notes.append(root + 12)
        return notes

    def arp(self, name, chords, bars, pattern, step=0.25, octave=4, vel=0.5, length=0.9):
        for b in bars:
            tones = self.chord_notes(chords[b - 1], octave, True)
            for i, p in enumerate(pattern):
                if p is None:
                    continue
                self.note(name, (b - 1) * 4 + i * step, tones[p % len(tones)] + 12 * (p // len(tones)), step * length, vel)

    def bass(self, name, chords, bars, pattern, octave=2, vel=0.8):
        """pattern: (Schlag im Takt, 'r' Grundton | '3' Terz | '5' Quinte | 'o' Oktave, Laenge)."""
        for b in bars:
            pc, ints = chord(chords[b - 1])
            root = 12 * (octave + 1) + pc
            for beat, deg, dur in pattern:
                m = root + {'r': 0, '3': ints[1], '5': 7, 'o': 12, '7': ints[3] if len(ints) > 3 else 10}[deg]
                self.note(name, (b - 1) * 4 + beat, m, dur, vel)

    def block(self, name, chords, bars, beats, dur, octave=4, vel=0.5):
        """Akkord-Anschlaege an Schlaegen "beats" (Liste je Takt oder Liste von Listen im Wechsel)."""
        for i, b in enumerate(bars):
            hits = beats[i % len(beats)] if isinstance(beats[0], list) else beats
            for beat in hits:
                for m in self.chord_notes(chords[b - 1], octave):
                    self.note(name, (b - 1) * 4 + beat, m, dur, vel)

    def drums(self, name, pattern, bars, vel=0.8):
        """16 Zeichen je Takt: x = laut, o = leise, . = nichts."""
        for b in bars:
            for i, c in enumerate(pattern):
                if c in 'xo':
                    self.note(name, (b - 1) * 4 + i * 0.25, 0, 0.25, vel if c == 'x' else vel * 0.45)

    # --- Mischung ---
    def render(self):
        L = self.length
        mix = np.zeros((L, 2))
        send = np.zeros((L, 2))
        t = np.arange(L) / SR
        duck_env = 1 - np.exp(-(t % self.beat) / 0.11)  # Pumpen im Takt der Viertel
        for name, tr in self.tracks.items():
            mono = np.zeros(L)
            fn = INSTRUMENTS[tr['inst']]
            for start, f, dur, vel in tr['events']:
                sig = fn(f, dur, vel)
                s0 = int(round(start * SR)) % L
                n = len(sig)
                first = min(n, L - s0)
                mono[s0:s0 + first] += sig[:first]
                rest = sig[first:]
                while len(rest):
                    k = min(len(rest), L)
                    mono[:k] += rest[:k]
                    rest = rest[k:]
            if tr['duck']:
                mono *= 1 - tr['duck'] * (1 - duck_env)
            mono *= tr['gain'] * TRIM.get(tr['inst'], 1.0)
            left = math.cos((tr['pan'] + 1) * math.pi / 4)
            right = math.sin((tr['pan'] + 1) * math.pi / 4)
            st = np.stack([mono * left, mono * right], 1)
            mix += st
            send += st * tr['send']
        mix += reverb(send, L)
        if self.lowpass:
            mix = lowpass_loop(mix, self.lowpass)
        if self.wow:
            mix = tape_wow(mix, self.wow, self.bars * 4 * self.beat)
        if self.crackle:
            mix += vinyl(L) * self.crackle
        return master(mix, self.target_db)


def reverb(x, L, rt=1.8):
    """Ringfoermige Faltung mit kuenstlichem Raum (dunkler werdendes Rauschen)."""
    n_ir = min(L, int(rt * SR))
    t = np.arange(n_ir) / SR
    out = np.zeros_like(x)
    for ch in range(2):
        ir = noise(n_ir) * np.exp(-t * 6.9 / rt)
        ir[:int(0.012 * SR)] = 0
        spec = np.fft.rfft(ir)
        freqs = np.fft.rfftfreq(n_ir, 1 / SR)
        spec *= 1 / (1 + (freqs / 4500.0) ** 2)
        ir = np.fft.irfft(spec, n_ir)
        ir /= np.sqrt(np.sum(ir ** 2)) + 1e-9
        full = np.zeros(L)
        full[:n_ir] = ir
        out[:, ch] = np.fft.irfft(np.fft.rfft(x[:, ch]) * np.fft.rfft(full), L)
    return out * 0.6


def lowpass_loop(x, cutoff):
    """Sanfter Tiefpass (ringfoermig per FFT, also schleifentauglich)."""
    out = np.zeros_like(x)
    freqs = np.fft.rfftfreq(len(x), 1 / SR)
    gain = 1 / np.sqrt(1 + (freqs / cutoff) ** 4)
    for ch in range(x.shape[1]):
        out[:, ch] = np.fft.irfft(np.fft.rfft(x[:, ch]) * gain, len(x))
    return out


def tape_wow(x, depth, loop_seconds):
    """Band-Leiern: langsam schwankende Tonhoehe. Ganze Schwingungen je
    Schleife, damit der Uebergang nahtlos bleibt."""
    L = len(x)
    cycles = max(1, round(loop_seconds * 0.45))
    w = 2 * np.pi * cycles / L
    amp = depth / w  # Tonhoehen-Abweichung "depth" -> Verzoegerung in Samples
    idx = np.arange(L) - amp * np.sin(w * np.arange(L))
    out = np.zeros_like(x)
    pos = np.arange(L)
    for ch in range(x.shape[1]):
        ext = np.concatenate([x[-64:, ch], x[:, ch], x[:64, ch]])
        out[:, ch] = np.interp(idx + 64, np.arange(L + 128), ext)
    return out


def vinyl(L):
    """Plattenknistern: leises Rauschen plus einzelne Knackser (Stereo)."""
    out = np.zeros((L, 2))
    for ch in range(2):
        hiss = hp(noise(L)) * 0.012
        clicks = np.zeros(L)
        pos = rng.integers(0, L, int(L / SR * 9))
        clicks[pos] = rng.uniform(-1, 1, len(pos)) * rng.uniform(0.2, 1.0, len(pos))
        k = np.exp(-np.arange(int(0.002 * SR)) / (0.0004 * SR))
        clicks = np.convolve(clicks, k)[:L] * 0.25
        out[:, ch] = lowpass_loop((hiss + clicks)[:, None], 6000)[:, 0]
    return out


def master(mix, target_rms_db=-19.0):
    rms = np.sqrt(np.mean(mix ** 2)) + 1e-9
    mix = mix * (10 ** (target_rms_db / 20) / rms)
    mix = np.tanh(mix * 1.1) / math.tanh(1.1)  # sanfte Begrenzung
    peak = np.max(np.abs(mix))
    if peak > 0.94:
        mix *= 0.94 / peak
    return mix.astype(np.float32)


# --- Songs ---------------------------------------------------------------------------------

def bars(a, b):
    return range(a, b + 1)


def song_title():
    """Song 1 "Time Shifter": Titel. c-Moll, 100 BPM, tickendes Arpeggio, geheimnisvoll-heldenhaft."""
    s = Score(100, 32)
    ch = ['Cm', 'Ab', 'Eb', 'Bb', 'Cm', 'Ab', 'Fm', 'G'] * 4
    s.track('arp', 'chip', 0.32, -0.35, 0.3)
    s.track('bass', 'bass', 0.9, 0.0, 0.05)
    s.track('pad', 'pad', 0.35, 0.2, 0.5)
    s.track('lead', 'lead', 0.55, 0.1, 0.35)
    s.track('vibes', 'vibes', 0.55, 0.15, 0.4)
    s.track('tick', 'tick', 0.1, 0.4, 0.1)
    s.track('tock', 'tock', 0.12, -0.4, 0.1)
    s.track('kick', 'kick', 0.8, 0.0, 0.05)
    s.track('snare', 'snare', 0.35, 0.05, 0.25)
    s.track('hat', 'hat', 0.18, 0.3, 0.1)
    s.arp('arp', ch, bars(1, 32), [0, 1, 2, 3, 2, 1, 0, 1, 0, 1, 2, 3, 2, 1, 2, 3], vel=0.6)
    s.bass('bass', ch, bars(1, 24), [(0, 'r', 0.9), (1, 'r', 0.4), (1.5, 'r', 0.4), (2, 'r', 0.9), (3, '5', 0.45), (3.5, 'o', 0.45)])
    s.bass('bass', ch, bars(25, 32), [(0, 'r', 3.8)], vel=0.7)
    s.block('pad', ch, bars(9, 32), [0], 3.9, 4, 0.5)
    s.drums('tick', 'x.......x.......', bars(1, 32))
    s.drums('tock', '....x.......x...', bars(1, 32))
    s.drums('kick', 'x.......x.......', bars(9, 16))
    s.drums('kick', 'x.......x.x.....', bars(17, 24))
    s.drums('snare', '....x.......x...', bars(17, 24))
    s.drums('hat', '..x...x...x...x.', bars(17, 24))
    m1 = ['G4:1.5 C5:0.5 Eb5:1 D5:1', 'C5:1.5 Bb4:0.5 Ab4:1 C5:1', 'Bb4:2 G4:1 Bb4:1', 'D5:3 r:1',
          'G4:1.5 C5:0.5 Eb5:1 G5:1', 'F5:1.5 Eb5:0.5 C5:2', 'Ab4:1 C5:1 F5:1 Eb5:1', 'D5:2 B4:2']
    m2 = ['C6:1 Bb5:0.5 G5:0.5 Eb5:1 G5:1', 'Ab5:1 G5:0.5 Eb5:0.5 C5:2', 'Eb5:0.5 F5:0.5 G5:1 Bb5:1 G5:1', 'F5:1 D5:1 Bb4:2',
          'C6:1 D6:0.5 Eb6:0.5 D6:1 C6:1', 'Ab5:1.5 G5:0.5 F5:1 Eb5:1', 'F5:1 Ab5:1 C6:1 Ab5:1', 'G5:2 F5:1 D5:1']
    for i, m in enumerate(m1):
        s.melody('lead', m, 9 + i)
        s.melody('vibes', m, 25 + i, vel=0.7)
    for i, m in enumerate(m2):
        s.melody('lead', m, 17 + i)
    return s


def song_intro():
    """Song 2 "Pizza on the Line": Intro-Comic. F-Dur, 112 BPM, huepfend, verspielt."""
    s = Score(112, 16)
    ch = ['F', 'Dm', 'Gm', 'C7', 'F', 'Dm', 'Bb', 'C7'] * 2
    s.track('bass', 'bass', 0.9, 0.0, 0.05)
    s.track('stab', 'pluck', 0.45, -0.3, 0.25)
    s.track('lead', 'chip', 1.0, 0.15, 0.3)
    s.track('vibes', 'vibes', 0.6, 0.2, 0.35)
    s.track('shaker', 'shaker', 0.25, 0.35, 0.05)
    s.track('kick', 'kick', 0.6, 0.0, 0.05)
    s.track('rim', 'rim', 0.18, -0.2, 0.2)
    s.bass('bass', ch, bars(1, 16), [(0, 'r', 0.5), (2, '5', 0.5), (3.5, 'r', 0.25)])
    s.block('stab', ch, bars(1, 16), [1, 3], 0.3, 4, 0.5)
    s.drums('shaker', 'x.o.x.o.x.o.x.o.', bars(1, 16))
    s.drums('kick', 'x.......x.......', bars(1, 16))
    s.drums('rim', '....x.......x...', bars(1, 16))
    a = ['A4:0.5 C5:0.5 F5:0.5 r:0.5 E5:0.5 F5:0.5 G5:1', 'A5:1 F5:0.5 D5:0.5 r:1 A4:1',
         'Bb4:0.5 D5:0.5 G5:0.5 r:0.5 F5:0.5 G5:0.5 A5:1', 'Bb5:1 G5:0.5 E5:0.5 C5:2',
         'A4:0.5 C5:0.5 F5:0.5 r:0.5 E5:0.5 F5:0.5 G5:1', 'A5:0.5 Bb5:0.5 A5:0.5 F5:0.5 D5:2',
         'D5:0.5 F5:0.5 Bb5:1 A5:0.5 G5:0.5 F5:1']
    for i, m in enumerate(a):
        s.melody('lead', m, 1 + i, vel=0.7)
        s.melody('vibes', m, 9 + i, vel=0.75)
    s.melody('lead', 'E5:1 G5:1 C5:2', 8, vel=0.7)
    s.melody('vibes', 'E5:0.5 F5:0.5 G5:0.5 Bb5:0.5 C6:2', 16, vel=0.75)
    return s


def song_workshop():
    """Song 3 "Tinkering": Werkstatt. G-Mixolydisch, 92 BPM, gemuetlich, Metall-Klonk als Backbeat."""
    s = Score(92, 32, swing=0.08)
    A = ['G', 'F', 'C', 'G', 'G', 'F', 'C', 'D']
    B = ['Em', 'C', 'G', 'D', 'Em', 'C', 'D', 'D']
    ch = A + A + B + A
    s.track('bass', 'bass', 0.85, 0.0, 0.05)
    s.track('strum', 'pluck', 0.4, -0.35, 0.25)
    s.track('mel', 'marimba', 0.75, 0.15, 0.3)
    s.track('flute', 'flute', 0.4, 0.1, 0.4)
    s.track('pad', 'pad', 0.28, 0.2, 0.5)
    s.track('hat', 'hat', 0.16, 0.3, 0.05)
    s.track('kick', 'kick', 0.6, 0.0, 0.05)
    s.track('clank', 'clank', 0.32, -0.15, 0.25)
    s.bass('bass', ch, bars(1, 32), [(0, 'r', 1.0), (1.5, 'r', 0.5), (2, '5', 1.0), (3, 'r', 0.5), (3.5, '3', 0.5)])
    s.block('strum', ch, bars(1, 32), [1, 3], 0.4, 4, 0.5)
    s.block('pad', ch, bars(17, 24), [0], 3.9, 4, 0.45)
    s.drums('hat', 'x.o.x.o.x.o.x.o.', bars(1, 32))
    s.drums('kick', 'x.....x...x.....', bars(9, 32))
    s.drums('clank', '....x.......x...', bars(9, 32))
    ma = ['B4:1 D5:1 G5:1.5 F5:0.5', 'F5:1 C5:1 A4:2', 'G4:0.5 A4:0.5 C5:0.5 E5:0.5 G5:1 E5:1', 'D5:3 r:1',
          'B4:1 D5:1 G5:1 A5:0.5 B5:0.5', 'C6:1 A5:1 F5:2', 'E5:1 G5:0.5 E5:0.5 C5:1 E5:1', 'D5:2 F#5:1 A5:1']
    mb = ['G5:1.5 F#5:0.5 E5:1 B4:1', 'C5:1 E5:1 G5:2', 'B5:1.5 A5:0.5 G5:1 D5:1', 'F#5:2 A5:2',
          'G5:0.5 A5:0.5 B5:1 A5:1 G5:1', 'E5:1 G5:1 C6:2', 'A5:1 F#5:1 D5:1 E5:1', 'F#5:2 r:2']
    for i, m in enumerate(ma):
        s.melody('mel', m, 9 + i, vel=0.8)
        s.melody('flute', m, 25 + i, transpose=-12, vel=0.8)
    for i, m in enumerate(mb):
        s.melody('mel', m, 17 + i, vel=0.8)
    return s


def song_clockwork():
    """Song 4 "Clockwork Lab": Fabrik/Chemie. d-Dorisch, 104 BPM, Uhrwerk-Tick-Tack, treibend."""
    s = Score(104, 32)
    ch = ['Dm', 'C', 'Bb', 'C', 'Dm', 'C', 'Bb', 'A'] * 4
    s.track('bass', 'bass', 0.85, 0.0, 0.05)
    s.track('tick', 'tick', 0.12, 0.4, 0.1)
    s.track('tock', 'tock', 0.14, -0.4, 0.1)
    s.track('arp', 'chip', 0.36, -0.3, 0.3)
    s.track('lead', 'lead', 0.55, 0.1, 0.35)
    s.track('counter', 'vibes', 0.45, 0.25, 0.4)
    s.track('pad', 'pad', 0.25, -0.1, 0.5)
    s.track('kick', 'kick', 0.75, 0.0, 0.05)
    s.track('snare', 'snare', 0.32, 0.05, 0.25)
    s.track('hat', 'hat', 0.14, 0.3, 0.05)
    pat = [(i * 0.5, p, 0.42) for i, p in enumerate(['r', 'r', 'o', 'r', '5', 'r', 'o', '5'])]
    s.bass('bass', ch, bars(1, 8), pat, vel=0.65)
    s.bass('bass', ch, bars(9, 32), pat)
    s.drums('tick', 'x...x...x...x...', bars(1, 32))
    s.drums('tock', '..x...x...x...x.', bars(1, 32))
    s.arp('arp', ch, bars(9, 32), [0, 2, 1, 3, 2, 0, 3, 1, 0, 2, 1, 3, 2, 3, 1, 2], vel=0.55)
    s.block('pad', ch, bars(17, 32), [0], 3.9, 3, 0.45)
    s.drums('kick', 'x.......x.......', bars(17, 32))
    s.drums('snare', '....x.......x...', bars(17, 32))
    s.drums('hat', 'o.o.o.o.o.o.o.o.', bars(25, 32))
    mel = ['D5:0.75 E5:0.75 F5:0.5 A5:1 G5:1', 'E5:1.5 C5:0.5 G4:2', 'F5:0.75 G5:0.75 F5:0.5 D5:1 Bb4:1', 'C5:1 E5:1 G5:2',
           'A5:0.75 G5:0.75 F5:0.5 E5:1 D5:1', 'E5:0.5 F5:0.5 G5:1 C6:2', 'Bb5:1 A5:0.5 G5:0.5 F5:1 D5:1', 'C#5:2 E5:1 A5:1']
    cnt = ['F5:1 A5:1 B5:1 A5:1', 'G5:1 E5:1 C5:2', 'D5:1 F5:1 Bb5:1 A5:1', 'G5:2 E5:2',
           'A5:1 B5:1 D6:1 C6:1', 'B5:0.5 C6:0.5 G5:1 E5:2', 'F5:1 G5:1 Bb5:1 D6:1', 'C#6:2 A5:2']
    for i in range(8):
        s.melody('lead', mel[i], 9 + i)
        s.melody('counter', cnt[i], 17 + i, vel=0.8)
        s.melody('lead', mel[i], 25 + i)
        s.melody('counter', cnt[i], 25 + i, transpose=-12, vel=0.6)
    return s


def song_quantum():
    """Song 5 "Quantum Climb": Elektro/Magnet/Quanten. a-Moll, 120 BPM, Synthwave, pumpend."""
    s = Score(120, 32)
    ch = ['Am', 'F', 'C', 'G', 'Am', 'F', 'G', 'E'] * 4
    s.track('bass', 'bass', 0.85, 0.0, 0.05, duck=0.5)
    s.track('arp', 'chip', 0.24, 0.35, 0.35)
    s.track('pad', 'pad', 0.4, -0.2, 0.5, duck=0.6)
    s.track('lead', 'lead', 0.5, 0.05, 0.4)
    s.track('vibes', 'vibes', 0.45, -0.15, 0.4)
    s.track('flute', 'flute', 0.4, 0.1, 0.45)
    s.track('kick', 'kick', 0.8, 0.0, 0.05)
    s.track('snare', 'snare', 0.35, 0.0, 0.3)
    s.track('hat', 'hat', 0.16, 0.3, 0.05)
    s.bass('bass', ch, bars(1, 24), [(i * 0.5, 'r' if i % 4 else 'o', 0.42) for i in range(8)])
    s.bass('bass', ch, bars(25, 32), [(0, 'r', 1.9), (2, 'r', 1.9)], vel=0.7)
    s.arp('arp', ch, bars(1, 32), [0, 1, 2, 3] * 4, octave=5, vel=0.55)
    s.block('pad', ch, bars(1, 32), [0], 3.9, 4, 0.5)
    s.drums('kick', 'x.......x.......', bars(9, 16))
    s.drums('kick', 'x...x...x...x...', bars(17, 24))
    s.drums('snare', '....x.......x...', bars(9, 24))
    s.drums('hat', 'o.x.o.x.o.x.o.x.', bars(9, 24))
    mel = ['E5:1 A5:1 B5:0.5 C6:0.5 B5:1', 'A5:1.5 G5:0.5 F5:1 E5:1', 'G5:1 C6:1 E6:1 D6:1', 'D6:1.5 B5:0.5 G5:2',
           'E5:1 A5:1 B5:0.5 C6:0.5 D6:1', 'E6:1.5 D6:0.5 C6:1 A5:1', 'B5:1 D6:1 G6:1 F6:1', 'E6:2 G#5:2']
    for i, m in enumerate(mel):
        s.melody('lead', m, 9 + i, transpose=-12)
        s.melody('vibes', m, 17 + i, vel=0.75)
        s.melody('lead', m, 17 + i, transpose=-12, vel=0.5)
        s.melody('flute', m, 25 + i, transpose=-12, vel=0.75)
    return s


def song_elevator():
    """Song 6 "Going Down (with Pizza)": Ende/Abspann. B-Dur, Bossa, 120 BPM, Fahrstuhlmusik."""
    s = Score(120, 32)
    ch16 = ['Bbmaj7', 'Gm7', 'Cm7', 'F7', 'Dm7', 'G7', 'Cm7', 'F7', 'Ebmaj7', 'Ab7', 'Dm7', 'G7', 'Cm7', 'F7', 'Bbmaj7', 'F7']
    ch = ch16 * 2
    s.track('rhodes', 'rhodes', 0.42, -0.25, 0.35)
    s.track('bass', 'bass', 0.85, 0.0, 0.05)
    s.track('vibes', 'vibes', 0.6, 0.2, 0.4)
    s.track('flute', 'flute', 0.5, 0.1, 0.45)
    s.track('shaker', 'shaker', 0.22, 0.35, 0.05)
    s.track('rim', 'rim', 0.16, -0.3, 0.2)
    s.track('kick', 'kick', 0.45, 0.0, 0.05)
    s.block('rhodes', ch, bars(1, 32), [[0, 1.5, 3], [0.5, 2]], 0.7, 4, 0.5)
    s.bass('bass', ch, bars(1, 32), [(0, 'r', 1.4), (1.5, '5', 0.45), (2, '5', 1.4), (3.5, 'r', 0.45)])
    s.drums('shaker', 'xoxoxoxoxoxoxoxo', bars(1, 32))
    for b in bars(1, 32):
        s.drums('rim', 'x.....x.....x...' if b % 2 else '....x...x.......', [b])
    s.drums('kick', 'x.......x.......', bars(1, 32))
    mel = ['D5:1.5 C5:0.5 D5:1 F5:1', 'Bb4:2 r:1 A4:0.5 Bb4:0.5', 'Eb5:1.5 D5:0.5 C5:1 Bb4:1', 'A4:3 r:1',
           'F5:1.5 E5:0.5 F5:1 A5:1', 'D5:2 r:1 B4:0.5 D5:0.5', 'G5:1.5 F5:0.5 Eb5:1 D5:1', 'C5:3 r:1',
           'G5:1 Bb5:1 D6:1 Bb5:1', 'C6:1.5 Bb5:0.5 Gb5:2', 'F5:1 A5:1 C6:1 A5:1', 'B5:2 G5:1 F5:1',
           'Eb5:1 G5:1 Bb5:1 G5:1', 'A5:1.5 G5:0.5 F5:1 Eb5:1', 'D5:3 r:1', 'r:2 C5:0.5 D5:0.5 Eb5:0.5 E5:0.5']
    for i, m in enumerate(mel):
        s.melody('vibes', m, 1 + i, vel=0.75)
        s.melody('flute', m, 17 + i, vel=0.75)
    return s


def song_coffee():
    """Song 7 "Coffee Break Circuits": Lo-Fi, C-Dur, 80 BPM, entspannt
    tuefteln (E-Piano, Boom-Bap, Vinyl)."""
    s = Score(80, 32, swing=0.09)
    s.humanize = 0.012
    s.lowpass = 5200
    s.wow = 0.003
    s.crackle = 1.0
    s.target_db = -21.0
    A = ['Fmaj9', 'Em7', 'Dm9', 'Cmaj9'] * 2
    B = ['Am9', 'Dm9', 'G9', 'Cmaj9', 'Fmaj9', 'Em7', 'Dm9', 'G9']
    ch = A + A + B + A
    s.track('keys', 'lofi_keys', 0.36, -0.2, 0.35)
    s.track('bass', 'lofi_bass', 0.9, 0.0, 0.05)
    s.track('kick', 'lofi_kick', 0.8, 0.0, 0.05)
    s.track('snare', 'lofi_snare', 0.5, 0.05, 0.3)
    s.track('hat', 'hat', 0.28, 0.25, 0.1)
    s.track('vibes', 'vibes', 0.65, 0.2, 0.45)
    s.track('flute', 'flute', 0.5, 0.1, 0.5)
    s.block('keys', ch, bars(1, 32), [[0, 1.5], [0, 2.5]], 1.3, 3, 0.5)
    s.bass('bass', ch, bars(1, 32), [(0, 'r', 1.4), (1.5, 'r', 0.4), (2.5, '5', 0.9), (3.5, 'o', 0.4)])
    s.drums('kick', 'x......x..x.....', bars(1, 32))
    s.drums('snare', '....x.......x...', bars(5, 32))
    s.drums('hat', 'x.o.x.o.x.o.x.oo', bars(1, 32))
    a = ['A5:1.5 G5:0.5 E5:1 r:1', 'G5:1 E5:0.5 D5:0.5 B4:2', 'C5:1.5 D5:0.5 F5:1 E5:1', 'E5:3 r:1',
         'A5:1 C6:1 B5:0.5 A5:0.5 G5:1', 'E5:2 G5:1 D5:1', 'F5:1.5 E5:0.5 D5:1 C5:1', 'B4:2 r:2']
    b = ['E5:1 G5:1 B5:1 A5:1', 'F5:2 A5:1 C6:1', 'B5:1.5 A5:0.5 G5:1 F5:1', 'E5:2 r:1 G5:1',
         'A5:1 G5:0.5 F5:0.5 E5:1 C5:1', 'D5:1 E5:1 G5:2', 'F5:1 E5:1 D5:1 C5:1', 'D5:2 B4:1 G4:1']
    for i in range(8):
        s.melody('vibes', a[i], 9 + i, vel=0.7)
        s.melody('flute', b[i], 17 + i, vel=0.7)
        s.melody('vibes', a[i], 25 + i, transpose=-12, vel=0.6)
    return s


def song_late_night():
    """Song 8 "Late Night Lab": Lo-Fi, Es-Dur, 72 BPM, nachts im Labor
    (gedaempfte Gitarre, E-Piano, Rimshot, Vinyl)."""
    s = Score(72, 32, swing=0.1)
    s.humanize = 0.014
    s.lowpass = 4600
    s.wow = 0.0035
    s.crackle = 1.2
    s.target_db = -21.0
    A = ['Abmaj9', 'Gm7', 'Fm9', 'Bb9'] * 2
    B = ['Cm9', 'Fm9', 'Bb9', 'Ebmaj9', 'Abmaj9', 'Gm7', 'Fm9', 'Bb9']
    ch = A + A + B + A
    s.track('keys', 'lofi_keys', 0.42, 0.2, 0.4)
    s.track('guitar', 'lofi_pluck', 0.4, -0.3, 0.3)
    s.track('bass', 'lofi_bass', 0.9, 0.0, 0.05)
    s.track('kick', 'lofi_kick', 0.75, 0.0, 0.05)
    s.track('rim', 'rim', 0.6, -0.15, 0.2)
    s.track('snare', 'lofi_snare', 0.45, 0.05, 0.35)
    s.track('hat', 'hat', 0.24, 0.3, 0.1)
    s.track('flute', 'flute', 0.4, 0.1, 0.5)
    s.track('vibes', 'vibes', 0.65, -0.1, 0.45)
    s.block('keys', ch, bars(1, 32), [0], 3.6, 3, 0.4)
    s.arp('guitar', ch, bars(5, 32), [0, 2, 1, 3, 4, 3, 1, 2], step=0.5, octave=3, vel=0.6, length=0.8)
    s.bass('bass', ch, bars(1, 32), [(0, 'r', 1.8), (2.5, '5', 0.8), (3.5, 'r', 0.4)])
    s.drums('kick', 'x.........x.....', bars(1, 32))
    s.drums('rim', '....x.......x...', bars(1, 8))
    s.drums('rim', '....x.......x...', bars(25, 32))
    s.drums('snare', '....x.......x...', bars(9, 24))
    s.drums('hat', 'x.x.x.x.x.x.x.x.', bars(5, 32))
    a = ['C5:1.5 Bb4:0.5 G4:2', 'Bb4:1 D5:1 F5:2', 'Eb5:1 C5:1 Ab4:1 G4:1', 'F4:3 r:1',
         'C5:1 Eb5:1 G5:1.5 F5:0.5', 'D5:2 Bb4:2', 'Ab4:1 C5:1 Eb5:1 D5:1', 'D5:2 r:2']
    b = ['G5:2 Eb5:1 D5:1', 'C5:2 Ab4:2', 'D5:1 F5:1 Ab5:1 G5:1', 'G5:3 r:1',
         'Eb5:1 G5:1 C6:1 Bb5:1', 'Bb5:2 F5:2', 'Ab5:1 G5:1 F5:1 Eb5:1', 'D5:2 F5:2']
    for i in range(8):
        s.melody('flute', a[i], 9 + i, vel=0.7)
        s.melody('vibes', b[i], 17 + i, vel=0.7)
        s.melody('flute', a[i], 25 + i, vel=0.55)
    return s


SONGS = [
    (1, 'time_shifter', song_title),
    (2, 'pizza_on_the_line', song_intro),
    (3, 'tinkering', song_workshop),
    (4, 'clockwork_lab', song_clockwork),
    (5, 'quantum_climb', song_quantum),
    (6, 'going_down', song_elevator),
    (7, 'coffee_break_circuits', song_coffee),
    (8, 'late_night_lab', song_late_night),
]


def write_ogg(path, data):
    import aud
    sound = aud.Sound.buffer(np.ascontiguousarray(data), SR)
    sound.write(path, SR, aud.CHANNELS_STEREO, aud.FORMAT_FLOAT32, aud.CONTAINER_OGG, aud.CODEC_VORBIS, BITRATE)


def write_wav(path, data):
    pcm = (np.clip(data, -1, 1) * 32767).astype('<i2')
    with wave.open(path, 'wb') as w:
        w.setnchannels(2)
        w.setsampwidth(2)
        w.setframerate(SR)
        w.writeframes(pcm.tobytes())


def main():
    args = sys.argv[sys.argv.index('--') + 1:] if '--' in sys.argv else []
    wav_dir = None
    if '--wav' in args:
        i = args.index('--wav')
        wav_dir = args[i + 1]
        args = args[:i] + args[i + 2:]
    wanted = {int(a) for a in args}
    os.makedirs(OUT, exist_ok=True)
    for song_id, name, fn in SONGS:
        if wanted and song_id not in wanted:
            continue
        data = fn().render()
        base = 'music_%02d_%s' % (song_id, name)
        write_ogg(os.path.join(OUT, base + '.ogg'), data)
        if wav_dir:
            write_wav(os.path.join(wav_dir, base + '.wav'), data)
        print('MUSIC ok', base, round(len(data) / SR, 1), 's')


if __name__ == '__main__':
    main()
