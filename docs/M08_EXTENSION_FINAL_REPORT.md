# v0.5.0 · Interactive Hydroponics Workshop

## Design basis

The developer’s reference-game playthrough identified icon inventory, item inspection by hovering, physical drag-and-drop, and machine compartments opened from the environment. The large dashboard made cultivation feel like operating global controls. The workshop brings those interactions to the machine while keeping the project’s original artwork and simulation. These are developer observations and design decisions. The workshop makes no claim of complete reference-game fidelity.

## What changed

| Package | Result |
| --- | --- |
| M08-A | Icon-only inventory, live bilingual tooltips, and identity-preserving spatial drag-and-drop. |
| M08-B | Default workshop scene with a double-click chamber, contextual slots, drag-in supplies and seeds, automatic start, and one Next Night control. |
| M08-C | Validated transfers at the pointer’s release position, added rejection feedback and module return, and kept night settlement on the existing game-state path. |
| M08-C.1 | Captured the pressed item before Godot reconstructed the drag origin, which fixed the scaled-window reproduction. Added an environmental dustbin and a separate dock for Seed Profile, DNA Editor and Liquid Analysis. |
| M08-C.2 | Removed the occupied-looking empty seed icon. Fruit and Kotton received distinct seed artwork. Output became individually clickable with a short arrival animation and capacity-safe collection. Corrected the energy meter’s display range. |
| M08-C.3 | Counted seed and produce slots now match capacity. Refills, tablets, modules and spare chassis have a separate tray. Empty machine slots share a muted style. Output shows up to five occupied slots and lists overflow quantities by type. |
| M08-C.4 | Masked the platforms painted into the crop sprites. Each crop keeps its aspect ratio and shares the chamber floor anchor, with the lower rim drawn in front. |

The initial preloaded water and power remain in place. The machine starts through the existing planting and running methods. The night button invokes the existing settlement once per activation. The farm computes yield and grades, then the workshop moves one pending unit per output click. Uncollected output remains available when inventory is full.

## Verification

- **Developer desktop acceptance.** The developer reported completing manual gameplay testing and approving M08-A through M08-C.4. No individual manual test counts were supplied for this release.
- **Automated release gate.** Godot 4.7.2 passed the consolidated runner after a fresh isolated import. Results were 18 suites, 1,327 explicit checks including 149 workshop GUI checks, and four original crop assertion groups. The default workshop launch passed. The legacy Lettuce probe advanced day 1 → 2 and growth 0 → 1, preserving 1,000 ml water, 50 ml minerals, 100 kWh, and READY status.
- **Reported defects.** GUI checks reproduced missed drops, verified both quick release and scaled-input handling, checked single-item collection and full-inventory retention, and verified the energy display against the actual 8 kJ operating debit in the standard fixtures. Renderer captures cover the Kotton overlap fix, all workshop growth sprites, and live resizing.

[Default workshop](../screenshots/m08b-01-workshop.png) · [Loaded machine](../screenshots/m08c-loaded-machine.png) · [Ready output](../screenshots/m08c-completed-output.png) · [Kotton before](../screenshots/m08c4-kotton-before.png) · [Kotton after](../screenshots/m08c4-kotton-after.png) · [Growth and resize comparison](../screenshots/m08c4-chamber-stages.png)

## Simulation integrity and limits

The v0.4.0 comparison found unchanged crop resources, formulas, settlement, genetics, pollution, equipment and numerical fixtures. The only farm-domain additions are a readout for pending output and an atomic single-item collection method that uses the existing computed result. The prior whole-lot method remains available to the legacy dashboard. Coffee retains its existing seed-output category.

The farm still supports one active machine. Power and liquid refills merge into the existing machine reserves. The power meter uses the highest observed session charge as its reference because the model has no detachable battery or separately defined full-charge capacity. Inventory placement is session-local. M09 remains pending.

## Next milestone

M09 adds short optional transitions and readable feedback after final outcomes, highlighting gains, losses, blockers and crop progression. Use the icon workshop’s existing night-completion signal and transfer feedback. Expose the same outcome with reduced motion, keep interaction available, and test rapid input and one notification per accepted night before changing any further presentation. [Visual roadmap](VISUAL_DEVELOPMENT_PLAN.md)
