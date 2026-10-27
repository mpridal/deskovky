"""Synthesises the two own effects of Piškvorky (spec 13.5), deterministic:

- draw.ogg – a pencil scratching a mark on paper (two short strokes),
- line.ogg – one long pencil stroke crossing out the winning row.

Band-passed noise with a grainy envelope, encoded as OGG Vorbis (~64 kb/s):

    python test/games/tictactoe/sfx_source/make_sfx.py C:/dev/tools/ffmpeg/bin/ffmpeg.exe
"""

import math
import struct
import subprocess
import sys
import tempfile
import wave
from pathlib import Path

RATE = 44100
OUT = Path(__file__).resolve().parents[4] / "assets" / "games" / "tictactoe" / "sfx"


def noise(n, seed):
    x = seed
    for _ in range(n):
        x = (1103515245 * x + 12345) & 0x7FFFFFFF
        yield x / 0x3FFFFFFF - 1.0


def bandpass(samples, low, high):
    """Two one-pole filters: a high-pass at [low], a low-pass at [high]."""
    a_hi = math.exp(-2 * math.pi * low / RATE)
    a_lo = math.exp(-2 * math.pi * high / RATE)
    prev_in = prev_hp = lp = 0.0
    for s in samples:
        hp = a_hi * (prev_hp + s - prev_in)
        prev_in, prev_hp = s, hp
        lp = (1 - a_lo) * hp + a_lo * lp
        yield lp


def stroke(length, seed, low, high, grain_hz):
    """One pencil stroke: soft attack, grainy body, quick release."""
    n = int(length * RATE)
    body = list(bandpass(noise(n, seed), low, high))
    grains = list(noise(n, seed * 7 + 3))
    out = []
    smooth = 0.0
    for i, s in enumerate(body):
        t = i / n
        env = min(1.0, t / 0.12) * min(1.0, (1 - t) / 0.25)
        # Paper grain: slow random wobble of the loudness.
        smooth += (abs(grains[i]) - smooth) * (grain_hz / RATE)
        out.append(s * env * (0.55 + 0.9 * smooth))
    return out


def silence(length):
    return [0.0] * int(length * RATE)


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


def main():
    draw = silence(0.01) + stroke(0.09, 11, 1800, 6500, 90) + silence(0.035) + stroke(0.1, 23, 1700, 6000, 80) + silence(0.02)
    line = silence(0.01) + stroke(0.42, 37, 1200, 5200, 40) + silence(0.03)
    write("draw", draw)
    write("line", line, peak=0.8)


if __name__ == "__main__":
    main()
