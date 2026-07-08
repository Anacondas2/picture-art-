import SwiftUI

// ═══════════════════════════════════════════════════════════════
//  DrawGrid AI — Design System Foundation
//  "Frosted atelier": luminous cyan atmosphere, ink typography,
//  glass reserved for layers that float above the artwork.
// ═══════════════════════════════════════════════════════════════

// MARK: - Color tokens

extension Color {

    // ── Atmosphere (mist field, light-first) ──
    static let mistDeep  = Color(red: 0.310, green: 0.478, blue: 0.588)  // #4F7A96 — hero zones, large light text allowed
    static let mistHaze  = Color(red: 0.435, green: 0.639, blue: 0.769)  // #6FA3C4
    static let mistMid   = Color(red: 0.557, green: 0.769, blue: 0.910)  // #8EC4E8
    static let mistLight = Color(red: 0.706, green: 0.878, blue: 0.969)  // #B4E0F7
    static let mistIce   = Color(red: 0.875, green: 0.969, blue: 1.000)  // #DFF7FF — brand ice

    // ── Ink (reading text on glass / light surfaces) ──
    static let ink          = Color(red: 0.055, green: 0.165, blue: 0.259)   // #0E2A42
    static let inkSecondary = Color(red: 0.055, green: 0.165, blue: 0.259).opacity(0.72)
    static let inkTertiary  = Color(red: 0.055, green: 0.165, blue: 0.259).opacity(0.50)

    // ── Mist text (light text over the atmosphere, hero zones only) ──
    static let mistText      = Color.white.opacity(0.97)
    static let mistTextGhost = Color.white.opacity(0.58)
    static let mistTextSoft  = Color.white.opacity(0.78)

    // ── Functional accents (the only colors with opinions) ──
    static let progressTeal = Color(red: 0.055, green: 0.561, blue: 0.400)   // #0E8F66 — success / completion
    static let destructive  = Color(red: 0.788, green: 0.231, blue: 0.231)   // #C93B3B
    static let warning      = Color(red: 0.690, green: 0.471, blue: 0.094)   // #B07818 — rare (missing API key etc.)

    // ── Glass material ──
    static let glassFill     = Color.white.opacity(0.30)
    static let glassFillHi   = Color.white.opacity(0.44)
    static let glassSelected = Color.white.opacity(0.94)   // selection = the glass turning solid
    static let glassEdge     = Color.white.opacity(0.65)
    static let glassShine    = Color.white.opacity(0.95)
    static let glassShadow   = Color(red: 0.235, green: 0.392, blue: 0.510)  // #3C6482 — soft realistic shadow hue

    // ═══ Legacy aliases (older screens keep compiling; remapped to the light world) ═══
    static let bgDeep    = mistDeep
    static let bgMid     = mistMid
    static let bgSurface = mistLight

    static let glassLight  = glassFill
    static let glassMedium = glassFillHi
    static let glassBorder = glassEdge

    static let brand      = Color(red: 0.180, green: 0.392, blue: 0.522)  // #2E6485 — readable accent on light glass
    static let brandLight = Color(red: 0.498, green: 0.804, blue: 1.000)  // #7FCDFF
    static let accentBlue = Color(red: 0.243, green: 0.494, blue: 0.651)  // #3E7EA6

    static let neuLight = Color.white.opacity(0.75)
    static let neuDark  = glassShadow.opacity(0.20)

    static let labelPrimary   = ink
    static let labelSecondary = inkSecondary
    static let labelTertiary  = inkTertiary

    static let inkSurface       = mistDeep
    static let surfaceSecondary = mistLight
}

// MARK: - Atmosphere gradients

extension LinearGradient {
    /// Full-screen luminous mist field. Deep haze at top (hero zone) → ice at bottom.
    static let appBg = LinearGradient(
        colors: [.mistDeep, .mistHaze, .mistMid, .mistLight, .mistIce],
        startPoint: .top,
        endPoint: .bottom
    )
    /// DEPRECATED — gradients are banned inside components (§1 gradient rules).
    /// Kept only so legacy call sites compile; do not use in new code.
    static let brandGradient = LinearGradient(
        colors: [Color.brand, Color.accentBlue],
        startPoint: .leading,
        endPoint: .trailing
    )
}

/// Reusable atmospheric background: mist gradient + two soft pearly glows.
/// Static by design — the light doesn't need to move; calm is the feature.
struct MistBackground: View {
    var body: some View {
        ZStack {
            LinearGradient.appBg

            // Pearly glow, upper right
            RadialGradient(
                colors: [Color.white.opacity(0.42), .clear],
                center: .init(x: 0.85, y: 0.05),
                startRadius: 10, endRadius: 340
            )
            // Ice bloom, lower left
            RadialGradient(
                colors: [Color.mistIce.opacity(0.55), .clear],
                center: .init(x: 0.10, y: 1.0),
                startRadius: 20, endRadius: 380
            )
        }
        .ignoresSafeArea()
    }
}

// MARK: - Layout scale

enum DG {
    /// 4/8pt spacing rhythm
    enum Space {
        static let xs: CGFloat = 4
        static let s:  CGFloat = 8
        static let m:  CGFloat = 16
        static let l:  CGFloat = 24
        static let xl: CGFloat = 32
        /// Standard screen margin
        static let margin: CGFloat = 20
    }

