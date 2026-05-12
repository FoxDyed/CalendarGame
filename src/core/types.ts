export type Axis = 'x' | 'y';

export interface Cell {
  x: number;
  y: number;
}

export interface Piece {
  id: string;
  axis: Axis;
  length: number;
  x: number;
  y: number;
  min: number;
  max: number;
}

export interface PuzzleState {
  width: number;
  height: number;
  pieces: Piece[];
  monthIndex: number;
  day: number;
}

export interface Move {
  pieceId: string;
  delta: number;
}

export interface VisibilityWindow {
  monthCell: Cell;
  dayCell: Cell;
  month: string;
  day: number;
}
