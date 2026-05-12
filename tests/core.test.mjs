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
import { applySolveSteps, generateHint, replaySolution, solveToInitial, solveWithAStar, solverValidationHarness } from '../dist/core/solver.js';
import { generateAllDateCases, generateCandidate, generateSolvableBoardForDate, validateGeneratorForYear } from '../dist/core/generator.js';
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

test('A* solver, hint generation, and replay support', () => {
  const target = createInitialState();
  const candidate = generateCandidate(mulberry32(21));
  const result = solveWithAStar(candidate, target);
  assert.equal(result.solvable, true);
  assert.equal(result.steps.length > 0, true);
  const hint = generateHint(candidate, target);
  assert.notEqual(hint.hint, null);
  const replay = replaySolution(candidate, result.steps);
  assert.equal(replay.length, result.steps.length + 1);
  const final = replay[replay.length - 1];
  assert.equal(applySolveSteps(candidate, result.steps), true);
  assert.deepEqual(final.pieces, target.pieces);
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

test('generator validates all 365 dates and reports unsolved/invalid states', () => {
  const dates = generateAllDateCases();
  assert.equal(dates.length, 365);
  const report = validateGeneratorForYear(mulberry32(5));
  assert.equal(report.generated, 365);
  assert.deepEqual(report.unsolved, []);
  assert.deepEqual(report.invalid, []);
});

test('sub-second solve verification benchmark target', () => {
  const target = createInitialState();
  const dateCases = generateAllDateCases().slice(0, 50);
  const t0 = performance.now();
  for (const d of dateCases) {
    const board = generateSolvableBoardForDate(mulberry32(d.monthIndex * 100 + d.day), d);
    setDate(target, d.monthIndex, d.day);
    const solved = solveWithAStar(board, target);
    assert.equal(solved.solvable, true);
  }
  const elapsed = performance.now() - t0;
  assert.equal(elapsed < 1000, true);
});

test('serialization and date validation', () => {
  assert.equal(isValidPuzzleDate(0, 1), true);
  assert.equal(isValidPuzzleDate(11, 31), true);
  assert.equal(isValidPuzzleDate(12, 1), false);

  const s = generateCandidate(mulberry32(21));
  const parsed = deserializePuzzle(serializePuzzle(s));
  assert.deepEqual(parsed, s);
});
