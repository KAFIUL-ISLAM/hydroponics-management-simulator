# Orbital Workshop audio

Original procedural synthesis created for this project. No samples or reference-game audio were used. Run `python assets/audio/generate.py` from the project root. The generator uses only Python's standard library, with a fixed audio-only random seed. All 16 files are mono, 44,100 Hz, signed 16-bit PCM one-shot effects.

| Asset | Seconds | Bytes | Peak (full scale) | DC (full scale) | Boundary delta (PCM steps) |
| --- | ---: | ---: | ---: | ---: | ---: |
| `ui_click.wav` | 0.075 | 6,660 | 0.2400 | -0.0000001 | 0 |
| `item_pickup.wav` | 0.105 | 9,304 | 0.2800 | 0.0000001 | 0 |
| `item_place.wav` | 0.130 | 11,510 | 0.3200 | -0.0000001 | 0 |
| `item_reject.wav` | 0.170 | 15,038 | 0.2800 | 0.0000002 | 0 |
| `popup_open.wav` | 0.190 | 16,802 | 0.3000 | -0.0000002 | 0 |
| `popup_close.wav` | 0.160 | 14,156 | 0.2600 | 0.0000001 | 0 |
| `page_turn.wav` | 0.160 | 14,156 | 0.2400 | 0.0000000 | 0 |
| `tab_switch.wav` | 0.085 | 7,542 | 0.2200 | 0.0000002 | 0 |
| `machine_start.wav` | 0.430 | 37,970 | 0.3600 | -0.0000000 | 0 |
| `machine_stop.wav` | 0.360 | 31,796 | 0.2900 | 0.0000000 | 0 |
| `night_transition.wav` | 0.480 | 42,380 | 0.2800 | -0.0000000 | 0 |
| `harvest_ready.wav` | 0.380 | 33,560 | 0.3400 | 0.0000000 | 0 |
| `item_collect.wav` | 0.150 | 13,274 | 0.2800 | -0.0000001 | 0 |
| `resource_warning.wav` | 0.270 | 23,858 | 0.3200 | 0.0000001 | 0 |
| `dna_success.wav` | 0.420 | 37,088 | 0.3400 | 0.0000001 | 0 |
| `dna_failure.wav` | 0.310 | 27,386 | 0.2900 | -0.0000001 | 0 |

Total WAV size: 342,480 bytes. No samples reached clipping.
