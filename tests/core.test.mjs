import test from 'node:test';
import assert from 'node:assert/strict';
import { createInitialState, movePiece, randomize } from '../dist/core/puzzle.js';
import { render_game_to_text } from '../dist/core/debug.js';
import { mulberry32 } from '../dist/core/rng.js';
import { solveToInitial, applySolveSteps } from '../dist/core/solver.js';
import { generateCandidate } from '../dist/core/generator.js';
import { serializePuzzle, deserializePuzzle } from '../dist/core/serialization.js';
import { isValidPuzzleDate } from '../dist/core/date.js';

test('move constraints respected', () => {
  const s = createInitialState();
  assert.equal(movePiece(s, 'h1', 99), false);
  assert.equal(movePiece(s, 'h1', 1), true);
});

test('debug output includes visible windows', () => {
  const s = createInitialState();
  assert.match(render_game_to_text(s), /VISIBLE month=Jan day=1/);
});

test('deterministic text snapshot with seeded randomize', () => {
  const s = createInitialState();
  randomize(s, mulberry32(12345));
  const snapshot = render_game_to_text(s);
  assert.equal(snapshot, 'VISIBLE month=Jan day=1\nh1:x@(2,2)\nh2:x@(1,4)\nv1:y@(1,1)\nv2:y@(4,4)');
});

test('solver returns state to initial', () => {
  const s = createInitialState();
  randomize(s, mulberry32(7));
  const steps = solveToInitial(s);
  assert.equal(applySolveSteps(s, steps), true);
  assert.equal(render_game_to_text(s), render_game_to_text(createInitialState()));
});

test('generator creates in-bounds candidate', () => {
  const s = generateCandidate(mulberry32(99));
  for (const p of s.pieces) {
    const pos = p.axis === 'x' ? p.x : p.y;
    assert.ok(pos >= p.min && pos <= p.max);
  }
});

test('serialization round trip preserves state', () => {
  const s = generateCandidate(mulberry32(21));
  const raw = serializePuzzle(s);
  const parsed = deserializePuzzle(raw);
  assert.deepEqual(parsed, s);
});

test('date validation enforces month/day limits', () => {
  assert.equal(isValidPuzzleDate(0, 1), true);
  assert.equal(isValidPuzzleDate(11, 31), true);
  assert.equal(isValidPuzzleDate(12, 1), false);
  assert.equal(isValidPuzzleDate(-1, 1), false);
  assert.equal(isValidPuzzleDate(5, 0), false);
  assert.equal(isValidPuzzleDate(5, 32), false);
});
