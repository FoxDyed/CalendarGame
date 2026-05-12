import { PuzzleState } from '../core/types.js';
import { createInitialState } from '../core/puzzle.js';

export interface AppState {
  puzzle: PuzzleState;
  seed: number;
}

export function createAppState(): AppState {
  return { puzzle: createInitialState(), seed: 12345 };
}
