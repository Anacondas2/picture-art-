import Foundation

enum SkillLevel: String, Codable, CaseIterable {
    case beginner
    case intermediate
    case advanced

    var recommendedGridSizes: [Int] {
        switch self {
        case .beginner:     return [8, 12]
        case .intermediate: return [12, 16, 20]
        case .advanced:     return [16, 20, 24, 32]
        }
    }

    var defaultGridSize: Int {
        switch self {
        case .beginner:     return 8
        case .intermediate: return 16
        case .advanced:     return 20
        }
    }

    var colorCount: Int {
        switch self {
        case .beginner:     return 4
        case .intermediate: return 6
        case .advanced:     return 8
        }
    }

    var allowedStyles: [DrawingStyle] {
        switch self {
        case .beginner:
            return [.none, .pencilSketch, .coloredPencil]
        case .intermediate:
            return [.none, .gouache, .watercolor, .pencilSketch, .coloredPencil, .charcoal, .pastel]
        case .advanced:
            return DrawingStyle.allCases
        }
    }

    func displayName(lang: String) -> String {
        switch lang {
        case "ru":
            switch self {
            case .beginner:     return "Начинающий"
            case .intermediate: return "Средний"
            case .advanced:     return "Продвинутый"
            }
        default:
            switch self {
            case .beginner:     return "Beginner"
            case .intermediate: return "Intermediate"
            case .advanced:     return "Advanced"
            }
        }
    }

    func description(lang: String) -> String {
        switch lang {
        case "ru":
            switch self {
            case .beginner:     return "Первые шаги в рисовании"
            case .intermediate: return "Уже рисую, хочу развиваться"
            case .advanced:     return "Опытный художник"
            }
        default:
            switch self {
            case .beginner:     return "First steps in drawing"
            case .intermediate: return "Improving my skills"
            case .advanced:     return "Experienced artist"
            }
        }
    }

    var icon: String {
        switch self {
        case .beginner:     return "1.circle.fill"
        case .intermediate: return "2.circle.fill"
        case .advanced:     return "3.circle.fill"
        }
    }
}
