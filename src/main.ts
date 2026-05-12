import { createAppState } from './app/state.js';
import { loadState, saveState } from './app/persistence.js';
import { render } from './ui/render.js';
import { movePiece, randomize } from './core/puzzle';
import { mulberry32 } from './core/rng.js';

const state = loadState() ?? createAppState();
const rng = mulberry32(state.seed);

function rerender() {
  render(state);
  saveState(state);
}

document.getElementById('resetBtn')!.addEventListener('click', () => {
  state.puzzle = createAppState().puzzle;
  rerender();
});

document.getElementById('randomBtn')!.addEventListener('click', () => {
  randomize(state.puzzle, rng);
  rerender();
});

document.getElementById('hintBtn')!.addEventListener('click', () => {
  movePiece(state.puzzle, 'h1', 1) || movePiece(state.puzzle, 'h1', -1);
  rerender();
});

document.getElementById('solveBtn')!.addEventListener('click', () => {
  state.puzzle = createAppState().puzzle;
  rerender();
});

document.getElementById('board')!.addEventListener('click', (e) => {
  const target = e.target as HTMLElement;
  const id = target.dataset.pieceId;
  if (!id) return;
  movePiece(state.puzzle, id, 1) || movePiece(state.puzzle, id, -1);
  rerender();
});

rerender();
