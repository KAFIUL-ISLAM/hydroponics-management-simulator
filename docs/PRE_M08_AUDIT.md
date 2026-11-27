# Historical project audit and visual preparation

The three-crop loop and advanced systems passed a fresh regression. The owner has since supplied the employer brief. It calls for a playable demo and independent design and numerical analysis. It leaves the handoff format and target environment unspecified. The main delivery risks are clean-target verification and communicating player decisions and numerical outcomes clearly. The technical scope is frozen at v0.3.0, commit 74a3e440f81ba440219ca86ec052e61937c5f5c5. This audit adds documentation only.

- [Original employer brief, English translation and Chinese analysis outline](EMPLOYER_REQUIREMENTS.md)
- [Requirements traceability and submission risks](REQUIREMENTS_TRACEABILITY_MATRIX.md)
- [Visual assets, licensing gaps and screenshot dimensions](VISUAL_ASSET_INVENTORY.md)
- [Current visual development plan](VISUAL_DEVELOPMENT_PLAN.md)

## Evidence and scope

The historical audited documentation covered project status, GDD, glossary, technical design, requirements, research notes, formulas, calculation contract, development log and testing evidence. Use the audited code, current status and [testing report](TESTING_REPORT.md) for baseline behavior. The employer wording is preserved in [Employer requirements](EMPLOYER_REQUIREMENTS.md). No deferred technical feature is established as mandatory by that wording.

Local HEAD, origin/main tracking ref and the peeled tag match the checkpoint. The previous publication verified GitHub directly. No fresh fetch was performed. Existing local exclusions include the obsolete root crop_resource_test.tscn, .godot/ and docs.zip. The obsolete scene references tetst/ and is outside the runner.

Source inspection, captured screenshots and automated results are identified below. Player impacts are inferences. User-confirmed desktop walkthroughs are preserved as historical evidence. No new interactive desktop walkthrough, export, frame-time or latency measurement was performed.

## Gameplay and interaction

| Stage | Observed source or established evidence | Inferred player impact |
| --- | --- | --- |
| Launch and crop selection | Default dashboard hints to plant and start. Crop selection locks once a plant exists. | Multiple equally prominent actions obscure the first step. |
| Seed inspection and planting | Genes → Next seed cycles actual inventory identity. The separate inventory picker is for discard and shows raw instance IDs. DNA can lock the selected seed and disable planting. | Players may confuse the two selectors or have trouble recognizing an item. |
| Activation and settlement | Start and Next Night are distinct. The inherited Next Night caption is Chinese only. READY is global, while running/stopped belongs to the machine. Idle nights can advance the day. | READY can be mistaken for ready to grow. One click can advance an idle cycle. |
| Resource replenishment | Refill amounts appear in tooltips. Buttons generally stay enabled when configured, and rejected operations show generic causes below. Current and target mineral values are textual. | It takes extra inspection or a failed action to understand capacity, costs and recovery. |
| Pollution analysis | A modal lists raw indices, crop exposure, prediction and last running-night detail. Demo solution replacement requires confirmation. | Demo actions can look like ordinary supply actions; the two scales compete in dense rows. |
| Equipment | Gear lists installed/free stock, P/E/Q and rejection text. Switch and install/remove are separate. Running lock and capacity rejection are enforced. | Practical effect on the next night is buried under technical readouts. |
| DNA editing | Genes → DNA edit → select → confirm → close → advance nights → reopen. Cultivation draws from shared energy first. | Reopening interrupts progress tracking. Running and waiting for power share a message. |
| Harvest and reproduction | Mature display shows output quantity and size or textile. Collect stays enabled when storage is short. Products and offspring stay pending together; discard requires confirmation. | The player sees a capacity blocker without a count of slots to free. Offspring visibility depends on Genes. |
| Replant and demos | Coffee output is plantable. Other seeds depend on return rules. Demo seed, demo Coffee and solution scenarios remain available. | Show demo affordances separately so the normal loop stays clear. |

