import Foundation

final class GameViewModel: ObservableObject {
    @Published var selectedMonth: CalendarMonth = .jan
    @Published var selectedDay: Int = 1
    @Published var pieces: [PieceState] = BoardLayout.pieceDefinitions.map { PieceState(id: $0.id, definition: $0) }
    @Published var selectedPieceId: String?
    @Published var message: String = "Select month/day, then place every piece."

    var holeCells: Set<GridPoint> {
        Set([
            BoardLayout.labels.first(where: { $0.value.month == selectedMonth })?.key,
            BoardLayout.labels.first(where: { $0.value.day == selectedDay })?.key
        ].compactMap { $0 })
    }

    var occupiedCells: [GridPoint: String] {
        var map: [GridPoint: String] = [:]
        for piece in pieces {
            guard let origin = piece.placedOrigin else { continue }
            for offset in piece.transformedCells {
                map[origin + offset] = piece.id
            }
        }
        return map
    }

    var isWin: Bool {
        let requiredCells = BoardLayout.validCells.subtracting(holeCells)
        return Set(occupiedCells.keys) == requiredCells
    }

    func resetBoard() {
        pieces = BoardLayout.pieceDefinitions.map { PieceState(id: $0.id, definition: $0) }
        selectedPieceId = nil
        message = "Board reset. Pick a piece to place."
    }

    func selectPiece(_ id: String) {
        selectedPieceId = id
    }

    func rotateSelectedPiece() {
        guard let id = selectedPieceId, let index = pieces.firstIndex(where: { $0.id == id }) else { return }
        pieces[index].rotation = (pieces[index].rotation + 1) % 4
        pieces[index].placedOrigin = nil
    }

    func flipSelectedPiece() {
        guard let id = selectedPieceId, let index = pieces.firstIndex(where: { $0.id == id }) else { return }
        pieces[index].flipped.toggle()
        pieces[index].placedOrigin = nil
    }

    func tapCell(_ point: GridPoint) {
        if let occupyingPieceId = occupiedCells[point], let index = pieces.firstIndex(where: { $0.id == occupyingPieceId }) {
            pieces[index].placedOrigin = nil
            message = "Removed \(pieces[index].definition.name)."
            return
        }

        guard let id = selectedPieceId,
              let index = pieces.firstIndex(where: { $0.id == id }) else {
            message = "Choose a piece first."
            return
        }

        placePiece(at: point, index: index)
    }

    private func placePiece(at origin: GridPoint, index: Int) {
        let piece = pieces[index]
        let prospectiveCells = piece.transformedCells.map { origin + $0 }

        for cell in prospectiveCells {
            guard BoardLayout.validCells.contains(cell) else {
                message = "That piece goes out of bounds."
                return
            }
            guard !holeCells.contains(cell) else {
                message = "Leave the selected month/day uncovered."
                return
            }
            if let occupiedBy = occupiedCells[cell], occupiedBy != piece.id {
                message = "Pieces cannot overlap."
                return
            }
        }

        pieces[index].placedOrigin = origin

        if isWin {
            message = "Solved! Nice work."
        } else {
            message = "Placed \(piece.definition.name)."
        }
    }
}
