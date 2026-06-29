import Foundation

enum PaperSize: String, Codable, CaseIterable {
    case a5
    case a4
    case a3
    case a2
    case letter
    case tabloid
    case canvas20
    case canvas30
    case canvas40
    case canvas50
    case canvas30x40
    case canvas40x60

    var widthMM: Double {
        switch self {
        case .a5:        return 148
        case .a4:        return 210
        case .a3:        return 297
        case .a2:        return 420
        case .letter:    return 216
        case .tabloid:   return 279
        case .canvas20:  return 200
        case .canvas30:  return 300
        case .canvas40:  return 400
        case .canvas50:  return 500
        case .canvas30x40: return 300
        case .canvas40x60: return 400
        }
    }

    var heightMM: Double {
        switch self {
        case .a5:        return 210
        case .a4:        return 297
        case .a3:        return 420
        case .a2:        return 594
        case .letter:    return 279
        case .tabloid:   return 432
        case .canvas20:  return 200
        case .canvas30:  return 300
        case .canvas40:  return 400
        case .canvas50:  return 500
        case .canvas30x40: return 400
        case .canvas40x60: return 600
        }
    }

    func cellSize(rows: Int, cols: Int) -> (widthMM: Double, heightMM: Double) {
        (widthMM / Double(cols), heightMM / Double(rows))
    }

    var recommendedGridSizes: [Int] {
        let minDimension = min(widthMM, heightMM)
        switch minDimension {
        case ..<180:   return [6, 8]
        case 180..<260: return [8, 12]
        case 260..<350: return [12, 16]
        case 350..<450: return [16, 20]
        default:        return [20, 24, 32]
        }
    }

    var defaultGridSize: Int { recommendedGridSizes.first ?? 12 }

    func cellSizeComment(rows: Int, cols: Int, lang: String) -> String {
        let size = cellSize(rows: rows, cols: cols)
        let wStr = String(format: "%.1f", size.widthMM)
        let hStr = String(format: "%.1f", size.heightMM)
        if lang == "ru" {
            return "Каждый квадратик: \(wStr)×\(hStr) мм"
        } else {
            return "Each square: \(wStr)×\(hStr) mm"
        }
    }

    func difficulty(rows: Int, cols: Int) -> CellDifficulty {
        let size = cellSize(rows: rows, cols: cols)
        let minSide = min(size.widthMM, size.heightMM)
        switch minSide {
        case 20...: return .easy
        case 12..<20: return .medium
        default:    return .hard
        }
    }

    func displayName(lang: String) -> String {
        switch lang {
        case "ru":
            switch self {
            case .a5:        return "A5 (148×210 мм)"
            case .a4:        return "A4 (210×297 мм)"
            case .a3:        return "A3 (297×420 мм)"
            case .a2:        return "A2 (420×594 мм)"
            case .letter:    return "Letter (216×279 мм)"
            case .tabloid:   return "Tabloid (279×432 мм)"
            case .canvas20:  return "Холст 20×20 см"
            case .canvas30:  return "Холст 30×30 см"
            case .canvas40:  return "Холст 40×40 см"
            case .canvas50:  return "Холст 50×50 см"
            case .canvas30x40: return "Холст 30×40 см"
            case .canvas40x60: return "Холст 40×60 см"
            }
        default:
            switch self {
            case .a5:        return "A5 (148×210 mm)"
            case .a4:        return "A4 (210×297 mm)"
            case .a3:        return "A3 (297×420 mm)"
            case .a2:        return "A2 (420×594 mm)"
            case .letter:    return "Letter (216×279 mm)"
            case .tabloid:   return "Tabloid (279×432 mm)"
            case .canvas20:  return "Canvas 20×20 cm"
            case .canvas30:  return "Canvas 30×30 cm"
            case .canvas40:  return "Canvas 40×40 cm"
            case .canvas50:  return "Canvas 50×50 cm"
            case .canvas30x40: return "Canvas 30×40 cm"
            case .canvas40x60: return "Canvas 40×60 cm"
            }
        }
    }

    var icon: String {
        switch self {
        case .a5, .a4, .a3, .a2, .letter, .tabloid: return "doc.fill"
        default: return "rectangle.fill"
        }
    }

    enum CellDifficulty {
        case easy, medium, hard

        func label(lang: String) -> String {
            switch lang {
            case "ru":
                switch self {
                case .easy:   return "Комфортно"
                case .medium: return "Нормально"
                case .hard:   return "Мелко"
                }
            default:
                switch self {
                case .easy:   return "Comfortable"
                case .medium: return "Moderate"
                case .hard:   return "Fine detail"
                }
            }
        }

        var color: String {
            switch self {
            case .easy:   return "green"
            case .medium: return "orange"
            case .hard:   return "red"
            }
        }
    }
}
