# Calendar Puzzle

A browser version of the wooden calendar puzzle: choose a date, then arrange the puzzle pieces so every calendar space is covered except the selected month and day.

Play it here: https://foxdyed.github.io/CalendarGame/

## About the Game

Calendar Puzzle is inspired by physical daily calendar puzzles. The board is a 7 by 7 calendar grid with months, days, and fixed blocked spaces. The challenge is to fit all of the available pieces onto the board while leaving the chosen date visible.

The game defaults to today's date, but you can also pick any valid date or randomize the board date for a new challenge.

## How to Play

1. Pick a piece from the tray.
2. Drag it onto the calendar, or select it and click a board location.
3. Rotate or flip it while it is previewing on the board.
4. Watch the aura around the preview:
   - Green means the piece fits.
   - Red means it overlaps, covers the date, or falls outside the board.
5. Press **Accept** to place the piece.
6. Cover every available cell while keeping the selected month and day uncovered.

## Features

- Daily puzzle based on the current date.
- Custom date picker.
- Random date mode.
- Drag-to-preview and click-to-preview placement.
- Piece rotation and vertical-axis flipping, matching the physical puzzle.
- Rotate/flip-before-accept flow for careful positioning.
- Green/red placement feedback.
- Piece tray with the full puzzle set.
- Move counter, timer, hint text, and shareable seed link.
- Accessibility toggles for high contrast, larger text, and reduced motion.
- Static GitHub Pages deployment.

## How It Is Made

This project is a small static TypeScript app with no frontend framework. The puzzle logic and UI are separated so the core placement rules can be tested independently from the browser rendering.

Main pieces of the codebase:

- `src/core/puzzle.ts` defines the board, pieces, rotations, flips, collisions, placement validation, and win condition.
- `src/core/date.ts` handles valid puzzle dates.
- `src/app/state.ts` defines the application state, daily mode, pending placement, and accessibility settings.
- `src/ui/render.ts` renders the calendar, tray, preview pieces, and pointer interactions.
- `styles/main.css` contains the visual design and responsive layout.
- `scripts/build.mjs` compiles TypeScript into the committed `dist/` files used by GitHub Pages.

## Running Locally

Install dependencies:

```bash
npm install
```

Build the app:

```bash
npm run build
```

Start the local static server:

```bash
npm run serve
```

Then open:

```text
http://127.0.0.1:4173
```

## Testing

Run the core unit tests:

```bash
npm test
```

The repository also includes Playwright smoke and gameplay test scripts:

```bash
npm run test:e2e
npm run test:e2e:gameplay
```

## Deployment

The game is deployed with GitHub Pages from the static files in this repository. After changing TypeScript source files, run:

```bash
npm run build
```

Then commit both the source changes and updated `dist/` output so the published page receives the latest browser code.
