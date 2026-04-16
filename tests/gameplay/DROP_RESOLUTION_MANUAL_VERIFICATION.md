# Drop Resolution Manual Verification

1. Run the gameplay scene and drag any tray piece so its origin is over playable board cells.
2. Release while the board preview is yellow (valid).
3. Confirm the piece snaps to grid and the occupied board cells remain orange.
4. Pick that same placed piece up again.
5. Confirm its previous orange occupied cells clear immediately while dragging.
6. Move the piece to an invalid location (off board, onto missing cells, overlapping occupied cells, or over protected targets if configured) and release.
7. Confirm the drop is rejected and the piece returns to its prior position; prior occupied cells are restored.
8. Move the piece to a new valid location and release.
9. Confirm old occupancy does not linger and only the new covered cells are occupied.
