import { AppState } from '../app/state.js';
import { render_game_to_text } from '../core/debug.js';
import { Piece } from '../core/types.js';

const CELL_SIZE = 56;
const boardEl = document.getElementById('board') as HTMLElement;

let dragPieceId: string | null = null;
let dragStartClient = 0;
let dragPixels = 0;
let dragAxis: 'x' | 'y' | null = null;
let dragState: AppState | null = null;
let moveFn: ((pieceId: string, delta: number) => void) | null = null;

function px(n: number): string { return `${n}px`; }
function getPieceStyle(piece: Piece): string {
  const x = piece.x * CELL_SIZE; const y = piece.y * CELL_SIZE;
  const w = (piece.axis === 'x' ? piece.length : 1) * CELL_SIZE;
  const h = (piece.axis === 'y' ? piece.length : 1) * CELL_SIZE;
  return `left:${px(x)};top:${px(y)};width:${px(w)};height:${px(h)};`;
}

function bind(state: AppState, onMove: (pieceId: string, delta: number) => void) {
  dragState = state; moveFn = onMove;
  if (boardEl.dataset.bound === '1') return;
  boardEl.dataset.bound = '1';
  boardEl.addEventListener('pointerdown', (ev) => {
    const target = (ev.target as HTMLElement).closest('.piece') as HTMLElement | null;
    if (!target || !dragState) return;
    const id = target.dataset.pieceId!;
    const p = dragState.puzzle.pieces.find((q) => q.id === id);
    if (!p) return;
    dragPieceId = id; dragAxis = p.axis;
    dragStartClient = p.axis === 'x' ? ev.clientX : ev.clientY;
    dragPixels = 0;
  });
  boardEl.addEventListener('pointermove', (ev) => {
    if (!dragAxis) return;
    const current = dragAxis === 'x' ? ev.clientX : ev.clientY;
    dragPixels = current - dragStartClient;
  });
  boardEl.addEventListener('pointerup', () => {
    if (!dragPieceId || !moveFn) return;
    const delta = Math.max(-1, Math.min(1, Math.round(dragPixels / CELL_SIZE)));
    if (delta !== 0) moveFn(dragPieceId, delta);
    dragPieceId = null; dragAxis = null; dragPixels = 0;
  });
}

export function render(state: AppState, onMove?: (pieceId: string, delta: number) => void, elapsed = '00:00'): void {
  document.body.classList.toggle('reduced-motion', state.accessibility.reducedMotion);
  document.body.classList.toggle('high-contrast', state.accessibility.highContrast);
  document.body.classList.toggle('large-text', state.accessibility.largerText);

  (document.getElementById('moveCount') as HTMLElement).textContent = String(state.moveCount);
  (document.getElementById('timer') as HTMLElement).textContent = elapsed;
  (document.getElementById('streak') as HTMLElement).textContent = String(state.streak);
  (document.getElementById('hint') as HTMLElement).textContent = state.hintText;

  boardEl.innerHTML = '';
  boardEl.style.setProperty('--cols', String(state.puzzle.width));
  boardEl.style.setProperty('--rows', String(state.puzzle.height));
  for (const p of state.puzzle.pieces) {
    const el = document.createElement('div');
    el.className = `piece ${p.axis}`;
    el.setAttribute('role', 'button');
    el.tabIndex = 0;
    el.setAttribute('aria-label', `Piece ${p.id}`);
    el.textContent = p.id;
    el.style.cssText = getPieceStyle(p);
    el.dataset.pieceId = p.id;
    boardEl.appendChild(el);
  }
  document.getElementById('debug')!.textContent = render_game_to_text(state.puzzle);
  if (!state.tutorialCompleted && state.showTutorial) {
    document.getElementById('tutorial')!.textContent = 'Tutorial: drag any piece one cell. Use Hint if stuck.';
  } else {
    document.getElementById('tutorial')!.textContent = '';
  }
  if (onMove) bind(state, onMove);
}
