import { PuzzleState } from '../core/types.js';
import { createInitialState } from '../core/puzzle.js';

export interface MoveRecord { pieceId: string; delta: number }

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
  hintText: string;
  tutorialCompleted: boolean;
  showTutorial: boolean;
  accessibility: AccessibilityOptions;
}

export function todayDailyId(): string {
  return new Date().toISOString().slice(0, 10);
}

export function createAppState(): AppState {
  return {
    puzzle: createInitialState(),
    seed: 12345,
    moveCount: 0,
    elapsedMs: 0,
    timerRunning: true,
    timerStartedAt: Date.now(),
    streak: 0,
    lastDailyId: null,
    completedDailyIds: [],
    mode: 'daily',
    undoStack: [],
    redoStack: [],
    hintText: '',
    tutorialCompleted: false,
    showTutorial: true,
    accessibility: { highContrast: false, largerText: false, reducedMotion: false, soundEnabled: true }
  };
}
