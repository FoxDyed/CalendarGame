# Testing Documentation

## Unit tests
- Command: `npm test`
- Coverage: puzzle movement, collisions, generator, solver, serialization, date validity.

## End-to-end regression (Playwright)
- Command: `npm run test:regression`
- Scenarios:
  - multi-viewport smoke including mobile touch + screenshots
  - gameplay persistence and accessibility keyboard path

## CI gate
- Command: `npm run ci:validate`
- Includes build, unit tests, and Playwright regression.

## Low-end simulation guidance
- Use Chromium devtools CPU throttling (4x/6x) and network throttling.
- Repeat `npm run test:regression` while throttled locally.
