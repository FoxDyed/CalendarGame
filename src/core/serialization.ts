import { PuzzleState } from './types.js';

export function serializePuzzle(state: PuzzleState): string {
  return JSON.stringify(state);
}

export function deserializePuzzle(raw: string): PuzzleState {
  return JSON.parse(raw) as PuzzleState;
}
