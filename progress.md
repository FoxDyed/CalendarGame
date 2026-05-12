# Progress

## Completed
- Implemented A* solver with heuristic scoring, move history reconstruction, hint generation, and replay timeline support.
- Implemented solvable-board generator with 365-date validation and invalid/unsolved reporting.
- Added benchmark-oriented tests for sub-second solve verification.
- Added automated all-date (365) test coverage for generator and solver validation.
- Created PLAN.md with architecture and milestone strategy.
- Scaffolded TypeScript browser app and mobile-first styles.
- Added deterministic RNG, core puzzle state, movement constraints.
- Added `render_game_to_text()` debug output.
- Added reset/randomize/hint/solve controls.
- Added local persistence.
- Added initial unit tests.
- Added fallback test strategy for restricted environments (`TEST_STRATEGY.md`).
- Added browser availability check script (`scripts/check-playwright.mjs`).
- Made Playwright smoke test conditionally skip when Chromium is unavailable.
- Expanded non-browser test coverage for puzzle logic, solver, generator, serialization, date validation, and deterministic text snapshots.
- Preserved Playwright install failure evidence at `.logs/12_playwright_install_retry.log`.

## TODO
- Implement true calendar board with 12 month + 31 day slots and exactly two apertures.
- Implement full collision and rail-constrained sliding geometry.
- Extend coverage to leap-year variant dates (366) as optional mode.
- Add procedural generator and solvability validation sweep.
- Add touch drag controls and keyboard accessibility.
- Add Playwright interactive E2E and screenshots (run only where Chromium install succeeds).
- Add daily challenge mode and calm sound effects.
