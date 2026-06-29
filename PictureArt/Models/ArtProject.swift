import Foundation

struct ArtProject: Codable, Identifiable, Hashable {
    let id: UUID
    var name: String
    var createdAt: Date
    var style: DrawingStyle
    var medium: DrawingMedium
    var gridRows: Int
    var gridCols: Int
    var squares: [GridSquare]

    init(name: String, style: DrawingStyle, medium: DrawingMedium, gridRows: Int, gridCols: Int) {
        self.id = UUID()
        self.name = name
        self.createdAt = Date()
        self.style = style
        self.medium = medium
        self.gridRows = gridRows
        self.gridCols = gridCols
        self.squares = (0..<gridRows).flatMap { row in
            (0..<gridCols).map { col in GridSquare(row: row, col: col) }
        }
    }

    var completedCount: Int { squares.filter { $0.isCompleted }.count }
    var totalCount: Int { squares.count }
    var progress: Double { totalCount > 0 ? Double(completedCount) / Double(totalCount) : 0 }

    var firstUncompletedIndex: Int? {
        squares.firstIndex { !$0.isCompleted }
    }

    mutating func markCompleted(row: Int, col: Int) {
        if let idx = squares.firstIndex(where: { $0.row == row && $0.col == col }) {
            squares[idx].isCompleted = true
        }
    }

    mutating func markUncompleted(row: Int, col: Int) {
        if let idx = squares.firstIndex(where: { $0.row == row && $0.col == col }) {
            squares[idx].isCompleted = false
        }
    }

    func squareIndex(row: Int, col: Int) -> Int {
        row * gridCols + col
    }
}
