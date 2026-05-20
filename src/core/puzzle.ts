import { dayToIndex, isValidPuzzleDate, monthIndexToLabel } from './date.js';
import type { CalendarCell, Cell, Move, Piece, PuzzleState, VisibilityWindow } from './types.js';

const MONTH_CELLS = Array.from({ length: 12 }, (_, i) => ({ x: i % 6, y: Math.floor(i / 6) }));
const DAY_CELLS = Array.from({ length: 31 }, (_, i) => ({ x: i % 7, y: 2 + Math.floor(i / 7) }));
const MONTHS = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'] as const;

const PIECE_DEFS: Array<Pick<Piece, 'id' | 'name' | 'color' | 'cells'>> = [
  { id: 'A', name: 'Anchor', color: '#d85f45', cells: [{ x: 0, y: 0 }, { x: 1, y: 0 }, { x: 2, y: 0 }, { x: 1, y: 1 }, { x: 1, y: 2 }] },
  { id: 'B', name: 'Bridge', color: '#3d8f78', cells: [{ x: 0, y: 0 }, { x: 0, y: 1 }, { x: 1, y: 1 }, { x: 2, y: 1 }, { x: 2, y: 2 }] },
  { id: 'C', name: 'Corner', color: '#4e7ac7', cells: [{ x: 0, y: 0 }, { x: 1, y: 0 }, { x: 0, y: 1 }, { x: 0, y: 2 }, { x: 1, y: 2 }] },
  { id: 'D', name: 'Hook', color: '#c88a2d', cells: [{ x: 0, y: 0 }, { x: 0, y: 1 }, { x: 0, y: 2 }, { x: 1, y: 2 }] },
  { id: 'E', name: 'Step', color: '#8b67c8', cells: [{ x: 1, y: 0 }, { x: 2, y: 0 }, { x: 0, y: 1 }, { x: 1, y: 1 }] },
  { id: 'F', name: 'Square', color: '#5f9f36', cells: [{ x: 0, y: 0 }, { x: 1, y: 0 }, { x: 0, y: 1 }, { x: 1, y: 1 }] },
  { id: 'G', name: 'Line', color: '#b94f86', cells: [{ x: 0, y: 0 }, { x: 1, y: 0 }, { x: 2, y: 0 }, { x: 3, y: 0 }] },
  { id: 'H', name: 'Tee', color: '#327f9f', cells: [{ x: 0, y: 0 }, { x: 1, y: 0 }, { x: 2, y: 0 }, { x: 1, y: 1 }] },
  { id: 'I', name: 'Triad', color: '#9b6c35', cells: [{ x: 0, y: 0 }, { x: 1, y: 0 }, { x: 0, y: 1 }] },
  { id: 'J', name: 'Bar', color: '#6e7d2f', cells: [{ x: 0, y: 0 }, { x: 1, y: 0 }, { x: 2, y: 0 }] }
];

export function createInitialState(): PuzzleState {
  return {
    width: 7,
    height: 7,
    monthIndex: 0,
    day: 1,
    selectedPieceId: null,
    pieces: PIECE_DEFS.map((p) => ({ ...p, cells: p.cells.map((c) => ({ ...c })), rotation: 0, flipped: false, x: null, y: null }))
  };
}

export function createCalendarCells(): CalendarCell[] {
  const cells: CalendarCell[] = [];
  for (let i = 0; i < 12; i += 1) {
    cells.push({ ...MONTH_CELLS[i], id: `m-${i}`, label: MONTHS[i], kind: 'month' });
  }
  for (let i = 0; i < 31; i += 1) {
    cells.push({ ...DAY_CELLS[i], id: `d-${i + 1}`, label: String(i + 1), kind: 'day' });
  }
  for (const cell of [{ x: 6, y: 0 }, { x: 6, y: 1 }, { x: 3, y: 6 }, { x: 4, y: 6 }, { x: 5, y: 6 }, { x: 6, y: 6 }]) {
    cells.push({ ...cell, id: `blocked-${cell.x}-${cell.y}`, label: '', kind: 'blocked' });
  }
  return cells;
}

export function getPieceCells(piece: Piece): Cell[] {
  return piece.cells.map((c) => ({ x: c.x, y: c.y }));
}

export function getTransformedCells(piece: Piece, origin: Cell | null = piece.x === null || piece.y === null ? null : { x: piece.x, y: piece.y }): Cell[] {
  if (!origin) return getPieceCells(piece);
  return piece.cells.map((c) => ({ x: origin.x + c.x, y: origin.y + c.y }));
}

export function normalizedCells(cells: Cell[]): Cell[] {
  const minX = Math.min(...cells.map((c) => c.x));
  const minY = Math.min(...cells.map((c) => c.y));
  return cells.map((c) => ({ x: c.x - minX, y: c.y - minY })).sort((a, b) => a.y - b.y || a.x - b.x);
}

export function rotatedCells(cells: Cell[]): Cell[] {
  return normalizedCells(cells.map((c) => ({ x: c.y, y: -c.x })));
}

export function flippedCells(cells: Cell[]): Cell[] {
  const maxX = Math.max(...cells.map((c) => c.x));
  return normalizedCells(cells.map((c) => ({ x: maxX - c.x, y: c.y })));
}

export function rotatePiece(state: PuzzleState, pieceId: string): boolean {
  const piece = state.pieces.find((p) => p.id === pieceId);
  if (!piece) return false;
  const original = { cells: piece.cells.map((c) => ({ ...c })), rotation: piece.rotation, flipped: piece.flipped };
  piece.cells = rotatedCells(piece.cells);
  piece.rotation = (piece.rotation + 90) % 360;
  if (piece.x !== null && piece.y !== null && !canPlacePiece(state, piece.id, { x: piece.x, y: piece.y })) {
    piece.cells = original.cells;
    piece.rotation = original.rotation;
    piece.flipped = original.flipped;
    return false;
  }
  return true;
}

