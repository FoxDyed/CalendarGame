# Board Snap Preview Manual Verification

1. Launch `scenes/gameplay/main_gameplay_scene.tscn` in the editor/runtime.
2. Drag any piece from the tray so its top-left tile origin moves over the board.
3. Confirm the board highlights a yellow preview footprint that snaps to discrete grid coordinates while the piece moves.
4. Drag the same piece away from the board panel and confirm the board preview disappears immediately.
5. Release the mouse over the board and confirm no piece commit/occupancy change is applied (preview clears only).