    /// Radius scale — soft, organic
    enum Radius {
        static let s:  CGFloat = 14
        static let m:  CGFloat = 20
        static let l:  CGFloat = 28
        static let xl: CGFloat = 36
    }

    /// Minimum touch target
    static let touchTarget: CGFloat = 44
}

// MARK: - Motion tokens

enum DGMotion {
    /// Standard UI spring — liquid, unhurried
    static let spring = Animation.spring(response: 0.45, dampingFraction: 0.85)
    /// Snappier variant for press feedback
    static let press = Animation.spring(response: 0.30, dampingFraction: 0.75)
    /// Entrance for staggered content
    static func entrance(delay: Double = 0) -> Animation {
        .spring(response: 0.55, dampingFraction: 0.85).delay(delay)
    }
}

// MARK: - Typography

extension Font {
    /// Display voice: SF Pro Rounded — soft, atelier-warm. For titles and hero numerals.
    static func display(_ size: CGFloat, weight: Font.Weight = .semibold) -> Font {
        .system(size: size, weight: weight, design: .rounded)
    }
    /// Large rounded numerals (grid counters, percent complete)
    static func numeral(_ size: CGFloat, weight: Font.Weight = .light) -> Font {
        .system(size: size, weight: weight, design: .rounded)
    }
}

// MARK: - Glass surfaces

extension View {
    /// Frosted glass card — the one glass elevation. Content floats above the mist.
    func glassCard(radius: CGFloat = DG.Radius.l) -> some View {
        self
            .background(.ultraThinMaterial)
            .background(Color.glassFill)
            .clipShape(RoundedRectangle(cornerRadius: radius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: radius, style: .continuous)
                    .strokeBorder(
                        LinearGradient(
                            colors: [Color.glassShine, Color.glassEdge.opacity(0.35)],
                            startPoint: .top, endPoint: .bottom
                        ),
                        lineWidth: 1
                    )
            )
            .shadow(color: Color.glassShadow.opacity(0.16), radius: 22, x: 0, y: 10)
            .shadow(color: Color.glassShadow.opacity(0.08), radius: 4,  x: 0, y: 2)
    }

    /// Legacy soft surface — now a light frosted tile.
    func neuSurface(radius: CGFloat = DG.Radius.s) -> some View {
        self
            .background(Color.glassFillHi)
            .clipShape(RoundedRectangle(cornerRadius: radius, style: .continuous))
            .shadow(color: Color.glassShadow.opacity(0.12), radius: 8, x: 0, y: 4)
    }

    /// Legacy glow — now a soft mist halo (kept for API compatibility).
    func brandGlow(radius: CGFloat = 16) -> some View {
        self.shadow(color: Color.mistIce.opacity(0.55), radius: radius, x: 0, y: 6)
    }

    /// Full-screen atmospheric background.
    func darkPageBackground() -> some View {
        self.background(MistBackground())
    }
}

// MARK: - Button styles

/// Primary CTA — white pill with ink label. One per screen.
/// (Legacy name kept so existing call sites restyle automatically.)
struct GlassCTAStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(Color.white.opacity(configuration.isPressed ? 0.98 : 0.92))
            .clipShape(Capsule())
            .overlay(Capsule().strokeBorder(Color.white.opacity(0.95), lineWidth: 1))
            .shadow(
                color: Color.glassShadow.opacity(configuration.isPressed ? 0.14 : 0.26),
                radius: configuration.isPressed ? 6 : 14, x: 0, y: 6
            )
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(DGMotion.press, value: configuration.isPressed)
    }
}

/// Secondary — frosted capsule.
struct GlassSecondaryStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(.ultraThinMaterial)
            .background(Color.white.opacity(0.24))
            .clipShape(Capsule())
            .overlay(Capsule().strokeBorder(Color.white.opacity(0.55), lineWidth: 1))
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(DGMotion.press, value: configuration.isPressed)
    }
}

// MARK: - Style accent colors (restrained: muted atelier tones, no rainbow)

extension DrawingStyle {
    var accentColor: Color {
        switch self {
        case .none:          return .inkTertiary
        case .gouache:       return Color(red: 0.72, green: 0.42, blue: 0.52)  // muted rose
        case .watercolor:    return Color(red: 0.24, green: 0.52, blue: 0.66)  // slate cyan
        case .oilPaint:      return Color(red: 0.48, green: 0.42, blue: 0.62)  // dusty violet
        case .acrylic:       return Color(red: 0.22, green: 0.55, blue: 0.45)  // sea green
        case .pencilSketch:  return Color(red: 0.42, green: 0.49, blue: 0.56)  // graphite
        case .coloredPencil: return Color(red: 0.35, green: 0.48, blue: 0.64)  // faded indigo
        case .charcoal:      return Color(red: 0.35, green: 0.38, blue: 0.42)  // charcoal slate
        case .pastel:        return Color(red: 0.70, green: 0.52, blue: 0.62)  // powder plum
        case .ink:           return Color(red: 0.16, green: 0.22, blue: 0.30)  // deep ink
        }
    }
}
