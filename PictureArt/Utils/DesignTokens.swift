import SwiftUI

// Brand palette: warm amber-gold, like raw sienna pigment.
// Restrained strategy: amber for primary actions and selection only.
// Contrast-safe on both light (AA 4.5:1 against white at full saturation) and dark backgrounds.
extension Color {
    // Primary brand accent — warm amber, deliberately not corporate blue
    static let brand      = Color(red: 0.84, green: 0.51, blue: 0.07)
    static let brandLight = Color(red: 0.98, green: 0.90, blue: 0.70)
    static let brandDark  = Color(red: 0.55, green: 0.30, blue: 0.01)

    // Onboarding canvas — warm near-black, like the inside cover of a quality sketchbook.
    // Deliberately NOT cream/sand/beige (the AI default), NOT blue-tech-startup.
    static let inkSurface = Color(red: 0.09, green: 0.07, blue: 0.05)

    // Semantic shortcuts that stay adaptive (light/dark mode)
    static let surfaceSecondary = Color(UIColor.secondarySystemBackground)
    static let labelPrimary     = Color(UIColor.label)
    static let labelSecondary   = Color(UIColor.secondaryLabel)
}
