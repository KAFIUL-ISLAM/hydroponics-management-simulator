"""Generate original workshop PCM and a measured asset manifest using Python 3."""
from array import array
from math import pi, sin
from pathlib import Path
from random import Random
from sys import byteorder
import wave

RATE = 44100
ROOT = Path(__file__).resolve().parent
# Duration in seconds, pitch endpoints in Hz, noise fraction, and peak gain.
CUES = {
    "ui_click": (.075, 620, 440, .38, .24),
    "item_pickup": (.105, 420, 730, .28, .28),
    "item_place": (.13, 340, 195, .43, .32),
    "item_reject": (.17, 280, 165, .29, .28),
    "popup_open": (.19, 240, 410, .29, .30),
    "popup_close": (.16, 410, 240, .29, .26),
    "page_turn": (.16, 680, 325, .82, .24),
    "tab_switch": (.085, 540, 620, .45, .22),
    "machine_start": (.43, 105, 278, .32, .36),
    "machine_stop": (.36, 265, 105, .34, .29),
    "night_transition": (.48, 335, 180, .42, .28),
    "harvest_ready": (.38, 410, 580, .15, .34),
    "item_collect": (.15, 640, 890, .21, .28),
    "resource_warning": (.27, 405, 320, .22, .32),
    "dna_success": (.42, 485, 725, .17, .34),
    "dna_failure": (.31, 420, 175, .33, .29),
}


def effect(duration, start, end, noise_fraction):
    rng = Random(0xA710)
    filtered = slow = phase = 0.0
    count = round(duration * RATE)
    for i in range(count):
        x = i / (count - 1)
        phase += 2 * pi * (start + (end - start) * x) / RATE
        filtered += .22 * (rng.uniform(-1, 1) - filtered)
        slow += .025 * (filtered - slow)
        metal = sin(phase) + .29 * sin(phase * 2.01) + .12 * sin(phase * 3.17)
        envelope = min(1, i / 240) ** 2 * (1 - x) ** 2
        yield envelope * ((1 - noise_fraction) * metal + noise_fraction * 4 * (filtered - slow))


def save(name, samples, gain):
    samples = array("f", samples)
    mean = sum(samples) / len(samples)
    scale = gain * 32767 / max(abs(value - mean) for value in samples)
    pcm = array("h", (round((value - mean) * scale) for value in samples))
    peak = max(abs(value) for value in pcm)
    dc = sum(pcm) / len(pcm) / 32768
    seam = abs(pcm[-1] - pcm[0])
    if byteorder != "little":
        pcm.byteswap()
    path = ROOT / f"{name}.wav"
    with wave.open(str(path), "wb") as stream:
        stream.setparams((1, 2, RATE, len(pcm), "NONE", "not compressed"))
        stream.writeframes(pcm.tobytes())
    return f"| `{path.name}` | {len(pcm)/RATE:.3f} | {path.stat().st_size:,} | {peak/32768:.4f} | {dc:.7f} | {seam} |"


def main():
    rows = [save(name, effect(*params[:4]), params[4]) for name, params in CUES.items()]
    size = sum((ROOT / f"{name}.wav").stat().st_size for name in CUES)
    (ROOT / "MANIFEST.md").write_text(
        "# Orbital Workshop audio\n\n"
        "Original procedural synthesis created for this project. No samples or reference-game audio were used. "
        "Run `python assets/audio/generate.py` from the project root. The generator uses only Python's standard library, "
        "with a fixed audio-only random seed. All 16 files are mono, 44,100 Hz, signed 16-bit PCM one-shot effects.\n\n"
        "| Asset | Seconds | Bytes | Peak (full scale) | DC (full scale) | Boundary delta (PCM steps) |\n"
        "| --- | ---: | ---: | ---: | ---: | ---: |\n"
        + "\n".join(rows) + f"\n\nTotal WAV size: {size:,} bytes. No samples reached clipping.\n",
        encoding="utf-8",
    )


if __name__ == "__main__":
    main()
