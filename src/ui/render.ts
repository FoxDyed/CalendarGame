import { AppState } from '../app/state.js';
import { render_game_to_text } from '../core/debug.js';

export function render(state: AppState): void {
  const board = document.getElementById('board')!;
  board.innerHTML = '';
  for (const p of state.puzzle.pieces) {
    const el = document.createElement('div');
    el.className = `piece ${p.axis}`;
    el.textContent = p.id;
    el.style.left = `${p.x * 50}px`;
    el.style.top = `${p.y * 50}px`;
    el.style.width = `${(p.axis === 'x' ? p.length : 1) * 50}px`;
    el.style.height = `${(p.axis === 'y' ? p.length : 1) * 50}px`;
    el.dataset.pieceId = p.id;
    board.appendChild(el);
  }
  document.getElementById('debug')!.textContent = render_game_to_text(state.puzzle);
}
