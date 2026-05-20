import { createAppState, todayDailyId } from './app/state.js';
import { loadState, saveState } from './app/persistence.js';
import { render } from './ui/render.js';
import { canPlacePiece, isSolved, placePiece, removePiece, rotatePiece, setDate } from './core/puzzle.js';
import { daysInPuzzleMonth } from './core/date.js';
const loaded = loadState();
const state = loaded ?? createAppState();
const dateInput = document.getElementById('dateInput');
state.pendingPlacement = null;
if (state.timerStartedAt && state.timerStartedAt > performance.now() + 100000) state.timerStartedAt = performance.now();
function formatElapsed(ms) {
    const s = Math.floor(ms / 1000);
    const m = Math.floor(s / 60);
    return `${String(m).padStart(2, '0')}:${String(s % 60).padStart(2, '0')}`;
}
function resetPuzzle() {
    const fresh = createAppState().puzzle;
    setDate(fresh, state.puzzle.monthIndex, state.puzzle.day);
    state.puzzle = fresh;
    state.moveCount = 0;
    state.elapsedMs = 0;
    state.undoStack = [];
    state.redoStack = [];
    state.pendingPlacement = null;
    state.hintText = 'Pick a piece, rotate it if needed, then place it on the calendar without covering today.';
}
function clearPlacedPieces() {
    for (const piece of state.puzzle.pieces){
        piece.x = null;
        piece.y = null;
    }
    state.puzzle.selectedPieceId = null;
    state.pendingPlacement = null;
}
function setPuzzleDate(monthIndex, day, message) {
    setDate(state.puzzle, monthIndex, day);
    clearPlacedPieces();
    state.moveCount = 0;
    state.elapsedMs = 0;
    state.undoStack = [];
    state.redoStack = [];
    state.hintText = message;
}
function syncDateInput() {
    if (!dateInput) return;
    const year = state.puzzle.monthIndex === 1 && state.puzzle.day === 29 ? 2024 : new Date().getFullYear();
    const month = String(state.puzzle.monthIndex + 1).padStart(2, '0');
    const day = String(state.puzzle.day).padStart(2, '0');
    const nextValue = `${year}-${month}-${day}`;
    if (dateInput.value !== nextValue) dateInput.value = nextValue;
}
function setToday() {
    const today = new Date();
    state.mode = 'daily';
    setPuzzleDate(today.getMonth(), today.getDate(), 'Today is selected. Leave that month and day visible.');
}
function setRandomDate() {
    const monthIndex = Math.floor(Math.random() * 12);
    const day = Math.floor(Math.random() * daysInPuzzleMonth(monthIndex)) + 1;
    state.mode = 'sandbox';
    setPuzzleDate(monthIndex, day, 'Random date selected. Pieces stayed in their normal tray order.');
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
        const today = new Date();
        setPuzzleDate(today.getMonth(), today.getDate(), 'Daily date updated to today.');
        state.moveCount = 0;
        state.elapsedMs = 0;
    }
    if (isSolved(state.puzzle)) {
        state.hintText = 'Solved. The selected month and day are the only open calendar cells.';
    }
    render(state, {
        onChange: ()=>{
            state.moveCount += 1;
            rerender();
        },
        onSelect: (pieceId)=>{
            state.puzzle.selectedPieceId = pieceId;
        },
        onPreview: (pieceId, origin, source)=>{
            state.puzzle.selectedPieceId = pieceId;
            state.pendingPlacement = {
                pieceId,
                origin,
                source,
                valid: canPlacePiece(state.puzzle, pieceId, origin)
            };
            const piece = state.puzzle.pieces.find((p)=>p.id === pieceId);
            state.hintText = state.pendingPlacement.valid ? `${piece?.name ?? 'Piece'} fits here. Rotate if you want, then Accept to place it.` : `${piece?.name ?? 'Piece'} does not fit here yet. Rotate or move it until the aura turns green.`;
            rerender();
        },
        onReturnToTray: (pieceId)=>{
            state.pendingPlacement = null;
            removePiece(state.puzzle, pieceId);
            rerender();
        }
    }, formatElapsed(state.elapsedMs));
    syncDateInput();
    saveState(state);
}
function bindEvents() {
    document.getElementById('resetBtn')?.addEventListener('click', ()=>{
        resetPuzzle();
        rerender();
    });
    document.getElementById('randomBtn')?.addEventListener('click', ()=>{
        setRandomDate();
        rerender();
    });
    document.getElementById('todayBtn')?.addEventListener('click', ()=>{
        setToday();
        rerender();
    });
    dateInput?.addEventListener('change', ()=>{
        const selected = dateInput.value ? new Date(`${dateInput.value}T12:00:00`) : null;
        if (!selected || Number.isNaN(selected.getTime())) return;
        state.mode = 'sandbox';
        setPuzzleDate(selected.getMonth(), selected.getDate(), 'Custom date selected. Leave that month and day visible.');
        rerender();
    });
    document.getElementById('rotateBtn')?.addEventListener('click', ()=>{
        const id = state.puzzle.selectedPieceId;
        if (!id) {
            state.hintText = 'Select a piece first, then rotate.';
        } else if (state.pendingPlacement?.pieceId === id) {
            const piece = state.puzzle.pieces.find((p)=>p.id === id);
            const saved = piece ? {
                x: piece.x,
                y: piece.y
            } : null;
            if (piece) {
                piece.x = null;
                piece.y = null;
            }
            if (!rotatePiece(state.puzzle, id)) {
                state.hintText = 'That piece could not rotate.';
            } else {
                state.pendingPlacement.valid = canPlacePiece(state.puzzle, id, state.pendingPlacement.origin);
                state.hintText = state.pendingPlacement.valid ? 'That rotation fits. Accept to place it.' : 'That rotation does not fit here. Try another rotation or drag it elsewhere.';
            }
            if (piece && saved) {
                piece.x = saved.x;
                piece.y = saved.y;
            }
        } else if (!rotatePiece(state.puzzle, id)) {
            state.hintText = 'That rotation collides here. Pick it up or move it first.';
        }
        rerender();
    });
    document.getElementById('acceptBtn')?.addEventListener('click', ()=>{
        const pending = state.pendingPlacement;
        if (!pending) {
            state.hintText = 'Drag a piece onto the board first, then Accept.';
        } else if (!pending.valid || !placePiece(state.puzzle, pending.pieceId, pending.origin)) {
            state.hintText = 'That preview is not valid yet. Move or rotate it until the aura turns green.';
        } else {
            const piece = state.puzzle.pieces.find((p)=>p.id === pending.pieceId);
            state.pendingPlacement = null;
            state.moveCount += 1;
            state.hintText = `${piece?.name ?? 'Piece'} placed.`;
        }
        rerender();
    });
    document.getElementById('clearBtn')?.addEventListener('click', ()=>{
        const id = state.puzzle.selectedPieceId;
        state.pendingPlacement = null;
        if (id) removePiece(state.puzzle, id);
        rerender();
    });
    document.getElementById('hintBtn')?.addEventListener('click', ()=>{
        state.hintText = 'Leave today visible, cover every other active cell, and use Rotate before dropping a piece if its shape is close.';
        rerender();
    });
    document.getElementById('redoBtn')?.addEventListener('click', ()=>{
        state.hintText = 'Redo is parked for now while the game uses free placement instead of sliding history.';
        rerender();
    });
    document.getElementById('shareBtn')?.addEventListener('click', async ()=>{
        const url = `${location.origin}${location.pathname}?seed=${state.seed}`;
        if (navigator.clipboard?.writeText) await navigator.clipboard.writeText(url);
    });
    document.getElementById('dailyBtn')?.addEventListener('click', ()=>{
        setToday();
        rerender();
    });
    document.getElementById('reducedMotion')?.addEventListener('change', (e)=>{
        state.accessibility.reducedMotion = e.target.checked;
        rerender();
    });
    document.getElementById('highContrast')?.addEventListener('change', (e)=>{
        state.accessibility.highContrast = e.target.checked;
        rerender();
    });
    document.getElementById('largerText')?.addEventListener('change', (e)=>{
        state.accessibility.largerText = e.target.checked;
        rerender();
    });
    addEventListener('resize', ()=>requestAnimationFrame(rerender), {
        passive: true
    });
}
const seedParam = new URLSearchParams(location.search).get('seed');
if (seedParam) {
    state.seed = Number(seedParam);
}
if (state.mode === 'daily') {
    const today = new Date();
    setDate(state.puzzle, today.getMonth(), today.getDate());
}
setDate(state.puzzle, state.puzzle.monthIndex, state.puzzle.day);
bindEvents();
setInterval(rerender, 1000);
rerender();
