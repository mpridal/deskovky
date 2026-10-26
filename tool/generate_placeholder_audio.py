"""Generates placeholder sounds and their credits.

Placeholders keep the app working until the real recordings (spec 7.2, 7.3)
are chosen. Output is deterministic. Shared effects are WAV in assets/audio/;
games' own effects and placeholder music are OGG (needs ffmpeg) in
assets/games/<id>/sfx/ and assets/audio/music/<id>.ogg, credited in
assets/games/<id>/CREDITS.json.

    FFMPEG=C:/dev/tools/ffmpeg/bin/ffmpeg.exe python tool/generate_placeholder_audio.py

Real files replace these one by one: drop the file in, point the catalog or
the game's manifest at it, update its credits entry and remove it from the
lists below. Credits of real recordings are kept when the script runs.
"""

import json
import math
import os
import subprocess
import tempfile
import struct
import wave
from pathlib import Path

RATE = 22050
ROOT = Path(__file__).resolve().parent.parent / "assets" / "audio"
GAMES = ROOT.parent / "games"
FFMPEG = os.environ.get("FFMPEG", "ffmpeg")
GENERATED = "Deskovky (vygenerováno)"

# Menu and Hádej číslo already have real music (see CREDITS.json).
# Each track is a quiet 4 s chord loop; whole-Hz frequencies make 4 s an
# exact number of periods, so the loop is seamless. Tremolo speed differs
# per track so the tracks are told apart.
MUSIC = {
    "checkers": ([165, 196, 247], 0.5),
}

# Each game's own effects (spec 13.5–13.8), ids `<game>.<name>`.
GAME_SFX = {
    "tictactoe": {"draw": ([0], 0.12, "noise"), "line": ([660, 880], 0.1, "sine")},
    "memory": {"match": ([1047, 1319], 0.1, "bell"), "miss": ([220], 0.18, "sine")},
    "minesweeper": {
        "dig": ([0], 0.08, "noise"),
        "flag": ([784], 0.06, "click"),
        "puff": ([0, 0], 0.12, "noise"),
    },
    "ludo": {
        "hop": ([523], 0.06, "click"),
        "boing": ([392, 262], 0.12, "sine"),
        "home": ([523, 659, 784], 0.12, "bell"),
    },
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
        "author": GENERATED,
        "source_url": "https://github.com/mpridal/deskovky/blob/main/tool/generate_placeholder_audio.py",
        "license": "CC0 1.0",
        "attribution_text": f"„{title}“ – zástupný zvuk vygenerovaný skriptem, CC0 1.0",
    }


def write_ogg(path, samples):
    path.parent.mkdir(parents=True, exist_ok=True)
    with tempfile.TemporaryDirectory() as tmp:
        wav = Path(tmp) / "x.wav"
        write_wav(wav, samples)
        subprocess.run(
            [FFMPEG, "-y", "-loglevel", "error", "-i", str(wav), "-c:a", "libvorbis", "-q:a", "3", str(path)],
            check=True,
        )


def notes(names, length, kind):
    samples = []
    for i, freq in enumerate(names):
        samples += note(freq, length, kind, i)
    return samples


def kept(path):
    """Credits of real recordings in an existing CREDITS.json."""
    old = json.loads(path.read_text(encoding="utf-8")) if path.exists() else []
    return [c for c in old if c["author"] != GENERATED]


def save(path, credits):
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(credits, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")


def main():
    shared = kept(ROOT / "CREDITS.json")
    for name, (freqs, length, kind) in SFX.items():
        file = f"sfx/{name}.wav"
        write_wav(ROOT / file, notes(freqs, length, kind))
        shared.append(credit(file, f"Zástupný efekt {name}"))
    save(ROOT / "CREDITS.json", shared)

    for game in sorted(set(MUSIC) | set(GAME_SFX)):
        credits = kept(GAMES / game / "CREDITS.json")
        if game in MUSIC:
            freqs, tremolo = MUSIC[game]
            write_ogg(ROOT / "music" / f"{game}.ogg", music(freqs, tremolo))
            credits.append(credit(f"music/{game}.ogg", f"Zástupná hudba {game}"))
        for name, (freqs, length, kind) in GAME_SFX.get(game, {}).items():
            file = f"games/{game}/sfx/{name}.ogg"
            write_ogg(GAMES / game / "sfx" / f"{name}.ogg", notes(freqs, length, kind))
            credits.append(credit(file, f"Zástupný efekt {game}.{name}"))
        save(GAMES / game / "CREDITS.json", credits)


if __name__ == "__main__":
    main()
