import { Piece, PuzzleState } from './types.js';

export function createInitialState(): PuzzleState {
  return {
    width: 6,
    height: 8,
    monthIndex: 0,
    day: 1,
    pieces: [
      { id: 'h1', axis: 'x', length: 4, x: 0, y: 2, min: 0, max: 2 },
      { id: 'h2', axis: 'x', length: 3, x: 2, y: 4, min: 1, max: 3 },
      { id: 'v1', axis: 'y', length: 4, x: 1, y: 0, min: 0, max: 3 },
      { id: 'v2', axis: 'y', length: 3, x: 4, y: 2, min: 1, max: 4 }
    ]
  };
}

export function movePiece(state: PuzzleState, pieceId: string, delta: number): boolean {
  const p = state.pieces.find((q) => q.id === pieceId);
  if (!p) return false;
  const next = (p.axis === 'x' ? p.x : p.y) + delta;
  if (next < p.min || next > p.max) return false;
  if (p.axis === 'x') p.x = next; else p.y = next;
  return true;
}

export function randomize(state: PuzzleState, rng: () => number): void {
  for (const p of state.pieces) {
    const span = p.max - p.min + 1;
    const pos = p.min + Math.floor(rng() * span);
    if (p.axis === 'x') p.x = pos; else p.y = pos;
  }
}

export function setDate(state: PuzzleState, monthIndex: number, day: number): void {
  state.monthIndex = monthIndex;
  state.day = day;
}

export function visibleWindows(_state: PuzzleState): { month: string; day: number } {
  const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
  return { month: months[_state.monthIndex], day: _state.day };
}
