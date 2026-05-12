import { createAppState } from './app/state.js';
import { loadState, saveState } from './app/persistence.js';
import { render } from './ui/render.js';
import { randomize } from './core/puzzle.js';
import { mulberry32 } from './core/rng.js';

const state = loadState() ?? createAppState();
const rng = mulberry32(state.seed);

function rerender() {
  render(state, rerender);
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
  randomize(state.puzzle, rng);
  rerender();
});

document.getElementById('solveBtn')!.addEventListener('click', () => {
  state.puzzle = createAppState().puzzle;
  rerender();
});

rerender();
