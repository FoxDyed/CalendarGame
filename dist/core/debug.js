import { getTransformedCells, isSolved, visibleWindows } from './puzzle.js';
export function render_game_to_text(state) {
    const v = visibleWindows(state);
    const pieces = state.pieces.map((p)=>{
        const location = p.x === null || p.y === null ? 'tray' : `@(${p.x},${p.y})`;
        return `${p.id}:${location}:r${p.rotation}:f${p.flipped ? 1 : 0}:${getTransformedCells(p).map((c)=>`${c.x},${c.y}`).join(' ')}`;
    }).join('\n');
    return `OPEN month=${v.month} day=${v.day} solved=${isSolved(state)}\n${pieces}`;
}
