import type { Move, PuzzleState } from './types.js';
import { legalMoves, movePiece } from './puzzle.js';

export interface SolveStep extends Move {}

export interface SolveResult {
  solvable: boolean;
  steps: SolveStep[];
  explored: number;
  elapsedMs: number;
  score: number;
}

export interface HintResult {
  hint: SolveStep | null;
  remainingSteps: number;
  score: number;
}

function hashState(state: PuzzleState): string {
  return state.pieces.map((p) => `${p.id}:${p.x},${p.y}`).join('|');
}

function clone(state: PuzzleState): PuzzleState {
  return JSON.parse(JSON.stringify(state)) as PuzzleState;
}

function heuristicDistance(state: PuzzleState, target: PuzzleState): number {
  return state.pieces.reduce((sum, p, i) => {
    const t = target.pieces[i];
    return sum + Math.abs(p.x - t.x) + Math.abs(p.y - t.y);
  }, 0);
}

function reconstructPath(prev: Map<string, { parent: string; move: SolveStep }>, startHash: string, endHash: string): SolveStep[] {
  const path: SolveStep[] = [];
  let cursor = endHash;
  while (cursor !== startHash) {
    const step = prev.get(cursor)!;
    path.push(step.move);
    cursor = step.parent;
  }
  return path.reverse();
}

export function solveToInitial(state: PuzzleState, target: PuzzleState): SolveStep[] {
  return solveWithAStar(state, target).steps;
}

export function solveWithAStar(state: PuzzleState, target: PuzzleState): SolveResult {
  const startTime = performance.now();
  const start = clone(state);
  const startHash = hashState(start);
  const targetHash = hashState(target);
  if (startHash === targetHash) return { solvable: true, steps: [], explored: 0, elapsedMs: 0, score: 0 };

  const gScore = new Map<string, number>([[startHash, 0]]);
  const fScore = new Map<string, number>([[startHash, heuristicDistance(start, target)]]);
  const open: Array<{ state: PuzzleState; hash: string }> = [{ state: start, hash: startHash }];
  const prev = new Map<string, { parent: string; move: SolveStep }>();
  const closed = new Set<string>();
  let explored = 0;

  while (open.length) {
    open.sort((a, b) => (fScore.get(a.hash) ?? Infinity) - (fScore.get(b.hash) ?? Infinity));
    const current = open.shift()!;
    if (closed.has(current.hash)) continue;
    closed.add(current.hash);
    explored += 1;

    if (current.hash === targetHash) {
      const steps = reconstructPath(prev, startHash, targetHash);
      return {
        solvable: true,
        steps,
        explored,
        elapsedMs: performance.now() - startTime,
        score: steps.length + (fScore.get(current.hash) ?? 0)
      };
    }

    for (const m of legalMoves(current.state)) {
      const next = clone(current.state);
      movePiece(next, m.pieceId, m.delta);
      const nextHash = hashState(next);
      const tentativeG = (gScore.get(current.hash) ?? Infinity) + 1;
      if (tentativeG >= (gScore.get(nextHash) ?? Infinity)) continue;
      prev.set(nextHash, { parent: current.hash, move: m });
      gScore.set(nextHash, tentativeG);
      fScore.set(nextHash, tentativeG + heuristicDistance(next, target));
      open.push({ state: next, hash: nextHash });
    }
  }

  return { solvable: false, steps: [], explored, elapsedMs: performance.now() - startTime, score: Infinity };
}

export function generateHint(state: PuzzleState, target: PuzzleState): HintResult {
  const solved = solveWithAStar(state, target);
  return {
    hint: solved.steps[0] ?? null,
    remainingSteps: solved.steps.length,
    score: solved.score
  };
}

export function replaySolution(state: PuzzleState, steps: SolveStep[]): PuzzleState[] {
  const timeline: PuzzleState[] = [clone(state)];
  for (const step of steps) {
    const snapshot = clone(timeline[timeline.length - 1]);
    movePiece(snapshot, step.pieceId, step.delta);
    timeline.push(snapshot);
  }
  return timeline;
}

export function applySolveSteps(state: PuzzleState, steps: SolveStep[]): boolean {
  return steps.every((s) => movePiece(state, s.pieceId, s.delta));
}

export function solverValidationHarness(seedStates: PuzzleState[], target: PuzzleState): { solved: number; unsolved: number } {
  let solved = 0;
  for (const sample of seedStates) {
    const working = clone(sample);
    const result = solveWithAStar(working, target);
    if (!result.solvable) continue;
    if (applySolveSteps(working, result.steps) && hashState(working) === hashState(target)) solved += 1;
  }
  return { solved, unsolved: seedStates.length - solved };
}
