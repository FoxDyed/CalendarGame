# Calendar Sliding Puzzle Game Plan

## 1) Architecture
- **Core logic layer (`src/core`)**: deterministic puzzle rules, board topology, movement constraints, solver, generator, date mapping, serialization.
- **Application state layer (`src/app`)**: game session state, UI mode state, persistence adapter, challenge mode orchestration.
- **Rendering layer (`src/ui`)**: DOM-based board renderer + animation controller + accessibility bindings.
- **Interaction layer (`src/input`)**: unified pointer/touch/keyboard drag/slide controller.
- **Testing layer (`tests`)**: unit tests for core logic + Playwright E2E smoke/regression.

## 2) Rendering approach
- DOM/CSS Grid for mobile-first responsiveness.
- Puzzle cavity and blocks rendered as absolutely-positioned elements inside constrained tracks.
- CSS transitions for calm movement; JS-driven interpolation for drag previews.

## 3) State model
- `GameState`: board configuration, current selected date, move history, RNG seed, mode flags.
- `UiState`: hint visibility, animation speed, reduced-motion flag, focus target.
- `PersistedState`: serialized `GameState` + settings version.

## 4) Puzzle data model
- Board: canonical 7x7 occupancy mask.
- Labels: month slots (12), day slots (31), blocked slots.
- Pieces: rectangular/cross bars with discrete track constraints.
- Open windows: exactly 2 apertures (month + day).

## 5) Movement constraints
- Each piece has axis (`x` or `y`), min/max index in its rail.
- Collision detection via occupied-cell bitset.
- Legal move = translation along axis preserving no overlap and inside bounds.

## 6) Solver strategy
- BFS/A* hybrid:
  - BFS for shortest solve in low branching cases.
  - A* with heuristic (distance to target reveal) for hint/solve speed.
- Precompute date targets and cache solved states by hash.

## 7) Generation strategy
- Seedable RNG (Mulberry32).
- Generate puzzle layout variants from template rails + piece lengths.
- Validate full date coverage by solver sweep over all 372 dates.
- Keep only layouts passing constraints and target difficulty range.

## 8) Touch interaction model
- Pointer Events abstraction.
- Drag capture with axis lock after threshold.
- Snap to legal discrete step on release.
- Haptic-like feel via easing and subtle click sound.

## 9) Playwright testing strategy
- Smoke: load app, no console errors.
- Interaction: drag piece, verify state text output updates.
- Feature tests: reset/randomize/hint/solve controls.
- Invariant: exactly one month and one day visible.

## 10) File structure
- `index.html`
- `src/main.ts`
- `src/core/{types.ts,rng.ts,puzzle.ts,solver.ts,generator.ts,date.ts,debug.ts}`
- `src/app/{state.ts,persistence.ts,actions.ts}`
- `src/ui/{render.ts,animations.ts,a11y.ts}`
- `src/input/{drag.ts}`
- `styles/main.css`
- `tests/{core.test.ts,e2e.spec.ts}`
- `.logs/`
- `progress.md`

## 11) Milestones
1. Scaffold app + state + static board render.
2. Implement core move constraints + debug text.
3. Add drag/touch + controls.
4. Add solver + hint/solve.
5. Add generator + validation sweep.
6. Add persistence + challenge mode.
7. Add accessibility polish + animations + sound.
8. Add Playwright + unit tests.

## 12) Risk analysis
- Solver performance for 372-date validation may be heavy.
- Drag UX jitter on low-end mobile.
- Ensuring generated layouts remain solvable across all dates.

## 13) Performance targets
- First render < 1.5s on mid-tier mobile.
- Drag frame budget ~16ms.
- Hint generation < 200ms cached, < 1s cold.

## 14) Mobile optimization plan
- Touch targets >= 44px.
- Avoid layout thrash (transform-based movement).
- Reduced motion + low-power mode simplification.

## 15) Future expansion ideas
- Difficulty levels.
- Alternative board skins and wood textures.
- Daily streak and share card.
- Additional puzzle topologies.
