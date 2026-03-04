import SwiftUI

struct ContentView: View {
    @EnvironmentObject var vm: GameViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    headerControls
                    board
                    pieceTray
                    pieceControls
                    Text(vm.message)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding()
            }
            .navigationTitle("Calendar Puzzle")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Reset") { vm.resetBoard() }
                }
            }
        }
    }

    private var headerControls: some View {
        VStack(spacing: 12) {
            Picker("Month", selection: $vm.selectedMonth) {
                ForEach(CalendarMonth.allCases) { month in
                    Text(month.rawValue).tag(month)
                }
            }
            .pickerStyle(.segmented)

            Picker("Day", selection: $vm.selectedDay) {
                ForEach(1...31, id: \.self) { day in
                    Text("\(day)").tag(day)
                }
            }
        }
    }

    private var board: some View {
        let columns = Array(repeating: GridItem(.flexible(minimum: 30, maximum: 48), spacing: 4), count: BoardLayout.cols)

        return LazyVGrid(columns: columns, spacing: 4) {
            ForEach(0..<BoardLayout.rows, id: \.self) { row in
                ForEach(0..<BoardLayout.cols, id: \.self) { col in
                    let point = GridPoint(row: row, col: col)
                    boardCell(point: point)
                        .onTapGesture { vm.tapCell(point) }
                }
            }
        }
        .padding(8)
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    @ViewBuilder
    private func boardCell(point: GridPoint) -> some View {
        if !BoardLayout.validCells.contains(point) {
            RoundedRectangle(cornerRadius: 6)
                .fill(Color.clear)
                .frame(height: 42)
        } else {
            let label = BoardLayout.labels[point]
            let pieceId = vm.occupiedCells[point]
            let isHole = vm.holeCells.contains(point)
            let color = pieceColor(for: pieceId)

            ZStack {
                RoundedRectangle(cornerRadius: 6)
                    .fill(isHole ? Color.black.opacity(0.75) : color.opacity(pieceId == nil ? 0.2 : 0.9))
                if let label {
                    Text(labelText(label))
                        .font(.caption2)
                        .foregroundStyle(isHole ? .white : .primary)
                        .bold()
                }
            }
            .frame(height: 42)
        }
    }

    private var pieceTray: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Pieces")
                .font(.headline)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(vm.pieces) { piece in
                        Button {
                            vm.selectPiece(piece.id)
                        } label: {
                            VStack(spacing: 6) {
                                Text(piece.id)
                                    .font(.caption)
                                Text(piece.definition.name)
                                    .font(.caption2)
                            }
                            .padding(10)
                            .background(piece.definition.color.opacity(vm.selectedPieceId == piece.id ? 0.8 : 0.35))
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            .overlay {
                                if piece.placedOrigin != nil {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundStyle(.white)
                                        .offset(x: 18, y: -18)
                                }
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    private var pieceControls: some View {
        HStack {
            Button("Rotate") { vm.rotateSelectedPiece() }
                .buttonStyle(.bordered)
            Button("Flip") { vm.flipSelectedPiece() }
                .buttonStyle(.bordered)
            Spacer()
            if vm.isWin {
                Text("🎉 Solved")
                    .bold()
            }
        }
    }

    private func pieceColor(for pieceId: String?) -> Color {
        guard let pieceId,
              let piece = vm.pieces.first(where: { $0.id == pieceId }) else {
            return Color.gray
        }
        return piece.definition.color
    }

    private func labelText(_ label: CellLabel) -> String {
        if let month = label.month {
            return month.rawValue
        }
        if let day = label.day {
            return "\(day)"
        }
        return ""
    }
}

#Preview {
    ContentView()
        .environmentObject(GameViewModel())
}
