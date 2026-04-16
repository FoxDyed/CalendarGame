# Board Coordinate Convention

The calendar board is represented as a fixed **7x8** grid.

- Coordinates use `Vector2i(column, row)`.
- `(0, 0)` is the top-left cell.
- Columns increase to the right.
- Rows increase downward.

Cell categories:
- `MONTH`: Jan-Dec
- `DATE`: 1-31
- `WEEKDAY`: Sun-Sat
- `MISSING`: non-playable cells used to preserve the board shape

The canonical board definition lives in `res://model/board/board_model.gd`.
