export type Axis = 'x' | 'y';

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
