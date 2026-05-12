import { AppState } from '../app/state.js';
import { render_game_to_text } from '../core/debug.js';
import { Piece } from '../core/types.js';

const CELL_SIZE = 56;
const boardEl = document.getElementById('board') as HTMLElement;
const moveCountEl = document.getElementById('moveCount') as HTMLElement;
const timerEl = document.getElementById('timer') as HTMLElement;
const streakEl = document.getElementById('streak') as HTMLElement;
const hintEl = document.getElementById('hint') as HTMLElement;
const debugEl = document.getElementById('debug') as HTMLElement;
const tutorialEl = document.getElementById('tutorial') as HTMLElement;

let dragPieceId: string | null = null;
let dragStartClient = 0;
let dragPixels = 0;
let dragAxis: 'x' | 'y' | null = null;
let dragState: AppState | null = null;
let moveFn: ((pieceId: string, delta: number) => void) | null = null;
const pieceEls = new Map<string, HTMLElement>();
let lastSnapshot = '';

function getPieceStyle(piece: Piece): [string, string, string, string] {
  const x = `${piece.x * CELL_SIZE}px`;
  const y = `${piece.y * CELL_SIZE}px`;
  const w = `${(piece.axis === 'x' ? piece.length : 1) * CELL_SIZE}px`;
  const h = `${(piece.axis === 'y' ? piece.length : 1) * CELL_SIZE}px`;
  return [x, y, w, h];
}

function createPieceEl(p: Piece): HTMLElement {
  const el = document.createElement('div');
  el.className = `piece ${p.axis}`;
  el.setAttribute('role', 'button');
  el.tabIndex = 0;
  el.setAttribute('aria-label', `Piece ${p.id}`);
  el.textContent = p.id;
  el.dataset.pieceId = p.id;
  return el;
}

function bind(state: AppState, onMove: (pieceId: string, delta: number) => void) {
  dragState = state; moveFn = onMove;
  if (boardEl.dataset.bound === '1') return;
  boardEl.dataset.bound = '1';
  boardEl.addEventListener('pointerdown', (ev) => {
    const target = (ev.target as HTMLElement).closest('.piece') as HTMLElement | null;
    if (!target || !dragState) return;
    const id = target.dataset.pieceId;
    if (!id) return;
    const p = dragState.puzzle.pieces.find((q) => q.id === id);
    if (!p) return;
    dragPieceId = id; dragAxis = p.axis;
    dragStartClient = p.axis === 'x' ? ev.clientX : ev.clientY;
    dragPixels = 0;
  }, { passive: true });
  boardEl.addEventListener('pointermove', (ev) => {
    if (!dragAxis) return;
    const current = dragAxis === 'x' ? ev.clientX : ev.clientY;
    dragPixels = current - dragStartClient;
  }, { passive: true });
  boardEl.addEventListener('pointerup', () => {
    if (!dragPieceId || !moveFn) return;
    const delta = Math.max(-1, Math.min(1, Math.round(dragPixels / CELL_SIZE)));
    if (delta !== 0) moveFn(dragPieceId, delta);
    dragPieceId = null; dragAxis = null; dragPixels = 0;
  }, { passive: true });
}

export function render(state: AppState, onMove?: (pieceId: string, delta: number) => void, elapsed = '00:00'): void {
  const snapshot = JSON.stringify({
    pieces: state.puzzle.pieces,
    moveCount: state.moveCount,
    elapsed,
    streak: state.streak,
    hint: state.hintText,
    tutorial: state.showTutorial && !state.tutorialCompleted,
    a11y: state.accessibility,
    cols: state.puzzle.width,
    rows: state.puzzle.height
  });
  if (snapshot === lastSnapshot) return;
  lastSnapshot = snapshot;

  document.body.classList.toggle('reduced-motion', state.accessibility.reducedMotion);
  document.body.classList.toggle('high-contrast', state.accessibility.highContrast);
  document.body.classList.toggle('large-text', state.accessibility.largerText);

  moveCountEl.textContent = String(state.moveCount);
  timerEl.textContent = elapsed;
  streakEl.textContent = String(state.streak);
  hintEl.textContent = state.hintText;

  boardEl.style.setProperty('--cols', String(state.puzzle.width));
  boardEl.style.setProperty('--rows', String(state.puzzle.height));

  for (const p of state.puzzle.pieces) {
    let el = pieceEls.get(p.id);
    if (!el) {
      el = createPieceEl(p);
      pieceEls.set(p.id, el);
      boardEl.appendChild(el);
    }
    const [left, top, width, height] = getPieceStyle(p);
    el.style.left = left;
    el.style.top = top;
    el.style.width = width;
    el.style.height = height;
  }

  debugEl.textContent = render_game_to_text(state.puzzle);
  tutorialEl.textContent = (!state.tutorialCompleted && state.showTutorial)
    ? 'Tutorial: drag any piece one cell. Use Hint if stuck.'
    : '';

  if (onMove) bind(state, onMove);
}
