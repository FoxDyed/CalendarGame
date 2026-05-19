import type { PuzzleState } from './types.js';

interface Envelope {
  version: 1;
  state: PuzzleState;
}

export function serializePuzzle(state: PuzzleState): string {
  const payload: Envelope = { version: 1, state };
  return JSON.stringify(payload);
}

export function deserializePuzzle(raw: string): PuzzleState {
  const parsed = JSON.parse(raw) as Partial<Envelope>;
  if (parsed.version !== 1 || !parsed.state) throw new Error('Invalid puzzle serialization payload');
  return parsed.state;
}
