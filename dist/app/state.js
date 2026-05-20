import { createInitialState, setDate } from '../core/puzzle.js';
export function todayDailyId() {
    const today = new Date();
    const year = today.getFullYear();
    const month = String(today.getMonth() + 1).padStart(2, '0');
    const day = String(today.getDate()).padStart(2, '0');
    return `${year}-${month}-${day}`;
}
export function createAppState() {
    const puzzle = createInitialState();
    const today = new Date();
    setDate(puzzle, today.getMonth(), today.getDate());
    return {
        puzzle,
        seed: 12345,
        moveCount: 0,
        elapsedMs: 0,
        timerRunning: true,
        timerStartedAt: typeof performance === 'undefined' ? 0 : performance.now(),
        streak: 0,
        lastDailyId: null,
        completedDailyIds: [],
        mode: 'daily',
        undoStack: [],
        redoStack: [],
        pendingPlacement: null,
        hintText: 'Pick a piece, rotate it if needed, then place it on the calendar without covering today.',
        tutorialCompleted: false,
        showTutorial: true,
        accessibility: {
            highContrast: false,
            largerText: false,
            reducedMotion: false,
            soundEnabled: true
        }
    };
}
