# Piece Local Offsets

Each puzzle piece is defined as a list of local tile offsets using `Vector2i(x, y)` values.

- Offsets are relative to a piece-local origin, not board coordinates.
- Positive `x` moves right; positive `y` moves down.
- `PieceSet.normalize_tiles()` shifts a tile list so its minimum `x` and minimum `y` become `0`.
- Normalized tiles are sorted in deterministic row-major order (`y`, then `x`) to keep data comparisons stable in tests.
