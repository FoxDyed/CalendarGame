import { PuzzleState } from './types.js';
import { createInitialState, movePiece } from './puzzle.js';

export interface SolveStep { pieceId: string; delta: number }

export function solveToInitial(state: PuzzleState): SolveStep[] {
  const target = createInitialState();
  const steps: SolveStep[] = [];
  for (const current of state.pieces) {
    const desired = target.pieces.find((p) => p.id === current.id);
    if (!desired) continue;
    const currentPos = current.axis === 'x' ? current.x : current.y;
    const desiredPos = desired.axis === 'x' ? desired.x : desired.y;
    const delta = desiredPos - currentPos;
    if (delta !== 0) steps.push({ pieceId: current.id, delta });
  }
  return steps;
}

export function applySolveSteps(state: PuzzleState, steps: SolveStep[]): boolean {
  return steps.every((s) => movePiece(state, s.pieceId, s.delta));
}
