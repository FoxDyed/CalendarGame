import { createAppState, todayDailyId, type MoveRecord } from './app/state.js';
import { loadState, saveState } from './app/persistence.js';
import { render } from './ui/render.js';
import { legalMoves, movePiece, randomize } from './core/puzzle.js';
import { mulberry32 } from './core/rng.js';

const state = loadState() ?? createAppState();
const rng = mulberry32(state.seed);
const audioCtx = state.accessibility.soundEnabled ? new AudioContext() : null;

function playTick() {
  if (!state.accessibility.soundEnabled || !audioCtx) return;
  const osc = audioCtx.createOscillator();
  const gain = audioCtx.createGain();
  osc.type = 'triangle'; osc.frequency.value = 420;
  gain.gain.value = 0.02;
  osc.connect(gain); gain.connect(audioCtx.destination);
  osc.start(); osc.stop(audioCtx.currentTime + 0.05);
}

function formatElapsed(ms: number): string {
  const s = Math.floor(ms / 1000);
  const m = Math.floor(s / 60);
  return `${String(m).padStart(2, '0')}:${String(s % 60).padStart(2, '0')}`;
}

function applyMove(move: MoveRecord, track = true): boolean {
  const moved = movePiece(state.puzzle, move.pieceId, move.delta);
  if (!moved) return false;
  if (track) {
    state.undoStack.push(move);
    state.redoStack = [];
    state.moveCount += 1;
    playTick();
  }
  return true;
}

function rerender() {
  if (state.timerRunning && state.timerStartedAt) {
    const now = performance.now();
    state.elapsedMs += now - state.timerStartedAt;
    state.timerStartedAt = now;
  }

  const dailyId = todayDailyId();
  if (state.mode === 'daily' && state.lastDailyId !== dailyId) {
    state.lastDailyId = dailyId;
    state.seed = Number(dailyId.replaceAll('-', ''));
    state.puzzle = createAppState().puzzle;
    randomize(state.puzzle, mulberry32(state.seed));
    state.moveCount = 0;
    state.elapsedMs = 0;
    state.undoStack = [];
    state.redoStack = [];
  }

  render(state, (pieceId, delta) => applyMove({ pieceId, delta }) && rerender(), formatElapsed(state.elapsedMs));
  saveState(state);
}

function bindEvents() {
  document.getElementById('resetBtn')?.addEventListener('click', () => {
    state.puzzle = createAppState().puzzle;
    state.moveCount = 0;
    state.elapsedMs = 0;
    state.undoStack = [];
    state.redoStack = [];
    rerender();
  });

  document.getElementById('randomBtn')?.addEventListener('click', () => { randomize(state.puzzle, rng); rerender(); });

  document.getElementById('hintBtn')?.addEventListener('click', () => {
    const m = legalMoves(state.puzzle)[0];
    state.hintText = m ? `Try moving ${m.pieceId} by ${m.delta > 0 ? '+1' : '-1'}` : 'No legal moves';
    rerender();
  });

  document.getElementById('solveBtn')?.addEventListener('click', () => { state.puzzle = createAppState().puzzle; rerender(); });
  document.getElementById('undoBtn')?.addEventListener('click', () => { const mv = state.undoStack.pop(); if (mv && movePiece(state.puzzle, mv.pieceId, -mv.delta)) { state.redoStack.push(mv); rerender(); } });
  document.getElementById('redoBtn')?.addEventListener('click', () => { const mv = state.redoStack.pop(); if (mv && applyMove(mv, false)) { state.undoStack.push(mv); rerender(); } });

  document.getElementById('shareBtn')?.addEventListener('click', async () => {
    const url = `${location.origin}${location.pathname}?seed=${state.seed}`;
    if (navigator.clipboard?.writeText) await navigator.clipboard.writeText(url);
  });

  document.getElementById('dailyBtn')?.addEventListener('click', () => { state.mode = 'daily'; rerender(); });
  document.getElementById('sandboxBtn')?.addEventListener('click', () => { state.mode = 'sandbox'; rerender(); });

  document.getElementById('reducedMotion')?.addEventListener('change', (e) => { state.accessibility.reducedMotion = (e.target as HTMLInputElement).checked; rerender(); });
  document.getElementById('highContrast')?.addEventListener('change', (e) => { state.accessibility.highContrast = (e.target as HTMLInputElement).checked; rerender(); });
  document.getElementById('largerText')?.addEventListener('change', (e) => { state.accessibility.largerText = (e.target as HTMLInputElement).checked; rerender(); });

  addEventListener('resize', () => requestAnimationFrame(rerender), { passive: true });
}

const seedParam = new URLSearchParams(location.search).get('seed');
if (seedParam) {
  state.seed = Number(seedParam);
  randomize(state.puzzle, mulberry32(state.seed));
}

bindEvents();
setInterval(rerender, 1000);
rerender();
