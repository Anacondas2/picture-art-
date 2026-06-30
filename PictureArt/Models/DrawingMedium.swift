import Foundation

enum DrawingMedium: String, Codable, CaseIterable, Hashable {
    case brush
    case dryBrush
    case pencil
    case coloredPencil
    case marker
    case chalk

    func displayName(lang: String) -> String {
        switch lang {
        case "ru":
            switch self {
            case .brush:         return "Кисть"
            case .dryBrush:      return "Сухая кисть"
            case .pencil:        return "Карандаш"
            case .coloredPencil: return "Цветной карандаш"
            case .marker:        return "Маркер"
            case .chalk:         return "Мел / Уголь"
            }
        default:
            switch self {
            case .brush:         return "Brush"
            case .dryBrush:      return "Dry Brush"
            case .pencil:        return "Pencil"
            case .coloredPencil: return "Colored Pencil"
            case .marker:        return "Marker"
            case .chalk:         return "Chalk / Charcoal"
            }
        }
    }

    var icon: String {
        switch self {
        case .brush:         return "paintbrush"
        case .dryBrush:      return "paintbrush.pointed"
        case .pencil:        return "pencil"
        case .coloredPencil: return "pencil.tip"
        case .marker:        return "highlighter"
        case .chalk:         return "scribble"
        }
    }
}
