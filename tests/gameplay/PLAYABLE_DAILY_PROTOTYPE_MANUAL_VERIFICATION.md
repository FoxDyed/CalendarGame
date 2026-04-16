# Playable Daily Prototype Manual Verification

## Scope

This verifies one integrated gameplay session for a single fixed date in `main_gameplay_scene`.

- Fixed date: `2026-01-15`
- Targets expected: month/date/weekday for that date

## Steps

1. Run `res://scenes/gameplay/main_gameplay_scene.tscn` in Godot.
2. Confirm the status text includes the fixed date (`2026-01-15`).
3. Confirm exactly 3 protected board cells are highlighted for month/date/weekday.
4. Confirm tray contains all canonical pieces.
5. Drag any piece over the board and confirm preview appears.
6. Press `R` while dragging a rotatable piece and confirm orientation changes.
7. Press `F` while dragging a flippable piece and confirm mirrored orientation.
8. Drop on a valid location and confirm snap + occupied cells are rendered.
9. Drag the placed piece to an invalid location and release; confirm it restores to previous valid placement.
10. Click **Reset Layout** and confirm pieces return to tray spawn positions and board occupancy clears (protected cells remain).

## Expected result

The scene supports a coherent manual interaction loop (drag, transform, preview, valid commit, invalid rejection) for the fixed daily puzzle targets without completion detection or date progression.
