# Piece scene manual verification

1. Instantiate `res://scenes/pieces/piece_scene.tscn` in a temporary scene and call `initialize_from_piece_data()` with one piece dictionary from `PieceSet.list_all_pieces()`.
2. Click and hold the piece, then move the cursor; the piece should follow in free space until release.
3. Press `R` while the piece is selected; tile layout should rotate through that piece's allowed rotations.
4. Press `F`; only pieces with `allow_mirror = true` should visually flip.
5. Confirm no board snap or placement validation occurs when drag ends.
