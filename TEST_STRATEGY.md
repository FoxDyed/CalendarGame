# Test Strategy (Restricted Environment Aware)

## Priority in this environment
1. Always run unit and logic validation tests.
2. Treat Playwright E2E as optional when Chromium binaries are unavailable.
3. Preserve installation failure evidence in `.logs/12_playwright_install_retry.log`.

## Browser availability gate
- Run `npm run check:playwright`.
- If output reports `PLAYWRIGHT_AVAILABLE=0`, skip Playwright smoke/E2E and continue with unit test workflow.
- If output reports `PLAYWRIGHT_AVAILABLE=1`, run `npm run test:e2e`.

## Required non-browser coverage
- Puzzle move constraints and invariants.
- Solver behavior (return-to-target path validation).
- Generator candidate validity.
- Serialization round-trip safety.
- Date validation boundaries.
- Deterministic text-mode render snapshot path.

## Local developer instruction
Run Playwright E2E only on a machine where `npx playwright install chromium` succeeds.
