# CalendarGame

An iPhone SwiftUI game inspired by the **Puzzle-a-Day Calendar** concept.

## Gameplay
- Choose a month and day.
- Those two cells become blocked (the "date window").
- Place all polyomino pieces so every other calendar cell is covered.
- You win when the board is fully covered except the selected month/day cells.

## Project files
- `CalendarGame/CalendarPuzzleApp.swift`: App entry point.
- `CalendarGame/ContentView.swift`: Main game interface.
- `CalendarGame/GameViewModel.swift`: Placement rules and win checks.
- `CalendarGame/GameModels.swift`: Board, labels, and puzzle pieces.

## Running
Open this folder in Xcode as an iOS app project and run on an iPhone simulator/device.
