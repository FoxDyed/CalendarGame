import test from 'node:test';
import assert from 'node:assert/strict';
import {
  boardIntegrity,
  createInitialState,
  hasCollision,
  legalMoves,
  movePiece,
  randomize,
  setDate,
  visibleWindows
} from '../dist/core/puzzle.js';
import { render_game_to_text } from '../dist/core/debug.js';
import { mulberry32 } from '../dist/core/rng.js';
import { applySolveSteps, solveToInitial, solverValidationHarness } from '../dist/core/solver.js';
import { generateCandidate } from '../dist/core/generator.js';
import { serializePuzzle, deserializePuzzle } from '../dist/core/serialization.js';
import { isValidPuzzleDate } from '../dist/core/date.js';

test('movement validity and legal move generation', () => {
  const s = createInitialState();
  assert.equal(movePiece(s, 'h1', -1), false);
  assert.equal(movePiece(s, 'h2', 1), true);
  const moves = legalMoves(s);
  assert.ok(moves.length > 0);
  assert.ok(moves.every((m) => Math.abs(m.delta) === 1));
});

test('collision constraints disallow overlap', () => {
  const s = createInitialState();
  assert.equal(movePiece(s, 'v1', 1), false);
  assert.equal(hasCollision(s), false);
});

test('date visibility correctness', () => {
  const s = createInitialState();
  setDate(s, 10, 31);
  const windows = visibleWindows(s);
  assert.equal(windows.month, 'Nov');
  assert.equal(windows.day, 31);
  assert.deepEqual(windows.monthCell, { x: 4, y: 1 });
  assert.deepEqual(windows.dayCell, { x: 2, y: 6 });
});

test('board integrity stays valid after deterministic randomization', () => {
  const s = createInitialState();
  randomize(s, mulberry32(12345));
  assert.equal(boardIntegrity(s), true);
  assert.equal(hasCollision(s), false);
  assert.equal(render_game_to_text(s).startsWith('VISIBLE month=Jan day=1'), true);
});

test('deterministic seeded test case snapshot', () => {
  const s = createInitialState();
  randomize(s, mulberry32(99));
  assert.equal(render_game_to_text(s), 'VISIBLE month=Jan day=1\nh1:x@(3,4)\nh2:x@(2,6)\nv1:y@(1,1)\nv2:y@(5,1)');
});

test('solver validation harness solves seeded candidates', () => {
  const target = createInitialState();
  const samples = [7, 11, 19, 23].map((seed) => {
    const s = createInitialState();
    randomize(s, mulberry32(seed));
    return s;
  });
  const stats = solverValidationHarness(samples, target);
  assert.deepEqual(stats, { solved: 4, unsolved: 0 });

  const candidate = generateCandidate(mulberry32(21));
  const steps = solveToInitial(candidate, target);
  assert.equal(applySolveSteps(candidate, steps), true);
});

test('serialization and date validation', () => {
  assert.equal(isValidPuzzleDate(0, 1), true);
  assert.equal(isValidPuzzleDate(11, 31), true);
  assert.equal(isValidPuzzleDate(12, 1), false);

  const s = generateCandidate(mulberry32(21));
  const parsed = deserializePuzzle(serializePuzzle(s));
  assert.deepEqual(parsed, s);
});
