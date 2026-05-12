import { PuzzleState } from './types.js';
import { visibleWindows } from './puzzle.js';

export function render_game_to_text(state: PuzzleState): string {
  const v = visibleWindows(state);
  const pieces = state.pieces.map((p) => `${p.id}:${p.axis}@(${p.x},${p.y})`).join('\n');
  return `VISIBLE month=${v.month} day=${v.day}\n${pieces}`;
}