[Dashboard builders](../scripts/coffee_dashboard.gd#L53) · [DNA dialog](../scripts/coffee_dashboard.gd#L145) · [Action handling](../scripts/coffee_dashboard.gd#L440) · [State rendering](../scripts/coffee_dashboard.gd#L463) · [Night feedback](../scripts/coffee_dashboard.gd#L531)

## UI architecture and redesign boundary

| Surface | Construction and dependency |
| --- | --- |
| Scene entry | coffee_dashboard.tscn instances main.tscn, attaches the dashboard script and adds the scene-local CoffeeFarm. Its enter-tree hook disables the inherited Lettuce simulator path for default play. main.tscn remains runnable directly. |
| Base hierarchy | Root Control → Background and SafeArea MarginContainer → VBox with header, three-card resource HBox, two-panel main HBox, control bar and footer. Machine and crop panels have nested VBox containers and inset cards. |
| Runtime construction | The dashboard script adds supplies, action grid, crop/inventory selectors and buttons. It hides the old machine stat grid and inherited Manage/Equipment controls. The actions dictionary and direct node paths are shared with UI tests and inherited bindings. |
| Dialogs | Genes, DNA, Analysis and Gear are created in code with AcceptDialog. A shared ConfirmationDialog stores the pending discard, drain or replacement callable. Labels and option lists are formatted on demand. |
| Signals | Button presses, option selection and confirmation call domain methods. The dashboard listens to GameState day, status and night completion signals. The farm registers the sole playable settlement handler. The legacy scene retains its own binding path. |
| Theme, type and language | Four scene-local StyleBoxFlat variants define visual treatments. Colors and text sizes are overridden per node. Runtime controls inherit the engine theme with some overrides. Scene fonts range 9–34 px; runtime controls commonly use 13 px and analysis 14 px. Bilingual copy is inline, with Chinese-only inherited buttons and generic modal captions. No bundled CJK font was found. |
| Scale and minimum size | Project viewport 1280 × 720, canvas_items stretch and expand aspect. No explicit runtime minimum window size or responsive breakpoints were found. Tests cover bounds at the supported baseline, and smaller, ultrawide and high-DPI behavior remain unverified. |

[Project settings](../project.godot) · [Scene hierarchy and styles](../scenes/main.tscn#L9) · [Playable entry](../scenes/coffee_dashboard.tscn) · [Legacy bindings](../scripts/main.gd) · [GameState](../scripts/game_state.gd)

Safe changes are theme, spacing, visual grouping, readout formatting and modal views. Preserve both scene entries, stable action intent, resource/seed identity, confirmation targets, and the GameState permit and completion order. If nodes move, update the inherited bindings and test lookup points together. Keep calculations, inventory mutations, resource debits and RNG with the existing domain owners. Use final outcomes to drive motion after settlement.

## Prioritized visual findings

| Priority | Finding and evidence | Impact | Estimated effort |
| --- | --- | --- | --- |
| P0 | Handoff format and target environment remain unspecified in the employer brief. | Delivery may fail if the chosen artifact cannot run in the evaluator's environment. | Confirm the delivery format and target environment. |
| P1 | Small feedback and a Chinese-only Next Night caption. Peer buttons compete for attention. Source and screenshots. | First-run and bilingual flow. | Low–medium |
| P1 | Machine name is a fixed scene label while running state is refreshed. Inventory clears and reselects row zero on render. Source verified. | Selected machine or item can be misread before acting. | Low–medium |
| P1 | Flat crop glyph, text-only progress, generic completion feedback and tooltip-only refill quantities. Source and screenshots. | Players struggle to see what changed and what to do next. | Medium |
| P1 | Dense advanced modals and no dashboard editor progress. Source, Analysis and Gear screenshots. | Multi-night and advanced workflows are hard to track. | Medium |
| P2 | Strong resource numbers, smaller muted labels, default gray modals, mixed localization and long IDs. Source and screenshots. | Inconsistent hierarchy and potential readability concerns. Contrast ratios are unmeasured. | Medium |
| P2 | Default keyboard focus, hover and disabled styling with few reason tooltips and no verified focus restoration. Source. | Keyboard-only and low-vision operation needs validation. | Medium |
| P3 | Custom crop art, motion and audio are absent. Asset inventory. | Weak visual identity and limited immediate feedback. | Medium after design approval |

## Performance and regression

A fresh isolated Godot 4.7.2 import passed **13 suites, 932 explicit checks and four original crop assertion groups**, zero failures. Default launch loaded coffee_dashboard.tscn and exited 0. The archived Lettuce probe returned BASELINE_MATCH=true and exited 0. The established Windows certificate-store diagnostic appeared. These results measure functional checks and launch, and no FPS or responsiveness benchmark was taken.

Production scripts have no per-frame process or physics-process callbacks and no active tween or animation loop. UI construction is mostly one-time, with small preloaded scripts and resources. The synchronous render rebuilds the stored item menu and recalculates analysis for unrelated actions. DNA rebuilds its seed list on open, and Gear rebuilds options on selection refresh. These are inspection findings and candidates for profiling. Keep future transitions short and interruptible. Render committed outcomes once and verify focus restoration and rapid input around modal boundaries.

| Preserve | Regression evidence |
| --- | --- |
| Both entrances and legacy startup/night | main_dashboard, nightly_integration, archived Lettuce probe. Day 1 → 2, growth 0 → 1, 1,000 mL water, 50 mL minerals and 100 kWh unchanged in the legacy path. |
| Native cultivation and integer liquid accounting | three_crops, coffee_farm, liquid_composition, resource_manager. Full final-night growth and 16/24/48 kJ; exact losses 3,148/9,430/46,639 µL. |
| Pollution and crop health | pollution. 120/162/605 health units at raw index 20 and eight points. |
| Ownership, planting snapshot, reproduction and capacity | genetics, seed_reproduction and the farming suites. Preserve selected seed, independent traits, pending harvest, single collection and zero offspring heat. |
| Modules, vessel safety, editor state and RNG | equipment and dna_editor. Preserve locks, full energy debits, disc/heat accounting and independent RNG. |
| Atomic settlement and stable completion | night_state, nightly_integration and subsystem suites. Preserve shortage and configuration-error behavior, reentrancy restrictions and final observer state. |

Use the [existing runner](../tests/run-tests.ps1) in an isolated project for each approved change. Additional layout, focus, modal, bilingual and reduced-motion checks are proposed in the [visual plan](VISUAL_DEVELOPMENT_PLAN.md). No tests were added for this audit.

## Decisions for the owner

1. Confirm the target platform and delivery format.
2. Choose the visual direction, default language treatment and minimum supported resolution/Windows scale.
3. Decide whether the first-run walkthrough should feature Coffee Beans first, with an optional advanced route, or present the three crops equally.
4. Confirm the asset and audio scope and reserve time for export and clean-target verification before approving M08.
