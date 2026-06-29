import Foundation

enum DrawingMedium: String, Codable, CaseIterable, Hashable {
    case brush
    case dryBrush
    case pencil
    case marker
    case chalk

    func displayName(lang: String) -> String {
        switch lang {
        case "ru":
            switch self {
            case .brush:    return "Кисть"
            case .dryBrush: return "Сухая кисть"
            case .pencil:   return "Карандаш"
            case .marker:   return "Маркер"
            case .chalk:    return "Мел"
            }
        default:
            switch self {
            case .brush:    return "Brush"
            case .dryBrush: return "Dry Brush"
            case .pencil:   return "Pencil"
            case .marker:   return "Marker"
            case .chalk:    return "Chalk"
            }
        }
    }

    var icon: String {
        switch self {
        case .brush:    return "paintbrush"
        case .dryBrush: return "paintbrush.pointed"
        case .pencil:   return "pencil"
        case .marker:   return "highlighter"
        case .chalk:    return "scribble"
        }
    }
}
