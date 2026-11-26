# PRE-M08 proposed visual development plan

**M08 final checkpoint.** Packages A–D are complete and accepted. The v0.4.0 release passed the automated gate and the owner authorized publication. M09 remains pending. The December 1, 2026 delivery target remains active. The latest owner-reported weekly Codex allowance is 59%. [M08 final report](M08_FINAL_REPORT.md)

**M08-D checkpoint.** Specialized workstation redesign is implemented. The owner reported all 11 M08-C desktop items passed. Review the M08-D desktop checklist before confirming the complete M08 milestone or authorizing publication of v0.4.0. The previously reported allowance remains the last known value. [M08-D report](M08_PACKAGE_D_REPORT.md)

**M08-C checkpoint.** The laboratory-centered dashboard, aligned hotspots and visual inventory strip are implemented and regression tested. The latest user-reported weekly allowance is 65%. Review both supported resolutions and confirm focus, hotspot and inventory behavior on desktop before authorizing M08-D dialog work. [M08-C report](M08_PACKAGE_C_REPORT.md)

**M08-B checkpoint.** Added the approved laboratory imagery and state-bound crop presentation. The separate chamber stays unused because the laboratory already includes one. Review crop alignment, icon affordances and panel balance before authorizing M08-C. The owner last reported 69% weekly Codex allowance remaining. [Artwork report](M08_PACKAGE_B_REPORT.md)

**M08-A checkpoint.** The owner authorized Package A. The shared theme, workstation layout and regression harness are implemented. Review the desktop baseline and asset dimensions before approving M08-B. M09–M12 remain proposed. [M08-A report](M08_PACKAGE_A_REPORT.md) · [Visual style guide](VISUAL_STYLE_GUIDE.md)

2026-11-26 · December 1 delivery · user-reported weekly Codex allowance remaining 73%

The owner has redirected development toward visual experience, usability and presentation. The technical scope is frozen at v0.3.0, commit 74a3e440f81ba440219ca86ec052e61937c5f5c5. The [employer brief](EMPLOYER_REQUIREMENTS.md) asks for a playable demo and independent decomposition of gameplay and numbers. It leaves the delivery format open. The milestones below are proposals for review. Effort is an estimate of focused working hours, including regression checks at each handoff. Protect clean-target delivery verification before optional polish.

| Milestone | Objective and scope | Dependencies | Effort | Main risks | Acceptance |
| --- | --- | --- | --- | --- | --- |
| M08 Visual identity and interface redesign | Approve an original theme. Rebalance dashboard hierarchy, crop stage readout, resource cards and consistent modal layout. Establish type, spacing and semantic colors. | Owner approves style, language treatment and viewport. [Asset audit](VISUAL_ASSET_INVENTORY.md) | 4–7h | Long strings, lost focus or inherited paths, large redesign churn | 1280 × 720 clean desktop walkthrough; critical controls and readouts visible in approved language(s); existing regression semantics and fixtures pass. |
| M09 Animations, transitions and gameplay feedback | Add short optional transitions and readable state changes after final outcomes. Surface material gains and losses, blocking conditions and crop growth without changing timing. | M08 states and hierarchy | 2–4h | Animation consumes input, stale results, reentrancy | Each accepted night displays one result; no double debit or lost input. Reduced-motion path shows the same data. |
| M10 Usability, onboarding and demo | Guide crop → seed → plant → start → settle → collect. Make block reasons and recovery visible. Distinguish demo actions, preserve selected inventory item, improve equipment and editor navigation. Prepare a Chinese analysis and demonstration route from the agreed outline. | Stable M08 controls and M09 feedback | 2–4h | Too many prompts; presentation hides real costs or state | A fresh tester completes Coffee Beans harvest and replant. One contrast shows how a setup decision changes a numerical outcome. Optional advanced steps demonstrate pollution, gear and DNA. |
| M11 Polish, audio and performance | Harmonize hover/focus/disabled states, type and spacing. Profile actual UI interactions. Add optional short sound cues only with approved assets and mute handling. | Owner-approved assets and supported hardware; M08–M10 baseline | 2–4h | Audio licensing and competing polish; profiling without representative target | No known clipping at agreed sizes, keyboard focus and readable disabled reasons, tested mute if audio ships. Document measured frame data and hardware for any performance claim. |
| M12 Verification, export and submission | Freeze visuals, run full regression, verify desktop on target and prepare the agreed handoff. Include screenshots, capture or export only as agreed. | Confirm target format, environment, channel and exact cutoff; export templates if needed; M08–M11 acceptance | 3–5h | Format or platform constraints; distribution errors | Clean copy and chosen artifact launch on target; 13 existing suites and presentation checks pass; release evidence, credits and launch instructions are accurate. |

## Scope and sequence

- Allow roughly 13–24 focused hours across the five proposals. Protect M12 time first. Under deadline pressure, keep the shared theme, crop/readout hierarchy, clear feedback and first-run path. Defer music, elaborate motion, custom environments and broad responsive reflow.
- Begin with a visual mockup and action/state map for approval. Preserve Godot version, public callable behavior, scene entry points and the settlement lock. Use an interface-only revision for each approved stage. Keep any template/import work and third-party asset acquisition outside this audit.
- Keep perennial crops, warehouse routing, expanded genetics, additional DNA operations, broader modules, economy and other simulation growth out of the plan. The employer brief names none of these as mandatory. Disclose scope differences in the analysis and preserve the existing numerical fixtures.

## Proposed presentation tests

Retain the existing suite and chosen labels/actions contract while rearranging presentation. Add tests in approved future work for viewport bounds and clipping at the agreed minimum and typical sizes; long bilingual labels; tab/focus order and keyboard activation; modal open/close and dismissal; confirmation target identity; retained inventory selection; running, blocked, mature and DNA states; transient feedback under rapid input and reduced-motion modes. Use captured desktop evidence for visual quality and headless tests for structure and behavior. [Baseline and expected invariants](PRE_M08_AUDIT.md)

## Decisions before work is authorized

Confirm the delivery artifact and channel, exact submission time and target machine. Review the Package A layout, bilingual copy and artwork specifications before authorizing Package B. Audio and later presentation milestones remain proposals.
