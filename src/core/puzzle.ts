import { dayToIndex, isValidPuzzleDate, monthIndexToLabel } from './date.js';
import { Move, Piece, PuzzleState, VisibilityWindow } from './types.js';

const MONTH_CELLS = Array.from({ length: 12 }, (_, i) => ({ x: i % 6, y: Math.floor(i / 6) }));
const DAY_CELLS = Array.from({ length: 31 }, (_, i) => ({ x: i % 7, y: 2 + Math.floor(i / 7) }));

export function createInitialState(): PuzzleState {
  return {
    width: 7,
    height: 7,
    monthIndex: 0,
    day: 1,
    pieces: [
      { id: 'h1', axis: 'x', length: 3, x: 0, y: 4, min: 0, max: 4 },
      { id: 'h2', axis: 'x', length: 3, x: 2, y: 6, min: 1, max: 4 },
      { id: 'v1', axis: 'y', length: 4, x: 1, y: 0, min: 0, max: 3 },
      { id: 'v2', axis: 'y', length: 3, x: 5, y: 1, min: 1, max: 4 }
    ]
  };
}

export function getPieceCells(p: Piece): { x: number; y: number }[] {
  return Array.from({ length: p.length }, (_, i) => ({ x: p.x + (p.axis === 'x' ? i : 0), y: p.y + (p.axis === 'y' ? i : 0) }));
}

export function boardIntegrity(state: PuzzleState): boolean {
  return state.pieces.every((p) => {
    const pos = p.axis === 'x' ? p.x : p.y;
    if (pos < p.min || pos > p.max) return false;
    return getPieceCells(p).every((c) => c.x >= 0 && c.x < state.width && c.y >= 0 && c.y < state.height);
  });
}

export function hasCollision(state: PuzzleState): boolean {
  const seen = new Set<string>();
  for (const p of state.pieces) {
    for (const c of getPieceCells(p)) {
      const k = `${c.x},${c.y}`;
      if (seen.has(k)) return true;
      seen.add(k);
    }
  }
  return false;
}

export function movePiece(state: PuzzleState, pieceId: string, delta: number): boolean {
  if (!Number.isInteger(delta) || delta === 0) return false;
  const p = state.pieces.find((q) => q.id === pieceId);
  if (!p) return false;
  const copy: Piece = { ...p };
  if (copy.axis === 'x') copy.x += delta; else copy.y += delta;
  const pos = copy.axis === 'x' ? copy.x : copy.y;
  if (pos < copy.min || pos > copy.max) return false;
  const next: PuzzleState = { ...state, pieces: state.pieces.map((q) => (q.id === copy.id ? copy : q)) };
  if (!boardIntegrity(next) || hasCollision(next)) return false;
  p.x = copy.x;
  p.y = copy.y;
  return true;
}

export function legalMoves(state: PuzzleState): Move[] {
  const moves: Move[] = [];
  for (const p of state.pieces) {
    for (const delta of [-1, 1]) {
      const clone = deserializeSerialize(state);
      if (movePiece(clone, p.id, delta)) moves.push({ pieceId: p.id, delta });
    }
  }
  return moves;
}

export function randomize(state: PuzzleState, rng: () => number): void {
  for (let i = 0; i < 40; i += 1) {
    const moves = legalMoves(state);
    if (moves.length === 0) return;
    const m = moves[Math.floor(rng() * moves.length) % moves.length];
    movePiece(state, m.pieceId, m.delta);
  }
}

export function setDate(state: PuzzleState, monthIndex: number, day: number): void {
  if (!isValidPuzzleDate(monthIndex, day)) throw new Error('Invalid puzzle date');
  state.monthIndex = monthIndex;
  state.day = day;
}

export function visibleWindows(state: PuzzleState): VisibilityWindow {
  const monthCell = MONTH_CELLS[state.monthIndex];
  const dayCell = DAY_CELLS[dayToIndex(state.day)];
  return { monthCell, dayCell, month: monthIndexToLabel(state.monthIndex), day: state.day };
}

function deserializeSerialize(state: PuzzleState): PuzzleState {
  return JSON.parse(JSON.stringify(state)) as PuzzleState;
}
