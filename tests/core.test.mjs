import test from 'node:test';
import assert from 'node:assert/strict';
import { createInitialState, movePiece } from '../dist/core/puzzle.js';
import { render_game_to_text } from '../dist/core/debug.js';

test('move constraints respected', () => {
  const s = createInitialState();
  assert.equal(movePiece(s, 'h1', 99), false);
  assert.equal(movePiece(s, 'h1', 1), true);
});

test('debug output includes visible windows', () => {
  const s = createInitialState();
  assert.match(render_game_to_text(s), /VISIBLE month=Jan day=1/);
});
