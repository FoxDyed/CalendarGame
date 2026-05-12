import { AppState } from './state.js';

const KEY = 'calendar-puzzle-v1';

export function saveState(state: AppState): void {
  localStorage.setItem(KEY, JSON.stringify(state));
}

export function loadState(): AppState | null {
  const raw = localStorage.getItem(KEY);
  if (!raw) return null;
  try { return JSON.parse(raw) as AppState; } catch { return null; }
}
