import type { AppState } from './state.js';

const KEY = 'calendar-puzzle-v1';

export function saveState(state: AppState): void {
  localStorage.setItem(KEY, JSON.stringify(state));
}

export function loadState(): AppState | null {
  const raw = localStorage.getItem(KEY);
  if (!raw) return null;
  try {
    const parsed = JSON.parse(raw) as AppState;
    if (!parsed.puzzle?.pieces?.every((p) => Array.isArray(p.cells))) return null;
    for (const piece of parsed.puzzle.pieces) {
      piece.flipped ??= false;
    }
    return parsed;
  } catch { return null; }
}