export function flipPiece(state: PuzzleState, pieceId: string): boolean {
  const piece = state.pieces.find((p) => p.id === pieceId);
  if (!piece) return false;
  const original = { cells: piece.cells.map((c) => ({ ...c })), flipped: piece.flipped };
  piece.cells = flippedCells(piece.cells);
  piece.flipped = !piece.flipped;
  if (piece.x !== null && piece.y !== null && !canPlacePiece(state, piece.id, { x: piece.x, y: piece.y })) {
    piece.cells = original.cells;
    piece.flipped = original.flipped;
    return false;
  }
  return true;
}

export function removePiece(state: PuzzleState, pieceId: string): boolean {
  const piece = state.pieces.find((p) => p.id === pieceId);
  if (!piece) return false;
  piece.x = null;
  piece.y = null;
  state.selectedPieceId = piece.id;
  return true;
}

export function canPlacePiece(state: PuzzleState, pieceId: string, origin: Cell): boolean {
  const piece = state.pieces.find((p) => p.id === pieceId);
  if (!piece) return false;
  const windows = visibleWindows(state);
  const blocked = new Set(createCalendarCells()
    .filter((c) => c.kind === 'blocked')
    .map((c) => `${c.x},${c.y}`));
  blocked.add(`${windows.monthCell.x},${windows.monthCell.y}`);
  blocked.add(`${windows.dayCell.x},${windows.dayCell.y}`);

  const occupied = new Set<string>();
  for (const other of state.pieces) {
    if (other.id === pieceId || other.x === null || other.y === null) continue;
    for (const c of getTransformedCells(other)) occupied.add(`${c.x},${c.y}`);
  }

  for (const c of getTransformedCells(piece, origin)) {
    const key = `${c.x},${c.y}`;
    if (c.x < 0 || c.x >= state.width || c.y < 0 || c.y >= state.height) return false;
    if (blocked.has(key) || occupied.has(key)) return false;
  }
  return true;
}

export function placePiece(state: PuzzleState, pieceId: string, origin: Cell): boolean {
  const piece = state.pieces.find((p) => p.id === pieceId);
  if (!piece || !canPlacePiece(state, pieceId, origin)) return false;
  piece.x = origin.x;
  piece.y = origin.y;
  state.selectedPieceId = piece.id;
  return true;
}

export function boardIntegrity(state: PuzzleState): boolean {
  return state.pieces.every((p) => p.x === null || p.y === null || canPlacePiece({ ...state, pieces: state.pieces.map((q) => q.id === p.id ? { ...q, x: null, y: null } : q) }, p.id, { x: p.x, y: p.y }));
}

export function hasCollision(state: PuzzleState): boolean {
  const seen = new Set<string>();
  for (const p of state.pieces) {
    if (p.x === null || p.y === null) continue;
    for (const c of getTransformedCells(p)) {
      const key = `${c.x},${c.y}`;
      if (seen.has(key)) return true;
      seen.add(key);
    }
  }
  return false;
}

export function isSolved(state: PuzzleState): boolean {
  const windows = visibleWindows(state);
  const blocked = new Set(createCalendarCells()
    .filter((c) => c.kind === 'blocked')
    .map((c) => `${c.x},${c.y}`));
  blocked.add(`${windows.monthCell.x},${windows.monthCell.y}`);
  blocked.add(`${windows.dayCell.x},${windows.dayCell.y}`);
  const covered = new Set<string>();
  for (const p of state.pieces) {
    if (p.x === null || p.y === null) return false;
    for (const c of getTransformedCells(p)) covered.add(`${c.x},${c.y}`);
  }
  for (let y = 0; y < state.height; y += 1) {
    for (let x = 0; x < state.width; x += 1) {
      const key = `${x},${y}`;
      if (!blocked.has(key) && !covered.has(key)) return false;
    }
  }
  return !hasCollision(state);
}

export function randomize(state: PuzzleState, rng: () => number): void {
  for (const p of state.pieces) {
    p.x = null;
    p.y = null;
    const turns = Math.floor(rng() * 4);
    for (let i = 0; i < turns; i += 1) rotatePiece(state, p.id);
    if (rng() >= 0.5) flipPiece(state, p.id);
  }
  state.pieces.sort(() => rng() - 0.5);
  state.selectedPieceId = state.pieces[0]?.id ?? null;
}

export function movePiece(_state: PuzzleState, _pieceId: string, _delta: number): boolean {
  return false;
}

export function legalMoves(state: PuzzleState): Move[] {
  return state.pieces.map((p) => ({ pieceId: p.id, from: p.x === null || p.y === null ? null : { x: p.x, y: p.y }, to: null, rotation: p.rotation, flipped: p.flipped }));
}

export function setDate(state: PuzzleState, monthIndex: number, day: number): void {
  if (!isValidPuzzleDate(monthIndex, day)) throw new Error('Invalid puzzle date');
  state.monthIndex = monthIndex;
  state.day = day;
  for (const p of state.pieces) {
    if (p.x !== null && p.y !== null && !canPlacePiece(state, p.id, { x: p.x, y: p.y })) {
      p.x = null;
      p.y = null;
    }
  }
}

export function visibleWindows(state: PuzzleState): VisibilityWindow {
  const monthCell = MONTH_CELLS[state.monthIndex];
  const dayCell = DAY_CELLS[dayToIndex(state.day)];
  return { monthCell, dayCell, month: monthIndexToLabel(state.monthIndex), day: state.day };
}
