import Foundation

enum DrawingStyle: String, Codable, CaseIterable, Hashable {
    case none
    case gouache
    case watercolor
    case oilPaint
    case pencilSketch
    case charcoal
    case pastel

    var stabilityPrompt: String {
        switch self {
        case .none:         return ""
        case .gouache:      return "gouache painting, thick opaque paint, matte flat colors, illustration style, vibrant"
        case .watercolor:   return "watercolor painting, transparent washes, soft edges, flowing colors, wet on wet technique"
        case .oilPaint:     return "oil painting, thick impasto brushstrokes, rich vivid colors, textured canvas, renaissance style"
        case .pencilSketch: return "pencil sketch, black and white, crosshatching, graphite drawing, detailed linework, no color"
        case .charcoal:     return "charcoal drawing, dramatic shadows, smudged texture, black and white, expressive marks"
        case .pastel:       return "pastel drawing, soft chalky colors, blended strokes, gentle texture, impressionist"
        }
    }

    func displayName(lang: String) -> String {
        switch lang {
        case "ru":
            switch self {
            case .none:         return "Без стиля"
            case .gouache:      return "Гуашь"
            case .watercolor:   return "Акварель"
            case .oilPaint:     return "Масло"
            case .pencilSketch: return "Карандаш"
            case .charcoal:     return "Уголь"
            case .pastel:       return "Пастель"
            }
        default:
            switch self {
            case .none:         return "No Style"
            case .gouache:      return "Gouache"
            case .watercolor:   return "Watercolor"
            case .oilPaint:     return "Oil Paint"
            case .pencilSketch: return "Pencil Sketch"
            case .charcoal:     return "Charcoal"
            case .pastel:       return "Pastel"
            }
        }
    }

    var icon: String {
        switch self {
        case .none:         return "photo"
        case .gouache:      return "paintbrush.fill"
        case .watercolor:   return "drop.fill"
        case .oilPaint:     return "paintpalette.fill"
        case .pencilSketch: return "pencil"
        case .charcoal:     return "pencil.and.scribble"
        case .pastel:       return "square.fill"
        }
    }
}
