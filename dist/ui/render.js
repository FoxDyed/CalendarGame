import { render_game_to_text } from '../core/debug.js';
import { createCalendarCells, getTransformedCells, visibleWindows } from '../core/puzzle.js';
const boardEl = document.getElementById('board');
const trayEl = document.getElementById('tray');
const moveCountEl = document.getElementById('moveCount');
const timerEl = document.getElementById('timer');
const streakEl = document.getElementById('streak');
const hintEl = document.getElementById('hint');
const debugEl = document.getElementById('debug');
const tutorialEl = document.getElementById('tutorial');
let stateRef = null;
let actionsRef = null;
let drag = null;
let lastSnapshot = '';
function cellKey(cell) {
    return `${cell.x},${cell.y}`;
}
function getBoardMetrics() {
    const rect = boardEl.getBoundingClientRect();
    const styles = getComputedStyle(boardEl);
    const paddingLeft = Number.parseFloat(styles.paddingLeft);
    const paddingRight = Number.parseFloat(styles.paddingRight);
    const paddingTop = Number.parseFloat(styles.paddingTop);
    const paddingBottom = Number.parseFloat(styles.paddingBottom);
    const contentWidth = rect.width - paddingLeft - paddingRight;
    const contentHeight = rect.height - paddingTop - paddingBottom;
    return {
        size: contentWidth / 7,
        left: rect.left + paddingLeft,
        top: rect.top + paddingTop,
        right: rect.left + paddingLeft + contentWidth,
        bottom: rect.top + paddingTop + contentHeight
    };
}
function getCellSize() {
    return getBoardMetrics().size;
}
function pieceBounds(piece) {
    const cells = getTransformedCells({
        ...piece,
        x: null,
        y: null
    });
    return {
        cols: Math.max(...cells.map((c)=>c.x)) + 1,
        rows: Math.max(...cells.map((c)=>c.y)) + 1
    };
}
function createPieceElement(piece, inTray) {
    const el = document.createElement('button');
    el.className = `piece ${inTray ? 'in-tray' : 'on-board'}`;
    el.dataset.pieceId = piece.id;
    el.type = 'button';
    el.setAttribute('aria-label', `${piece.name} piece`);
    el.innerHTML = '';
    return el;
}
function renderPieceShape(el, piece, unit) {
    const bounds = pieceBounds(piece);
    el.style.setProperty('--piece-cols', String(bounds.cols));
    el.style.setProperty('--piece-rows', String(bounds.rows));
    el.style.setProperty('--piece-color', piece.color);
    el.style.width = `${bounds.cols * unit}px`;
    el.style.height = `${bounds.rows * unit}px`;
    el.innerHTML = '';
    for (const cell of getTransformedCells({
        ...piece,
        x: null,
        y: null
    })){
        const block = document.createElement('span');
        block.className = 'piece-cell';
        block.style.gridColumn = String(cell.x + 1);
        block.style.gridRow = String(cell.y + 1);
        el.appendChild(block);
    }
}
function renderCalendarCells(state) {
    boardEl.innerHTML = '';
    const windows = visibleWindows(state.puzzle);
    const open = new Set([
        cellKey(windows.monthCell),
        cellKey(windows.dayCell)
    ]);
    for (const cell of createCalendarCells()){
        const el = document.createElement('div');
        el.className = `calendar-cell ${cell.kind}`;
        el.style.gridColumn = String(cell.x + 1);
        el.style.gridRow = String(cell.y + 1);
        el.textContent = cell.label;
        if (open.has(cellKey(cell))) el.classList.add('target-open');
        boardEl.appendChild(el);
    }
    const brand = document.createElement('div');
    brand.className = 'brand-cell';
    brand.textContent = 'Calendar Puzzle';
    brand.style.gridColumn = '4 / 8';
    brand.style.gridRow = '7';
    boardEl.appendChild(brand);
}
function boardOriginForDrop(ev) {
    if (!drag) return null;
    const metrics = getBoardMetrics();
    const pieceLeft = ev.clientX - drag.offsetX;
    const pieceTop = ev.clientY - drag.offsetY;
    if (pieceLeft > metrics.right || pieceTop > metrics.bottom || pieceLeft < metrics.left - metrics.size || pieceTop < metrics.top - metrics.size) {
        return null;
    }
    const x = Math.round((pieceLeft - metrics.left) / metrics.size);
    const y = Math.round((pieceTop - metrics.top) / metrics.size);
    if (x < 0 || x > 6 || y < 0 || y > 6) return null;
    return {
        x,
        y
    };
}
function positionDragGhost(clientX, clientY) {
    if (!drag) return;
    drag.ghost.style.left = `${clientX - drag.offsetX}px`;
    drag.ghost.style.top = `${clientY - drag.offsetY}px`;
}
function cleanupDrag() {
    if (!drag) return;
    drag.sourceEl.style.visibility = '';
    drag.ghost.remove();
    drag = null;
}
function boardOriginForPoint(clientX, clientY) {
    const metrics = getBoardMetrics();
    if (clientX < metrics.left || clientX > metrics.right || clientY < metrics.top || clientY > metrics.bottom) return null;
    const x = Math.floor((clientX - metrics.left) / metrics.size);
    const y = Math.floor((clientY - metrics.top) / metrics.size);
    if (x < 0 || x > 6 || y < 0 || y > 6) return null;
    return {
        x,
        y
    };
}
function getBoardPadding() {
    const styles = getComputedStyle(boardEl);
    return {
        left: Number.parseFloat(styles.paddingLeft),
        top: Number.parseFloat(styles.paddingTop)
    };
}
function positionPieceOnBoard(el, origin, unit) {
    const padding = getBoardPadding();
    el.style.left = `${padding.left + origin.x * unit}px`;
    el.style.top = `${padding.top + origin.y * unit}px`;
}
function placeBoardPieces(state) {
    const unit = getCellSize();
    for (const piece of state.puzzle.pieces.filter((p)=>p.x !== null && p.y !== null && p.id !== state.pendingPlacement?.pieceId)){
        const el = createPieceElement(piece, false);
        renderPieceShape(el, piece, unit);
        el.classList.toggle('selected', state.puzzle.selectedPieceId === piece.id);
        positionPieceOnBoard(el, {
            x: piece.x,
            y: piece.y
        }, unit);
        boardEl.appendChild(el);
    }
}
function placePreviewPiece(state) {
    const pending = state.pendingPlacement;
    if (!pending) return;
    const piece = state.puzzle.pieces.find((p)=>p.id === pending.pieceId);
    if (!piece) return;
    const el = createPieceElement(piece, false);
    renderPieceShape(el, piece, getCellSize());
    el.classList.add('preview', pending.valid ? 'valid' : 'invalid', 'selected');
    el.setAttribute('aria-label', `${piece.name} preview ${pending.valid ? 'valid' : 'invalid'}`);
    positionPieceOnBoard(el, pending.origin, getCellSize());
    boardEl.appendChild(el);
}
function renderTrayPieces(state) {
    trayEl.innerHTML = '';
    const unit = Math.max(26, Math.min(38, getCellSize() * 0.64));
    for (const piece of state.puzzle.pieces.filter((p)=>(p.x === null || p.y === null) && p.id !== state.pendingPlacement?.pieceId)){
        const el = createPieceElement(piece, true);
        renderPieceShape(el, piece, unit);
        el.classList.toggle('selected', state.puzzle.selectedPieceId === piece.id);
        trayEl.appendChild(el);
    }
}
function bind() {
    if (document.body.dataset.calendarBound === '1') return;
    document.body.dataset.calendarBound = '1';
    document.addEventListener('pointerdown', (ev)=>{
        const target = ev.target.closest('.piece');
        if (!target || !stateRef || !actionsRef) return;
        const id = target.dataset.pieceId;
        const piece = stateRef.puzzle.pieces.find((p)=>p.id === id);
        if (!id || !piece) return;
        if (stateRef.pendingPlacement && stateRef.pendingPlacement.pieceId !== id) {
            stateRef.hintText = 'Finish the current preview with Accept or Clear Piece before selecting another piece.';
            render(stateRef, actionsRef, timerEl.textContent ?? '00:00');
            ev.preventDefault();
            return;
        }
        actionsRef.onSelect(id);
        const rect = target.getBoundingClientRect();
        const grabRatioX = (ev.clientX - rect.left) / rect.width;
        const grabRatioY = (ev.clientY - rect.top) / rect.height;
        const ghost = createPieceElement(piece, false);
        renderPieceShape(ghost, piece, getCellSize());
        ghost.classList.add('dragging', 'drag-ghost');
        ghost.style.position = 'fixed';
        ghost.style.left = '0px';
        ghost.style.top = '0px';
        ghost.style.margin = '0';
        ghost.style.visibility = 'hidden';
        ghost.style.zIndex = '1000';
        document.body.appendChild(ghost);
        const dragRect = ghost.getBoundingClientRect();
        drag = {
            id,
            pointerId: ev.pointerId,
            offsetX: grabRatioX * dragRect.width,
            offsetY: grabRatioY * dragRect.height,
            source: piece.x === null || piece.y === null ? null : {
                x: piece.x,
                y: piece.y
            },
            ghost,
            sourceEl: target
        };
        target.setPointerCapture?.(ev.pointerId);
        target.style.visibility = 'hidden';
        ghost.style.visibility = 'visible';
        positionDragGhost(ev.clientX, ev.clientY);
        ev.preventDefault();
    });
    document.addEventListener('pointermove', (ev)=>{
        if (!drag || ev.pointerId !== drag.pointerId) return;
        positionDragGhost(ev.clientX, ev.clientY);
        ev.preventDefault();
    });
    document.addEventListener('pointerup', (ev)=>{
        if (!drag || ev.pointerId !== drag.pointerId || !stateRef || !actionsRef) return;
        const currentDrag = drag;
        const piece = stateRef.puzzle.pieces.find((p)=>p.id === currentDrag.id);
        const target = boardOriginForDrop(ev);
        cleanupDrag();
        if (piece && target) {
            actionsRef.onPreview(piece.id, target, currentDrag.source);
        } else if (piece) {
            actionsRef.onReturnToTray(piece.id);
        }
        ev.preventDefault();
    });
    document.addEventListener('pointercancel', (ev)=>{
        if (!drag || ev.pointerId !== drag.pointerId || !stateRef || !actionsRef) return;
        const piece = stateRef.puzzle.pieces.find((p)=>p.id === drag.id);
        cleanupDrag();
        if (piece) actionsRef.onReturnToTray(piece.id);
        ev.preventDefault();
    });
    document.addEventListener('dblclick', (ev)=>{
        const target = ev.target.closest('.piece');
        if (!target || !stateRef || !actionsRef) return;
        const id = target.dataset.pieceId;
        if (!id) return;
        if (stateRef.pendingPlacement && stateRef.pendingPlacement.pieceId !== id) {
            stateRef.hintText = 'Finish the current preview with Accept or Clear Piece before selecting another piece.';
            render(stateRef, actionsRef, timerEl.textContent ?? '00:00');
            return;
        }
        stateRef.puzzle.selectedPieceId = id;
        actionsRef.onSelect(id);
    });
    boardEl.addEventListener('click', (ev)=>{
        if (!stateRef || !actionsRef || drag) return;
        if (ev.target.closest('.piece')) return;
        const selectedId = stateRef.pendingPlacement?.pieceId ?? stateRef.puzzle.selectedPieceId;
        if (!selectedId) return;
        const piece = stateRef.puzzle.pieces.find((p)=>p.id === selectedId);
        if (!piece) return;
        const origin = boardOriginForPoint(ev.clientX, ev.clientY);
        if (!origin) return;
        const source = piece.x === null || piece.y === null ? stateRef.pendingPlacement?.source ?? null : {
            x: piece.x,
            y: piece.y
        };
        actionsRef.onPreview(selectedId, origin, source);
        ev.preventDefault();
    });
}
export function render(state, actions, elapsed = '00:00') {
    stateRef = state;
    actionsRef = actions;
    const snapshot = JSON.stringify({
        pieces: state.puzzle.pieces,
        pending: state.pendingPlacement,
        selected: state.puzzle.selectedPieceId,
        moveCount: state.moveCount,
        elapsed,
        streak: state.streak,
        hint: state.hintText,
        tutorial: state.showTutorial && !state.tutorialCompleted,
        a11y: state.accessibility,
        date: [
            state.puzzle.monthIndex,
            state.puzzle.day
        ]
    });
    if (snapshot === lastSnapshot && !drag) return;
    lastSnapshot = snapshot;
    document.body.classList.toggle('reduced-motion', state.accessibility.reducedMotion);
    document.body.classList.toggle('high-contrast', state.accessibility.highContrast);
    document.body.classList.toggle('large-text', state.accessibility.largerText);
    moveCountEl.textContent = String(state.moveCount);
    timerEl.textContent = elapsed;
    streakEl.textContent = String(state.streak);
    hintEl.textContent = state.hintText;
    renderCalendarCells(state);
    placeBoardPieces(state);
    placePreviewPiece(state);
    renderTrayPieces(state);
    debugEl.textContent = render_game_to_text(state.puzzle);
    tutorialEl.textContent = !state.tutorialCompleted && state.showTutorial ? 'Drag a piece onto the calendar, rotate while previewing, then Accept when the aura is green.' : '';
    bind();
}
