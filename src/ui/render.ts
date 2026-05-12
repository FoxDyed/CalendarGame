import { AppState } from '../app/state.js';
import { render_game_to_text } from '../core/debug.js';
import { movePiece } from '../core/puzzle.js';
import { Piece } from '../core/types.js';

const CELL_SIZE = 56;
const DRAG_THRESHOLD = 8;
const boardEl = document.getElementById('board') as HTMLElement;

let activePointerId: number | null = null;
let dragPieceId: string | null = null;
let dragAxis: 'x' | 'y' | null = null;
let dragStartClient = 0;
let dragStartCoord = 0;
let dragPixels = 0;
let hasLockedAxis = false;
let dragState: AppState | null = null;
let rerenderFn: (() => void) | null = null;

function px(n: number): string { return `${n}px`; }

function getPieceStyle(piece: Piece): string {
  const x = piece.x * CELL_SIZE;
  const y = piece.y * CELL_SIZE;
  const w = (piece.axis === 'x' ? piece.length : 1) * CELL_SIZE;
  const h = (piece.axis === 'y' ? piece.length : 1) * CELL_SIZE;
  return `left:${px(x)};top:${px(y)};width:${px(w)};height:${px(h)};`;
}

function updateDragVisual() {
  if (!dragPieceId || !boardEl) return;
  for (const pieceEl of boardEl.querySelectorAll<HTMLElement>('.piece')) {
    if (pieceEl.dataset.pieceId !== dragPieceId) continue;
    pieceEl.classList.add('is-dragging');
    pieceEl.classList.toggle('is-constrained', hasLockedAxis);
    const offset = Math.max(-CELL_SIZE, Math.min(CELL_SIZE, dragPixels));
    pieceEl.style.setProperty('--drag-x', dragAxis === 'x' ? `${offset}px` : '0px');
    pieceEl.style.setProperty('--drag-y', dragAxis === 'y' ? `${offset}px` : '0px');
  }
}

function clearDragVisual() {
  for (const pieceEl of boardEl.querySelectorAll<HTMLElement>('.piece')) {
    pieceEl.classList.remove('is-dragging', 'is-constrained');
    pieceEl.style.removeProperty('--drag-x');
    pieceEl.style.removeProperty('--drag-y');
  }
}

function onPointerDown(ev: PointerEvent) {
  const target = (ev.target as HTMLElement).closest('.piece') as HTMLElement | null;
  if (!target || !dragState) return;
  const id = target.dataset.pieceId;
  if (!id) return;
  const piece = dragState.puzzle.pieces.find((p) => p.id === id);
  if (!piece) return;

  activePointerId = ev.pointerId;
  dragPieceId = id;
  dragAxis = piece.axis;
  dragStartClient = piece.axis === 'x' ? ev.clientX : ev.clientY;
  dragStartCoord = piece.axis === 'x' ? piece.x : piece.y;
  dragPixels = 0;
  hasLockedAxis = false;
  target.setPointerCapture(ev.pointerId);
  updateDragVisual();
}

function onPointerMove(ev: PointerEvent) {
  if (activePointerId !== ev.pointerId || !dragAxis) return;
  const current = dragAxis === 'x' ? ev.clientX : ev.clientY;
  dragPixels = current - dragStartClient;
  if (Math.abs(dragPixels) > DRAG_THRESHOLD) hasLockedAxis = true;
  updateDragVisual();
}

function onPointerUp(ev: PointerEvent) {
  if (activePointerId !== ev.pointerId || !dragState || !dragPieceId || !dragAxis) return;
  const steps = Math.round(dragPixels / CELL_SIZE);
  const clamped = Math.max(-1, Math.min(1, steps));
  let moved = false;

  if (clamped !== 0) {
    moved = movePiece(dragState.puzzle, dragPieceId, clamped);
  }

  clearDragVisual();
  activePointerId = null;
  dragPieceId = null;
  dragAxis = null;
  dragPixels = 0;
  hasLockedAxis = false;

  if (moved && rerenderFn) rerenderFn();
}

function bindPointerHandlers(state: AppState, onMove: () => void): void {
  dragState = state;
  rerenderFn = onMove;
  if (boardEl.dataset.pointerBound === '1') return;
  boardEl.dataset.pointerBound = '1';
  boardEl.addEventListener('pointerdown', onPointerDown);
  boardEl.addEventListener('pointermove', onPointerMove);
  boardEl.addEventListener('pointerup', onPointerUp);
  boardEl.addEventListener('pointercancel', onPointerUp);
}

export function render(state: AppState, onMove?: () => void): void {
  boardEl.innerHTML = '';
  boardEl.style.setProperty('--cols', String(state.puzzle.width));
  boardEl.style.setProperty('--rows', String(state.puzzle.height));
  boardEl.style.setProperty('--cell-size', `${CELL_SIZE}px`);

  for (const p of state.puzzle.pieces) {
    const el = document.createElement('div');
    el.className = `piece ${p.axis}`;
    el.setAttribute('role', 'button');
    el.setAttribute('aria-label', `Piece ${p.id}`);
    el.textContent = p.id;
    el.style.cssText = getPieceStyle(p);
    el.dataset.pieceId = p.id;
    boardEl.appendChild(el);
  }

  document.getElementById('debug')!.textContent = render_game_to_text(state.puzzle);
  if (onMove) bindPointerHandlers(state, onMove);
}
