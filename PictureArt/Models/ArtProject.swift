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
    var paperSize: PaperSize
    var skillLevel: SkillLevel

    init(
        name: String,
        style: DrawingStyle,
        medium: DrawingMedium,
        gridRows: Int,
        gridCols: Int,
        paperSize: PaperSize = .a4,
        skillLevel: SkillLevel = .intermediate
    ) {
        self.id = UUID()
        self.name = name
        self.createdAt = Date()
        self.style = style
        self.medium = medium
        self.gridRows = gridRows
        self.gridCols = gridCols
        self.paperSize = paperSize
        self.skillLevel = skillLevel
        self.squares = (0..<gridRows).flatMap { row in
            (0..<gridCols).map { col in GridSquare(row: row, col: col) }
        }
    }

    // Custom decoding for backward compatibility with projects saved without paperSize/skillLevel
    enum CodingKeys: String, CodingKey {
        case id, name, createdAt, style, medium, gridRows, gridCols, squares, paperSize, skillLevel
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decode(UUID.self, forKey: .id)
        name = try c.decode(String.self, forKey: .name)
        createdAt = try c.decode(Date.self, forKey: .createdAt)
        style = try c.decode(DrawingStyle.self, forKey: .style)
        medium = try c.decode(DrawingMedium.self, forKey: .medium)
        gridRows = try c.decode(Int.self, forKey: .gridRows)
        gridCols = try c.decode(Int.self, forKey: .gridCols)
        squares = try c.decode([GridSquare].self, forKey: .squares)
        paperSize = try c.decodeIfPresent(PaperSize.self, forKey: .paperSize) ?? .a4
        skillLevel = try c.decodeIfPresent(SkillLevel.self, forKey: .skillLevel) ?? .intermediate
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

    mutating func toggleCompleted(row: Int, col: Int) {
        if let idx = squares.firstIndex(where: { $0.row == row && $0.col == col }) {
            squares[idx].isCompleted.toggle()
        }
    }

    func squareIndex(row: Int, col: Int) -> Int {
        row * gridCols + col
    }
}
