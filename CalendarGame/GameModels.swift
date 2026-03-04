import Foundation
import SwiftUI

struct GridPoint: Hashable {
    let row: Int
    let col: Int

    static func + (lhs: GridPoint, rhs: GridPoint) -> GridPoint {
        GridPoint(row: lhs.row + rhs.row, col: lhs.col + rhs.col)
    }
}

struct PieceDefinition: Identifiable {
    let id: String
    let name: String
    let color: Color
    let cells: [GridPoint]
}

struct PieceState: Identifiable {
    let id: String
    let definition: PieceDefinition
    var rotation: Int = 0
    var flipped: Bool = false
    var placedOrigin: GridPoint?

    var transformedCells: [GridPoint] {
        let base = flipped
            ? definition.cells.map { GridPoint(row: $0.row, col: -$0.col) }
            : definition.cells
        let rotated = base.map { cell in
            switch rotation % 4 {
            case 1:
                return GridPoint(row: -cell.col, col: cell.row)
            case 2:
                return GridPoint(row: -cell.row, col: -cell.col)
            case 3:
                return GridPoint(row: cell.col, col: -cell.row)
            default:
                return cell
            }
        }
        let minRow = rotated.map(\.row).min() ?? 0
        let minCol = rotated.map(\.col).min() ?? 0
        return rotated.map { GridPoint(row: $0.row - minRow, col: $0.col - minCol) }
    }

    var footprintSize: (rows: Int, cols: Int) {
        let cells = transformedCells
        let maxRow = cells.map(\.row).max() ?? 0
        let maxCol = cells.map(\.col).max() ?? 0
        return (rows: maxRow + 1, cols: maxCol + 1)
    }
}

enum CalendarMonth: String, CaseIterable, Identifiable {
    case jan = "Jan", feb = "Feb", mar = "Mar", apr = "Apr", may = "May", jun = "Jun"
    case jul = "Jul", aug = "Aug", sep = "Sep", oct = "Oct", nov = "Nov", dec = "Dec"

    var id: String { rawValue }
}

struct CellLabel {
    let month: CalendarMonth?
    let day: Int?
}

struct BoardLayout {
    static let rows = 7
    static let cols = 7

    static let validCells: Set<GridPoint> = {
        var cells = Set<GridPoint>()
        for row in 0..<2 {
            for col in 0..<6 {
                cells.insert(GridPoint(row: row, col: col))
            }
        }
        var day = 1
        for row in 2..<7 {
            for col in 0..<7 where day <= 31 {
                cells.insert(GridPoint(row: row, col: col))
                day += 1
            }
        }
        return cells
    }()

    static let labels: [GridPoint: CellLabel] = {
        var map: [GridPoint: CellLabel] = [:]
        for (index, month) in CalendarMonth.allCases.enumerated() {
            let row = index / 6
            let col = index % 6
            map[GridPoint(row: row, col: col)] = CellLabel(month: month, day: nil)
        }

        var day = 1
        for row in 2..<7 {
            for col in 0..<7 where day <= 31 {
                map[GridPoint(row: row, col: col)] = CellLabel(month: nil, day: day)
                day += 1
            }
        }
        return map
    }()

    static let pieceDefinitions: [PieceDefinition] = [
        PieceDefinition(id: "P1", name: "Long L", color: .red, cells: [
            GridPoint(row: 0, col: 0), GridPoint(row: 1, col: 0), GridPoint(row: 2, col: 0),
            GridPoint(row: 3, col: 0), GridPoint(row: 3, col: 1)
        ]),
        PieceDefinition(id: "P2", name: "T", color: .orange, cells: [
            GridPoint(row: 0, col: 0), GridPoint(row: 0, col: 1), GridPoint(row: 0, col: 2),
            GridPoint(row: 1, col: 1), GridPoint(row: 2, col: 1)
        ]),
        PieceDefinition(id: "P3", name: "Box", color: .yellow, cells: [
            GridPoint(row: 0, col: 0), GridPoint(row: 0, col: 1),
            GridPoint(row: 1, col: 0), GridPoint(row: 1, col: 1),
            GridPoint(row: 2, col: 0)
        ]),
        PieceDefinition(id: "P4", name: "Snake", color: .green, cells: [
            GridPoint(row: 0, col: 1), GridPoint(row: 0, col: 2),
            GridPoint(row: 1, col: 0), GridPoint(row: 1, col: 1), GridPoint(row: 1, col: 2)
        ]),
        PieceDefinition(id: "P5", name: "Corner", color: .mint, cells: [
            GridPoint(row: 0, col: 0), GridPoint(row: 1, col: 0), GridPoint(row: 2, col: 0),
            GridPoint(row: 2, col: 1), GridPoint(row: 2, col: 2)
        ]),
        PieceDefinition(id: "P6", name: "Hook", color: .cyan, cells: [
            GridPoint(row: 0, col: 0), GridPoint(row: 1, col: 0),
            GridPoint(row: 1, col: 1), GridPoint(row: 1, col: 2)
        ]),
        PieceDefinition(id: "P7", name: "Wide L", color: .blue, cells: [
            GridPoint(row: 0, col: 0), GridPoint(row: 1, col: 0),
            GridPoint(row: 2, col: 0), GridPoint(row: 2, col: 1),
            GridPoint(row: 2, col: 2), GridPoint(row: 2, col: 3)
        ]),
        PieceDefinition(id: "P8", name: "Cross", color: .purple, cells: [
            GridPoint(row: 0, col: 1), GridPoint(row: 1, col: 0), GridPoint(row: 1, col: 1),
            GridPoint(row: 1, col: 2), GridPoint(row: 2, col: 1), GridPoint(row: 3, col: 1)
        ])
    ]
}
