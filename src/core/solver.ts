import { Move, PuzzleState } from './types.js';
import { legalMoves, movePiece } from './puzzle.js';

export interface SolveStep extends Move {}

function hashState(state: PuzzleState): string {
  return state.pieces.map((p) => `${p.id}:${p.x},${p.y}`).join('|');
}

function clone(state: PuzzleState): PuzzleState {
  return JSON.parse(JSON.stringify(state)) as PuzzleState;
}

export function solveToInitial(state: PuzzleState, target: PuzzleState): SolveStep[] {
  const startHash = hashState(state);
  const targetHash = hashState(target);
  if (startHash === targetHash) return [];

  const queue: PuzzleState[] = [clone(state)];
  const prev = new Map<string, { parent: string; move: SolveStep }>();
  const seen = new Set<string>([startHash]);

  while (queue.length) {
    const current = queue.shift()!;
    const currentHash = hashState(current);
    for (const m of legalMoves(current)) {
      const next = clone(current);
      movePiece(next, m.pieceId, m.delta);
      const nextHash = hashState(next);
      if (seen.has(nextHash)) continue;
      seen.add(nextHash);
      prev.set(nextHash, { parent: currentHash, move: m });
      if (nextHash === targetHash) {
        const path: SolveStep[] = [];
        let cursor = nextHash;
        while (cursor !== startHash) {
          const step = prev.get(cursor)!;
          path.push(step.move);
          cursor = step.parent;
        }
        return path.reverse();
      }
      queue.push(next);
    }
  }
  return [];
}

export function applySolveSteps(state: PuzzleState, steps: SolveStep[]): boolean {
  return steps.every((s) => movePiece(state, s.pieceId, s.delta));
}

export function solverValidationHarness(seedStates: PuzzleState[], target: PuzzleState): { solved: number; unsolved: number } {
  let solved = 0;
  for (const sample of seedStates) {
    const working = clone(sample);
    const steps = solveToInitial(working, target);
    if (steps.length === 0 && hashState(sample) !== hashState(target)) continue;
    if (applySolveSteps(working, steps) && hashState(working) === hashState(target)) solved += 1;
  }
  return { solved, unsolved: seedStates.length - solved };
}
