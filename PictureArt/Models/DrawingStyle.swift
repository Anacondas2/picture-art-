import Foundation

enum DrawingStyle: String, Codable, CaseIterable, Hashable {
    case none
    case gouache
    case watercolor
    case oilPaint
    case acrylic
    case pencilSketch
    case coloredPencil
    case charcoal
    case pastel
    case ink

    var stabilityPrompt: String {
        switch self {
        case .none:          return ""
        case .gouache:       return "gouache painting, flat opaque matte colors, bold shapes, illustration, children book art style"
        case .watercolor:    return "watercolor painting, transparent washes, soft wet edges, blooming pigment, luminous white paper showing through"
        case .oilPaint:      return "oil painting, thick impasto texture, rich saturated colors, visible brushstrokes, classical realism"
        case .acrylic:       return "acrylic painting, vibrant colors, smooth or textured brushwork, modern art style"
        case .pencilSketch:  return "graphite pencil sketch, black and white only, detailed crosshatching and hatching, no color fills"
        case .coloredPencil: return "colored pencil drawing, fine detailed linework, layered color strokes, waxy texture, illustration"
        case .charcoal:      return "charcoal drawing, deep blacks and soft grays, smudged shadows, dramatic contrast, expressive marks"
        case .pastel:        return "soft pastel drawing, chalky powdery texture, blended colors, impressionist style, muted tones"
        case .ink:           return "ink drawing, bold black outlines, brush pen or liner, high contrast, graphic novel style"
        }
    }

    var compatibleMediums: [DrawingMedium] {
        switch self {
        case .none:          return DrawingMedium.allCases
        case .gouache:       return [.brush, .dryBrush]
        case .watercolor:    return [.brush, .dryBrush]
        case .oilPaint:      return [.brush, .dryBrush]
        case .acrylic:       return [.brush, .dryBrush, .marker]
        case .pencilSketch:  return [.pencil, .coloredPencil]
        case .coloredPencil: return [.coloredPencil, .pencil]
        case .charcoal:      return [.chalk, .pencil]
        case .pastel:        return [.chalk, .coloredPencil]
        case .ink:           return [.marker, .brush]
        }
    }

    func displayName(lang: String) -> String {
        switch lang {
        case "ru":
            switch self {
            case .none:          return "Без стиля"
            case .gouache:       return "Гуашь"
            case .watercolor:    return "Акварель"
            case .oilPaint:      return "Масло"
            case .acrylic:       return "Акрил"
            case .pencilSketch:  return "Карандаш"
            case .coloredPencil: return "Цветной карандаш"
            case .charcoal:      return "Уголь"
            case .pastel:        return "Пастель"
            case .ink:           return "Тушь"
            }
        default:
            switch self {
            case .none:          return "No Style"
            case .gouache:       return "Gouache"
            case .watercolor:    return "Watercolor"
            case .oilPaint:      return "Oil Paint"
            case .acrylic:       return "Acrylic"
            case .pencilSketch:  return "Pencil Sketch"
            case .coloredPencil: return "Colored Pencil"
            case .charcoal:      return "Charcoal"
            case .pastel:        return "Pastel"
            case .ink:           return "Ink"
            }
        }
    }

    var icon: String {
        switch self {
        case .none:          return "photo"
        case .gouache:       return "paintbrush.fill"
        case .watercolor:    return "drop.fill"
        case .oilPaint:      return "paintpalette.fill"
        case .acrylic:       return "paintbrush.pointed.fill"
        case .pencilSketch:  return "pencil"
        case .coloredPencil: return "pencil.tip"
        case .charcoal:      return "pencil.and.scribble"
        case .pastel:        return "square.fill"
        case .ink:           return "signature"
        }
    }
}
