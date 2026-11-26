# Hydroponics Management Simulator

Continue this Godot 4 / GDScript project in place. Start with [the project audit](docs/PROJECT_AUDIT.md) for the development baseline and [the project status](docs/PROJECT_STATUS.md) for the latest scope and verification state. Use the [GDD](docs/GDD.md) for requirements, [FORMULAS.md](docs/FORMULAS.md) and [RESEARCH_NOTES.md](docs/RESEARCH_NOTES.md) for source context, and the [foundation plan](docs/FOUNDATION_STABILIZATION_PLAN.md) for proposed work. Inspect the current files and Git status before changing anything.

## Development rules

1. Continue the existing project. Build on `scenes/main.tscn`, the dashboard, and the scene-local gameplay nodes.
2. Preserve working functionality. Obtain approval for a justified change to existing behavior and document its impact.
3. Use typed GDScript where appropriate, especially for public APIs, state, signals, and calculation inputs and outputs.
4. Keep simulation rules independent of UI presentation. The dashboard sends player actions and renders state or outcomes. Keep UI labels and node paths out of simulation logic.
5. Keep crop definitions data-driven. Put crop-specific parameters in typed Godot resources and keep reusable calculations in the simulation.
6. Treat static crop definitions as shared configuration. Keep mutable plant and seed instance state separate so growth, health, and inherited or edited traits can vary independently.
7. Never invent reference-game formulas or undocumented constants. Cite the source and applicable conditions for every reference-derived rule.
8. Clearly label provisional values, prototype simplifications, assumptions, and unresolved research. Record the reason and approval for any adopted simplification.
9. Use consistent measurement units. Name unit-bearing fields explicitly, for example `water_ml` and `electricity_kwh`. Document conversions, percent versus ratio, and rounding where these affect results.
10. Prevent partial resource transactions. Validate the full operation before mutating balances, and publish resource changes only after the operation commits.
11. Test successful operations, failure conditions, and boundary cases. Exercise the normal scene entry points for integration tests and use deterministic fixtures with explicit units and expected results.
12. Maintain traceability from the requirement and formula source to the implementation, test case, expected result, and run evidence.
13. Mark a feature complete only after its acceptance criteria are verified. Distinguish static inspection, historical evidence, and a fresh test run against the current checkout.
14. Update relevant documentation after approved implementation tasks. Keep the status current, append dated evidence to the testing report or development log where relevant, and preserve existing research and historical evidence.
15. Commit or push only with explicit user approval. A suggested commit message is a proposal for a future commit.
16. Report all files changed, test results and skipped checks, unresolved issues, and design decisions at handoff.

## Git and GitHub workflow

- Prefer milestone-based pushes to GitHub. Use meaningful commit messages that explain the change.
- Review the working tree, untracked files, and staged diff. Stage only reviewed files and keep caches, temporary archives, logs, and credentials out of the repository.
- Fetch the existing remote and check branch alignment before publishing. Never force-push or overwrite an existing tag.
- Push only with explicit user authorization and after the required regression checks pass.
- Preserve accurate development history and AI-assisted development evidence, including dated decisions, test outcomes, and documented limitations. Use portable command examples in published reports.
