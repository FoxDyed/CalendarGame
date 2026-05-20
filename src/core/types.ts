export interface Cell {
  x: number;
  y: number;
}

export interface CalendarCell extends Cell {
  id: string;
  label: string;
  kind: 'month' | 'day' | 'blocked';
}

export interface Piece {
  id: string;
  name: string;
  color: string;
  cells: Cell[];
  rotation: number;
  flipped: boolean;
  x: number | null;
  y: number | null;
}

export interface PuzzleState {
  width: number;
  height: number;
  pieces: Piece[];
  monthIndex: number;
  day: number;
  selectedPieceId: string | null;
}

export interface Move {
  pieceId: string;
  from: Cell | null;
  to: Cell | null;
  rotation: number;
  flipped: boolean;
}

export interface VisibilityWindow {
  monthCell: Cell;
  dayCell: Cell;
  month: string;
  day: number;
}
