# M01 — Foundation stabilization plan

**Status: Implemented through M01-T11, ready for milestone review.** The task descriptions below record the approved scope and acceptance criteria. Current test paths use `tests/`. Earlier reports retain commands and paths from their recorded runs. [Package C handoff](M01_PACKAGE_C_REPORT.md)

The milestone preserves the existing dashboard and scene-local architecture. Retain the current prototype growth and resource costs as the baseline. Use explicitly labeled, test-only fixture values to exercise positive costs and shortages. Power gating, concentration, health, planting, harvest, and reference balancing belong to subsequent gameplay milestones. [Project status](PROJECT_STATUS.md) · [Audit](PROJECT_AUDIT.md) · [GDD required features](GDD.md#L692)

## M01-T02 — Reproduce the current runtime baseline

- **Objective** — Establish fresh runtime and test evidence before behavior changes.
- **Affected files** — Append evidence to `docs/TESTING_REPORT.md` and update `docs/PROJECT_STATUS.md`. Run `scenes/main.tscn` and `tests/test_crop_resource.tscn` as inputs.
- **Proposed implementation** — Record the engine build and the checked-out revision. Run the dashboard by explicit scene path and record whether normal project launch has a configured entry. Run the existing crop test in debug mode and capture its four group results and any errors. The scene has no automatic exit, so use the assertion output and stop the run after collecting it.
- **Dependencies** — M01-T01 and access to the installed Godot build.
- **Acceptance criteria** — Record the exact invocation or editor steps, engine version, expected and observed values, and a pass, fail, or blocked result for each check. Separate fresh observations from historical screenshots.
- **Required tests** — Explicit dashboard startup, initial scene render, one click on the night button, and the four existing crop assertions. Check the source-derived expectation of Day 1 to Day 2 and growth 0 to 1 with reserves unchanged at 1000 ml water, 50 ml minerals, and 100 kWh. Capture the default launch behavior and any script errors or warnings. [Audit summary](PROJECT_AUDIT.md#a-project-summary) · [Existing crop test](../tests/test_crop_resource.gd#L6)
- **Suggested Git commit message** — `docs(test): record Godot runtime baseline`

## M01-T03 — Configure the default main scene

- **Objective** — Make ordinary project launch open the existing dashboard.
- **Affected files** — `project.godot`, `docs/PROJECT_STATUS.md`, and `docs/TESTING_REPORT.md`.
- **Proposed implementation** — Set `application/run/main_scene` to `scenes/main.tscn` using the engine-supported scene reference. Preserve the main scene itself and the renderer and display settings.
- **Dependencies** — M01-T02.
- **Acceptance criteria** — Standard project launch opens the dashboard without selecting a main scene or relying on local editor history. The explicit test scene remains separately runnable.
- **Required tests** — Launch the project without a scene argument from a fresh checkout or equivalent clean project context. Compare initial day, crop, and reserves with the T02 baseline. Run the crop test by explicit scene path. [Project config](../project.godot#L11) · [Main scene](../scenes/main.tscn#L56)
- **Suggested Git commit message** — `fix(project): set the dashboard as the main scene`

## M01-T04 — Validate resource inputs

- **Objective** — Give the resource ledger a consistent validation contract before introducing batch debits.
- **Affected files** — `scripts/resource_manager.gd`, new `tests/test_resource_manager.gd` and `tests/test_resource_manager.tscn`, and `docs/TESTING_REPORT.md`.
- **Proposed implementation** — Share validation across affordability, consume, and add operations. Reject unknown resource types, negative and non-finite quantities, and operations that would leave a non-finite balance. Retain valid zero and exact-balance operations. Document the invalid lookup outcome and distinguish invalid input from an otherwise valid request that exceeds reserves. Preserve the existing ml/kWh representation and avoid introducing a tolerance or a new rounding rule.
- **Dependencies** — M01-T02.
- **Acceptance criteria** — Invalid requests cannot mutate balances or emit a successful change. The single-resource API keeps its existing valid behavior. A finite positive credit that would overflow is rejected.
- **Required tests** — Valid add/spend for each resource, exact-balance debit, just-over-balance rejection, zero amounts, an unknown enum value, negative values, NaN, both infinities, and a non-finite result from addition. Assert balances, return values, and relevant signal behavior. [Resource API](../scripts/resource_manager.gd#L26)
- **Suggested Git commit message** — `fix(resources): validate resource types and amounts`

## M01-T05 — Reset to configured starting balances

- **Objective** — Restore the balances configured for the scene instance.
- **Affected files** — `scripts/resource_manager.gd`, the T04 resource tests, and `docs/TESTING_REPORT.md`.
- **Proposed implementation** — Capture the effective starting balances at initialization before the first resource-change signal. Have reset restore the captured values together. Define the reset lifecycle explicitly so a pre-initialization call cannot silently replace scene configuration.
- **Dependencies** — M01-T04.
- **Acceptance criteria** — Reset restores the original values after spending or adding resources. An instance with overrides returns to its own starting balances, and listeners receive one coherent snapshot.
- **Required tests** — Default 1000/50/100 startup, a nondefault fixture with overrides for all three resources, add/spend followed by reset, repeated reset, notification payload, and the documented pre-initialization behavior. [Exports and initialization](../scripts/resource_manager.gd#L16) · [Current reset](../scripts/resource_manager.gd#L72)
- **Suggested Git commit message** — `fix(resources): restore configured starting balances on reset`

## M01-T06 — Commit resource consumption atomically

- **Objective** — Make a multi-resource spend succeed or fail as one operation.
- **Affected files** — `scripts/resource_manager.gd`, `scripts/hydroponics_simulator.gd`, the T04 resource tests, and `docs/TESTING_REPORT.md`.
- **Proposed implementation** — Add a batch debit that validates every requested amount and every affected balance before any write. Return a success or structured failure reason. On success, apply all changes before emitting a single snapshot for a changed balance. Route the current nightly water and mineral costs through the batch and advance growth only after explicit success.
- **Dependencies** — M01-T04.
- **Acceptance criteria** — A rejected or malformed batch leaves all balances and growth unchanged. The caller can distinguish a shortage from invalid input. Listeners see the final balances together, and a successful zero-cost night avoids a redundant balance-change notification.
- **Required tests** — Successful dual debit and one final signal, a shortage in each resource, invalid input in a mixed request, exact and zero-value batches, and an observer that checks both balances at notification time. Verify zero growth on a rejected transaction. [Current nightly debit](../scripts/hydroponics_simulator.gd#L42)
- **Suggested Git commit message** — `fix(simulation): apply nightly resource costs atomically`

## M01-T07 — Stabilize nightly settlement transitions

- **Objective** — Give each accepted night one guarded execution and one terminal outcome.
- **Affected files** — `scripts/game_state.gd`, `scripts/hydroponics_simulator.gd`, new `tests/test_night_state.gd` and `tests/test_night_state.tscn`, and `docs/TESTING_REPORT.md`.
- **Proposed implementation** — Keep `GameState` responsible for lifecycle and the simulator responsible for calculations. Establish one normal entry point and prevent listeners or direct calls from settling or completing a second time. Carry a typed outcome with enough information to distinguish completed growth, resource-blocked growth, and setup errors. Stabilize state before notifying completion listeners. Proposed policy for approval: a shortage consumes a day, a setup error does not, and a synchronous settlement rejects mid-operation pause without stranding the state. Keep the normal button path.
- **Dependencies** — M01-T06 and approval of the transition policy.
- **Acceptance criteria** — A successful or blocked night advances the day once and returns to `READY`. A configuration failure terminates cleanly without a debit, growth, or day advance. Completion observers see the final state, and a reentrant start or completion attempt cannot process another night before the current call returns.
- **Required tests** — Successful and blocked outcomes, missing dependency, duplicate/reentrant start and completion, direct-call bypass, pause during settlement, crop changes attempted during settlement, and a subsequent legal night. Verify event order, status, day, growth, and balances. [GameState](../scripts/game_state.gd#L35) · [Simulator](../scripts/hydroponics_simulator.gd#L14)
- **Suggested Git commit message** — `fix(simulation): guard nightly settlement transitions`

## M01-T08 — Synchronize the dashboard on entry

- **Objective** — Populate the initial dashboard from live game and simulation state.
- **Affected files** — `scripts/main.gd`, new `tests/test_main_dashboard.gd` and `tests/test_main_dashboard.tscn`, and `docs/TESTING_REPORT.md`.
- **Proposed implementation** — Subscribe to relevant signals and render the initial snapshot, including growth and the selected-crop or empty-state presentation. Keep the current node layout and follow the same rendering path for state changes where practical.
- **Dependencies** — M01-T02. Can be reviewed independently of T04–T07.
- **Acceptance criteria** — Initial values match day, status, reserves, crop identity, and growth immediately on scene entry. The default scene retains its appearance and subsequent night updates still render.
- **Required tests** — Instantiate the dashboard with default and overridden startup values. Exercise a nondefault day and a growth value or deliberately stale label that exposes an omitted initial sync. Check empty-crop rendering and updates after settlement. [Current dashboard initialization](../scripts/main.gd#L15)
- **Suggested Git commit message** — `fix(ui): initialize dashboard from live simulation state`

## M01-T09 — Show settlement shortages on the dashboard

- **Objective** — Explain blocked growth in the existing player interface.
- **Affected files** — `scripts/main.gd`, `scenes/main.tscn` if the feedback label needs a change, the T08 dashboard tests, and `docs/TESTING_REPORT.md`.
- **Proposed implementation** — Bind the settled shortage outcome from T07 to the existing control hint or crop status area. Show the blocked resource in the dashboard's language and include requested/available quantities with units where the outcome provides them. On a successful subsequent night, replace stale feedback. Keep message formatting in the UI.
- **Dependencies** — M01-T07 and M01-T08.
- **Acceptance criteria** — A water or mineral shortage is visible after the night returns to `READY`, and the text explains unchanged growth. A subsequent successful night clears or replaces the previous warning.
- **Required tests** — Water shortage, mineral shortage, successful night after replenishment, and manual readability at the target viewport. Assert that each blocked crop preserves its growth and balances while the header follows the approved day policy. [Current hint](../scenes/main.tscn#L384) · [Existing blocker signal](../scripts/hydroponics_simulator.gd#L4)
- **Suggested Git commit message** — `fix(ui): explain why nightly crop growth was blocked`

## M01-T10 — Add repeatable dashboard-to-settlement integration tests

- **Objective** — Exercise one complete night through the same scene and button action used by the player.
- **Affected files** — New `tests/test_nightly_integration.gd` and `tests/test_nightly_integration.tscn`, plus `docs/TESTING_REPORT.md` and `docs/PROJECT_STATUS.md`.
- **Proposed implementation** — Build a standalone Godot test scene that instantiates `scenes/main.tscn`, supplies isolated test-only `CropData` and reserves, and exercises the wired button. Provide a repeatable headless debug invocation with an explicit success/failure exit code and documented output. Keep the fixtures separate from shipped data.
- **Dependencies** — M01-T03, M01-T05, M01-T07, and M01-T09.
- **Acceptance criteria** — The documented test runs repeatedly from a fresh checkout after the required Godot import step. It fails clearly when a settlement invariant regresses and records exact expected values or an explicit comparison policy for fractional fixtures.
- **Required tests** — Initial dashboard snapshot, successful night with known water/mineral debits, exact-balance success, water shortage, mineral shortage with no partial debit, recovery on a later night, and one day/growth transition per accepted action. Assert the UI, `GameState`, simulator, ledger, and final notifications. Run the existing crop test and the targeted tests from T04, T07, and T08 as regression checks. [Button connection](../scenes/main.tscn#L431) · [GDD test criteria](GDD.md#L734)
- **Suggested Git commit message** — `test(simulation): cover nightly settlement through the dashboard`

## M01-T11 — Normalize the test directory name

- **Objective** — Align the checked-in test paths with the repository's documented `tests/` directory.
- **Affected files** — Move `tetst/` to `tests/` with its scripts, scenes, and `.gd.uid` sidecars. Update current links and invocations in `README.md`, `docs/PROJECT_STATUS.md`, and `docs/TESTING_REPORT.md`. Preserve dated paths and results in the audit and historical records. Include a current path note where readers need one.
- **Proposed implementation** — Make one path-only migration after test coverage is in place. Update current `res://tetst/...` references and commands to `res://tests/...` and verify script and scene UID resolution after import.
- **Dependencies** — M01-T10 and approval of the directory migration.
- **Acceptance criteria** — All tests live under `tests/`, current commands resolve from a fresh checkout, and the migration preserves runnable coverage and past test evidence. Historical links that name `tetst/` are explained by the migration note.
- **Required tests** — Search for stale live references, import a fresh checkout, verify all moved scenes and scripts resolve, rerun the crop and targeted/integration suites using `tests/`, and smoke-test normal dashboard startup. [README path](../README.md#L207) · [Current test scene](../tests/test_crop_resource.tscn#L3)
- **Suggested Git commit message** — `chore(tests): rename tetst directory to tests`

## Approval decisions

- Review the completed M01 foundation before approving gameplay implementation.
- Confirm the target engine and assessment deliverable if a Windows export or a different Godot version is required. Crop selection and reference-formula decisions are tracked separately for the gameplay milestone. [Open research and scope](PROJECT_STATUS.md#open-research-and-scope-decisions)
