import test from 'node:test';
import assert from 'node:assert/strict';
import {
  boardIntegrity,
  canPlacePiece,
  createCalendarCells,
  createInitialState,
  flipPiece,
  getTransformedCells,
  hasCollision,
  placePiece,
  removePiece,
  rotatePiece,
  setDate,
  visibleWindows
} from '../dist/core/puzzle.js';
import { render_game_to_text } from '../dist/core/debug.js';
import { serializePuzzle, deserializePuzzle } from '../dist/core/serialization.js';
import { isValidPuzzleDate } from '../dist/core/date.js';

test('calendar board matches the reference layout', () => {
  const cells = createCalendarCells();
  assert.equal(cells.length, 49);
  assert.deepEqual(cells.filter((c) => c.kind === 'month').map((c) => c.label), ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec']);
  assert.deepEqual(cells.filter((c) => c.kind === 'day').map((c) => c.label).slice(-3), ['29', '30', '31']);
  assert.equal(cells.find((c) => c.x === 3 && c.y === 6)?.kind, 'blocked');
});

test('date windows leave the selected month and day open', () => {
  const s = createInitialState();
  setDate(s, 11, 31);
  const windows = visibleWindows(s);
  assert.equal(windows.month, 'Dec');
  assert.equal(windows.day, 31);
  assert.deepEqual(windows.monthCell, { x: 5, y: 1 });
  assert.deepEqual(windows.dayCell, { x: 2, y: 6 });
});

test('pieces can be placed, removed, and collision checked', () => {
  const s = createInitialState();
  assert.equal(canPlacePiece(s, 'F', { x: 3, y: 3 }), true);
  assert.equal(placePiece(s, 'F', { x: 3, y: 3 }), true);
  assert.equal(s.pieces.find((p) => p.id === 'F').x, 3);
  assert.equal(canPlacePiece(s, 'I', { x: 3, y: 3 }), false);
  assert.equal(hasCollision(s), false);
  assert.equal(boardIntegrity(s), true);
  assert.equal(removePiece(s, 'F'), true);
  assert.equal(s.pieces.find((p) => p.id === 'F').x, null);
});

test('pieces rotate around normalized cells', () => {
  const s = createInitialState();
  const before = getTransformedCells(s.pieces.find((p) => p.id === 'D')).map((c) => `${c.x},${c.y}`).join('|');
  assert.equal(rotatePiece(s, 'D'), true);
  const after = getTransformedCells(s.pieces.find((p) => p.id === 'D')).map((c) => `${c.x},${c.y}`).join('|');
  assert.notEqual(after, before);
  assert.equal(s.pieces.find((p) => p.id === 'D').rotation, 90);
});

test('pieces flip across their vertical axis', () => {
  const s = createInitialState();
  const piece = s.pieces.find((p) => p.id === 'B');
  const before = getTransformedCells(piece).map((c) => `${c.x},${c.y}`).join('|');
  assert.equal(piece.flipped, false);
  assert.equal(flipPiece(s, 'B'), true);
  const after = getTransformedCells(piece).map((c) => `${c.x},${c.y}`).join('|');
  assert.notEqual(after, before);
  assert.equal(piece.flipped, true);
  assert.equal(flipPiece(s, 'B'), true);
  assert.equal(getTransformedCells(piece).map((c) => `${c.x},${c.y}`).join('|'), before);
  assert.equal(piece.flipped, false);
});

test('serialization and date validation remain stable', () => {
  assert.equal(isValidPuzzleDate(0, 1), true);
  assert.equal(isValidPuzzleDate(1, 29), true);
  assert.equal(isValidPuzzleDate(1, 30), false);
  assert.equal(isValidPuzzleDate(11, 31), true);
  assert.equal(isValidPuzzleDate(12, 1), false);

  const s = createInitialState();
  placePiece(s, 'F', { x: 3, y: 3 });
  const parsed = deserializePuzzle(serializePuzzle(s));
  assert.deepEqual(parsed, s);
  assert.equal(render_game_to_text(s).startsWith('OPEN month=Jan day=1'), true);
});
