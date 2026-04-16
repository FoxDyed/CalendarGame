# CalendarGame

## Playable daily prototype (fixed date)

This repository now includes a single integrated gameplay prototype scene for one deterministic date:

- **Fixed daily test date:** `2026-01-15`
- The gameplay scene marks month/date/weekday target cells for that date as protected.
- The piece tray is populated with the canonical piece set.
- Existing drag + rotate (`R`) + flip (`F`) + preview + snap/reject placement flow is enabled.

### Run the prototype scene

1. Open the project in Godot 4.5+.
2. Open and run `res://scenes/gameplay/main_gameplay_scene.tscn`.
3. Drag pieces from the right tray to the board.
4. While dragging a selected piece, press `R` to rotate and `F` to flip (if allowed for that piece).
5. Drop on a valid board location to commit and snap, or drop on an invalid location to see rejection + restore.

### Run tests

```bash
godot --headless --path . -s res://tests/run_tests.gd
```
