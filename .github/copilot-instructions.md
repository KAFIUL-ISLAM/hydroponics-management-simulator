# Copilot instructions

## Project purpose

- This is a Godot 4/GDScript hydroponics management simulator and technical-review submission for a game development position.
- It is inspired by the hydroponics system in *Probably Stolen*; it is not a complete recreation.

## Collaboration and scope

- The human developer owns project decisions and manual acceptance.
- Codex handles primary implementation, complex debugging, and regression testing.
- Copilot supports development and documentation, and performs Git operations only when authorized.
- Do not independently expand scope. Complete only the assigned task.

## Architecture

- `scenes/workshop.tscn` is the normal gameplay entry point. The active workshop presentation and interaction code is in `scripts/workshop_view.gd`, `scripts/workstation_view.gd`, `scripts/inventory_grid.gd`, `scripts/workshop_slot.gd`, and `scripts/workshop_night_feedback.gd`.
- `scripts/coffee_farm.gd` owns the farming state and settlement path, supported by focused simulation modules and data in `resources/`.
- Preserve `scenes/main.tscn` and `scenes/coffee_dashboard.tscn` as legacy dashboard and compatibility entry points; do not treat them as the normal launch.
- Consult `README.md`, `docs/PROJECT_STATUS.md`, `docs/FORMULAS.md`, `docs/CALCULATION_CONTRACT.md`, and relevant milestone reports instead of duplicating architecture or formula details.

## Protected simulation and approved interaction

- Do not modify simulation formulas, crop resources or balance, growth or health, water or mineral use, pollution or energy calculations, equipment effects, genetics or DNA, harvest or seed production, nightly settlement, or existing regression expectations without explicit developer authorization.
- Preserve the approved immersive orbital workshop: icon-based interaction, hover information, drag-and-drop installation, automatic machine operation, Next Night progression, click-to-collect output, environmental disposal, dynamic inventory/output capacity, dedicated analysis tools, bilingual Chinese/English presentation, and Reduced Motion support.

## Documentation integrity

- Use repository evidence. Never fabricate tests, numerical measurements, implemented features, dates, screenshots, or decisions.
- Distinguish historical verification from tests newly run against the current checkout, and reference-game observations from implemented mechanics.
- Preserve historical records and evidence of developer decisions and manual testing. Accurately acknowledge AI-assisted work.

## Git safety

- Inspect Git status before editing and preserve unrelated changes.
- Never force-push, rewrite published history, move existing release tags, commit credentials, or stage unrelated files.
- Do not commit or push without explicit authorization.

## Efficiency and current context

- Prefer targeted inspection, existing utilities, and minimal changes. Avoid unnecessary refactoring or repository-wide analysis.
- Before work, read `AGENTS.md`, `README.md`, `docs/PROJECT_STATUS.md`, `docs/VISUAL_DEVELOPMENT_PLAN.md`, and relevant milestone reports. Treat milestone test evidence as historical unless freshly verified.
- Do not put temporary milestone status, quota percentages, test counts, or commit hashes in these permanent instructions.
