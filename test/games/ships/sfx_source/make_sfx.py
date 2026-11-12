"""Synthesises the three own effects of Lodě, deterministic:

- splash.ogg – a shot falling into the water: a soft burst of filtered noise,
- hit.ogg – a shot hitting a ship: a short boom with a wooden crack,
- sunk.ogg – a ship going down: a long low boom and a bubbling fade.

Encoded as OGG Vorbis (~64 kb/s mono):

    python test/games/ships/sfx_source/make_sfx.py C:/dev/tools/ffmpeg/bin/ffmpeg.exe
"""

import math
import struct
import subprocess
import sys
import tempfile
import wave
from pathlib import Path

RATE = 44100
OUT = Path(__file__).resolve().parents[4] / "assets" / "games" / "ships" / "sfx"


def noise(n, seed):
    x = seed
    for _ in range(n):
        x = (1103515245 * x + 12345) & 0x7FFFFFFF
        yield x / 0x3FFFFFFF - 1.0


def lowpass(samples, cutoff):
    a = math.exp(-2 * math.pi * cutoff / RATE)
    y = 0.0
    for s in samples:
        y = (1 - a) * s + a * y
        yield y


def clack(length, pitch, seed):
    """Wood on wood: a damped resonance plus a click of noise."""
    n = int(length * RATE)
    click = list(lowpass(noise(n, seed), 5000))
    out = []
    for i in range(n):
        t = i / RATE
        env = math.exp(-t * 55)
        tone = math.sin(2 * math.pi * pitch * t) + 0.5 * math.sin(2 * math.pi * pitch * 2.76 * t)
        out.append((0.6 * tone + 0.8 * click[i] * math.exp(-t * 160)) * env)
    return out


def slide(length, seed):
    n = int(length * RATE)
    body = list(lowpass(noise(n, seed), 1800))
    return [s * min(1.0, i / (0.2 * n)) * (1 - i / n) * 0.5 for i, s in enumerate(body)]


def bell(freq, length):
    n = int(length * RATE)
    out = []
    for i in range(n):
        t = i / RATE
        env = min(1.0, t / 0.004) * math.exp(-t * 6)
        out.append(env * (math.sin(2 * math.pi * freq * t) + 0.35 * math.sin(2 * math.pi * freq * 2.0 * t) + 0.15 * math.sin(2 * math.pi * freq * 3.01 * t)))
    return out


def mix(*parts):
    """Each part is (start in s, samples)."""
    end = max(int(start * RATE) + len(s) for start, s in parts)
    out = [0.0] * end
    for start, s in parts:
        k = int(start * RATE)
        for i, v in enumerate(s):
            out[k + i] += v
    return out


def write(name, samples, peak=0.7):
    top = max(abs(s) for s in samples) or 1.0
    frames = b"".join(struct.pack("<h", int(s / top * peak * 32767)) for s in samples)
    with tempfile.TemporaryDirectory() as tmp:
        wav = Path(tmp) / f"{name}.wav"
        with wave.open(str(wav), "wb") as w:
            w.setnchannels(1)
            w.setsampwidth(2)
            w.setframerate(RATE)
            w.writeframes(frames)
        subprocess.run(
            [sys.argv[1], "-y", "-loglevel", "error", "-i", str(wav), "-c:a", "libvorbis", "-q:a", "2", str(OUT / f"{name}.ogg")],
            check=True,
        )




def boom(length, pitch, seed, decay):
    """A low thump: a falling sine and rumbling noise."""
    n = int(length * RATE)
    rumble = list(lowpass(noise(n, seed), 400))
    out = []
    phase = 0.0
    for i in range(n):
        t = i / RATE
        phase += 2 * math.pi * pitch * (1 - 0.6 * min(1.0, t / length)) / RATE
        env = min(1.0, t / 0.003) * math.exp(-t * decay)
        out.append(env * (0.9 * math.sin(phase) + 1.2 * rumble[i]))
    return out


def splash(length, seed):
    n = int(length * RATE)
    body = list(lowpass(noise(n, seed), 2500))
    return [s * min(1.0, i / (0.03 * n)) * math.exp(-i / RATE * 9) for i, s in enumerate(body)]


def bubbles(length, seed):
    out = []
    x = seed
    parts = []
    t = 0.0
    while t < length:
        x = (1103515245 * x + 12345) & 0x7FFFFFFF
        f = 300 + x % 500
        m = int(0.05 * RATE)
        parts.append((t, [math.sin(2 * math.pi * f * (1 + j / m) * j / RATE) * math.exp(-j / m * 4) * 0.3 * (1 - t / length) for j in range(m)]))
        t += 0.06 + (x % 7) / 100
    return mix(*parts)


def main():
    write("splash", mix((0.0, splash(0.45, 11)), (0.02, splash(0.3, 23))), peak=0.55)
    write("hit", mix((0.0, boom(0.5, 90, 5, 9)), (0.0, clack(0.08, 300, 13))))
    write("sunk", mix((0.0, boom(1.1, 70, 17, 3.5)), (0.35, bubbles(0.9, 41))))


if __name__ == "__main__":
    main()
