import Foundation

struct GridSquare: Codable, Identifiable, Hashable {
    let row: Int
    let col: Int
    var isCompleted: Bool

    var id: String { "\(row)_\(col)" }

    init(row: Int, col: Int) {
        self.row = row
        self.col = col
        self.isCompleted = false
    }
}
