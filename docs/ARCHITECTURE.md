# Architecture Documentation

## Layers
- **Core (`src/core`)**: puzzle rules, solver, RNG, serialization.
- **App (`src/app`)**: long-lived app state and persistence.
- **UI (`src/ui`)**: DOM rendering and pointer interactions.
- **Entry (`src/main.ts`)**: orchestration, event wiring, and periodic rerender loop.

## Runtime flow
1. Load persisted state or initialize defaults.
2. Bind input events once.
3. Trigger `rerender` after each state mutation.
4. UI renderer applies incremental piece updates (reuses existing nodes).

## Performance hardening
- Incremental rendering via stable piece element map.
- Passive pointer/resize listeners.
- Resize handling moved to `requestAnimationFrame` path.
- Shared `AudioContext` to avoid per-move allocation.
