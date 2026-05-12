import { PuzzleState } from './types.js';
import { createInitialState, randomize } from './puzzle.js';

export function generateCandidate(seedRng: () => number): PuzzleState {
  const state = createInitialState();
  randomize(state, seedRng);
  return state;
}
