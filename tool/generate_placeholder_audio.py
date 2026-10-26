"""Generates placeholder sounds into assets/audio/ and their CREDITS.json.

Placeholders keep the app working until the real recordings (spec 7.2, 7.3)
are chosen. Standard library only; output is deterministic.

    python tool/generate_placeholder_audio.py

Real files replace these one by one: drop the file into assets/audio/,
update its path in lib/core/audio/audio_catalog.dart and its entry in
assets/audio/CREDITS.json (keep entries for files not replaced yet).
"""

import json
import math
import struct
import wave
from pathlib import Path

RATE = 22050
ROOT = Path(__file__).resolve().parent.parent / "assets" / "audio"

# Each track is a quiet 4 s chord loop; whole-Hz frequencies make 4 s an
# exact number of periods, so the loop is seamless. Tremolo speed differs
# per track so the tracks are told apart.
MUSIC = {
    "menu": ([196, 247, 294], 0.5),  # G major, calm
    "sample": ([220, 277, 330], 1.0),  # A major, a bit livelier
    "tictactoe": ([175, 220, 262], 0.25),
    "memory": ([262, 330, 392], 2.0),
    "minesweeper": ([147, 175, 220], 0.75),
    "ludo": ([294, 370, 440], 2.0),
    "checkers": ([165, 196, 247], 0.5),
}

# (notes in Hz, note length in s, waveform)
SFX = {
    "tap": ([880], 0.05, "click"),
    "back": ([440], 0.06, "click"),
    "toggle": ([1320], 0.03, "click"),
    "card_flip": ([0], 0.12, "noise"),
    "piece_place": ([330], 0.08, "click"),
    "dice_roll": ([0, 0, 0], 0.07, "noise"),
    "coin": ([1568, 2093], 0.08, "sine"),
    "achievement": ([523, 659, 784, 1047], 0.12, "sine"),
    "error": ([150], 0.2, "buzz"),
    "turn": ([1047], 0.25, "bell"),
    "purchase": ([1568, 2093, 784, 1047], 0.09, "sine"),
    "equip": ([0], 0.1, "noise"),
    "level_up": ([392, 494, 587, 784, 988], 0.18, "sine"),
    "jingle_win": ([523, 659, 784, 1047], 0.35, "bell"),
    "jingle_lose": ([392, 349, 330, 262], 0.4, "bell"),
}


def write_wav(path, samples):
    path.parent.mkdir(parents=True, exist_ok=True)
    with wave.open(str(path), "wb") as f:
        f.setnchannels(1)
        f.setsampwidth(2)
        f.setframerate(RATE)
        f.writeframes(b"".join(struct.pack("<h", int(max(-1, min(1, s)) * 32767)) for s in samples))


def music(freqs, tremolo):
    n = RATE * 4
    return [
        0.12
        * (0.75 + 0.25 * math.cos(2 * math.pi * tremolo * i / RATE))
        * sum(math.sin(2 * math.pi * f * i / RATE) for f in freqs)
        / len(freqs)
        for i in range(n)
    ]


def note(freq, length, kind, seed):
    n = int(RATE * length)
    out = []
    state = seed * 7919 + 1
    for i in range(n):
        t = i / RATE
        if kind == "click":
            env = math.exp(-t * 60)
            s = math.sin(2 * math.pi * freq * t) * env
        elif kind == "noise":
            state = (state * 1103515245 + 12345) & 0x7FFFFFFF
            env = math.exp(-t * 30)
            s = (state / 0x3FFFFFFF - 1) * env * 0.6
        elif kind == "buzz":
            env = min(1, t * 50) * min(1, (length - t) * 50)
            s = (0.6 if math.sin(2 * math.pi * freq * t) > 0 else -0.6) * env * 0.4
        elif kind == "bell":
            env = math.exp(-t * 6)
            s = (math.sin(2 * math.pi * freq * t) + 0.3 * math.sin(4 * math.pi * freq * t)) * env * 0.6
        else:
            env = min(1, t * 200) * math.exp(-t * 8)
            s = math.sin(2 * math.pi * freq * t) * env * 0.7
        out.append(s * 0.8)
    return out


def credit(file, title):
    return {
        "file": file,
        "title": title,
        "author": "Deskovky (vygenerováno)",
        "source_url": "https://github.com/mpridal/deskovky/blob/main/tool/generate_placeholder_audio.py",
        "license": "CC0 1.0",
        "attribution_text": f"„{title}“ – zástupný zvuk vygenerovaný skriptem, CC0 1.0",
    }


def main():
    credits = []
    for name, (freqs, tremolo) in MUSIC.items():
        file = f"music/{name}.wav"
        write_wav(ROOT / file, music(freqs, tremolo))
        credits.append(credit(file, f"Zástupná hudba {name}"))
    for name, (notes, length, kind) in SFX.items():
        file = f"sfx/{name}.wav"
        samples = []
        for i, freq in enumerate(notes):
            samples += note(freq, length, kind, i)
        write_wav(ROOT / file, samples)
        credits.append(credit(file, f"Zástupný efekt {name}"))
    (ROOT / "CREDITS.json").write_text(json.dumps(credits, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")


if __name__ == "__main__":
    main()
