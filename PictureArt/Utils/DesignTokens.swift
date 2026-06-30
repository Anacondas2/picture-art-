import SwiftUI

extension Color {
    // Background system — Ink Blue / Deep Ocean
    static let bgDeep    = Color(red: 0.039, green: 0.055, blue: 0.102)  // #0A0E1A
    static let bgMid     = Color(red: 0.059, green: 0.102, blue: 0.180)  // #0F1A2E
    static let bgSurface = Color(red: 0.090, green: 0.130, blue: 0.220)  // #17213A

    // Glass surfaces
    static let glassLight  = Color.white.opacity(0.07)
    static let glassMedium = Color.white.opacity(0.12)
    static let glassBorder = Color.white.opacity(0.18)

    // Accent: Blue → Indigo
    static let brand      = Color(red: 0.388, green: 0.400, blue: 0.945)  // #6366F1
    static let brandLight = Color(red: 0.565, green: 0.573, blue: 0.973)  // #9091F8
    static let accentBlue = Color(red: 0.231, green: 0.506, blue: 0.965)  // #3B82F6

    // Neumorphic shadows for dark surface
    static let neuLight = Color.white.opacity(0.07)
    static let neuDark  = Color(red: 0.020, green: 0.035, blue: 0.075).opacity(0.85)

    // Text
    static let labelPrimary   = Color.white
    static let labelSecondary = Color.white.opacity(0.55)
    static let labelTertiary  = Color.white.opacity(0.30)

    // Legacy aliases for backward compatibility
    static let inkSurface       = bgDeep
    static let surfaceSecondary = bgSurface
}

extension LinearGradient {
    static let appBg = LinearGradient(
        colors: [.bgDeep, .bgMid],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    static let brandGradient = LinearGradient(
        colors: [.accentBlue, .brand],
        startPoint: .leading,
        endPoint: .trailing
    )
}

extension View {
    func glassCard(radius: CGFloat = 20) -> some View {
        self
            .background(Color.glassLight)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: radius))
            .overlay(
                RoundedRectangle(cornerRadius: radius)
                    .stroke(Color.glassBorder, lineWidth: 0.5)
            )
    }

    func neuSurface(radius: CGFloat = 16) -> some View {
        self
            .background(Color.bgSurface)
            .clipShape(RoundedRectangle(cornerRadius: radius))
            .shadow(color: .neuLight, radius: 8, x: -4, y: -4)
            .shadow(color: .neuDark,  radius: 8, x:  4, y:  4)
    }

    func brandGlow(radius: CGFloat = 16) -> some View {
        self.shadow(color: Color.brand.opacity(0.45), radius: radius, x: 0, y: 6)
    }

    func darkPageBackground() -> some View {
        self.background(LinearGradient.appBg.ignoresSafeArea())
    }
}

struct GlassCTAStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .background(LinearGradient.brandGradient)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .shadow(color: .brand.opacity(configuration.isPressed ? 0.2 : 0.45), radius: 16, x: 0, y: 6)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}

struct GlassSecondaryStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(Color.glassLight)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.glassBorder, lineWidth: 0.5)
            )
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }
}

// MARK: - Style accent colors (view-layer, not model)
extension DrawingStyle {
    var accentColor: Color {
        switch self {
        case .none:          return .labelTertiary
        case .gouache:       return Color(red: 0.94, green: 0.45, blue: 0.68)  // rose
        case .watercolor:    return Color(red: 0.22, green: 0.74, blue: 0.95)  // sky blue
        case .oilPaint:      return Color(red: 0.66, green: 0.47, blue: 0.95)  // violet
        case .acrylic:       return Color(red: 0.20, green: 0.83, blue: 0.60)  // emerald
        case .pencilSketch:  return Color(red: 0.72, green: 0.78, blue: 0.86)  // steel blue
        case .coloredPencil: return Color.brand                                  // indigo
        case .charcoal:      return Color(red: 0.78, green: 0.80, blue: 0.85)  // light slate
        case .pastel:        return Color(red: 0.97, green: 0.63, blue: 0.86)  // soft pink
        case .ink:           return Color(red: 0.93, green: 0.93, blue: 0.97)  // near-white
        }
    }
}
