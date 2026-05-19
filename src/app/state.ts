import type { Cell, PuzzleState } from '../core/types.js';
import { createInitialState, setDate } from '../core/puzzle.js';

export interface MoveRecord {
  pieceId: string;
  from: Cell | null;
  to: Cell | null;
  rotation: number;
}

export interface PendingPlacement {
  pieceId: string;
  origin: Cell;
  valid: boolean;
  source: Cell | null;
}

export interface AccessibilityOptions {
  highContrast: boolean;
  largerText: boolean;
  reducedMotion: boolean;
  soundEnabled: boolean;
}

export interface AppState {
  puzzle: PuzzleState;
  seed: number;
  moveCount: number;
  elapsedMs: number;
  timerRunning: boolean;
  timerStartedAt: number | null;
  streak: number;
  lastDailyId: string | null;
  completedDailyIds: string[];
  mode: 'daily' | 'sandbox';
  undoStack: MoveRecord[];
  redoStack: MoveRecord[];
  pendingPlacement: PendingPlacement | null;
  hintText: string;
  tutorialCompleted: boolean;
  showTutorial: boolean;
  accessibility: AccessibilityOptions;
}

export function todayDailyId(): string {
  const today = new Date();
  const year = today.getFullYear();
  const month = String(today.getMonth() + 1).padStart(2, '0');
  const day = String(today.getDate()).padStart(2, '0');
  return `${year}-${month}-${day}`;
}

export function createAppState(): AppState {
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
    accessibility: { highContrast: false, largerText: false, reducedMotion: false, soundEnabled: true }
  };
}
