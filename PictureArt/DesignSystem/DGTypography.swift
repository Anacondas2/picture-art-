import SwiftUI

// ═══════════════════════════════════════════════════════════════
//  DrawGrid AI — Typography roles
//  SF Pro = working voice · SF Pro Rounded = display voice.
//  Views use roles, never raw sizes. All roles scale with
//  Dynamic Type via relative text styles.
// ═══════════════════════════════════════════════════════════════

extension View {

    /// Home large title — Rounded 34 semibold, ink.
    func dgLargeTitle() -> some View {
        font(.system(size: 34, weight: .semibold, design: .rounded))
            .foregroundColor(.ink)
    }

    /// Screen header — Rounded 28 semibold, ink.
    func dgScreenTitle() -> some View {
        font(.system(size: 28, weight: .semibold, design: .rounded))
            .foregroundColor(.ink)
    }

    /// Section header — Rounded 20 semibold, ink.
    func dgSectionTitle() -> some View {
        font(.system(size: 20, weight: .semibold, design: .rounded))
            .foregroundColor(.ink)
    }

    /// Card / list-row title — Rounded 17 semibold, ink.
    func dgCardTitle() -> some View {
        font(.system(size: 17, weight: .semibold, design: .rounded))
            .foregroundColor(.ink)
    }

    /// Reading text — SF Pro 17 regular, ink, comfortable line spacing.
    func dgBody() -> some View {
        font(.system(size: 17, weight: .regular))
            .foregroundColor(.ink)
            .lineSpacing(4)
    }

    /// Metadata / helper text — SF Pro 13 regular, secondary ink.
    func dgCaption() -> some View {
        font(.system(size: 13, weight: .regular))
            .foregroundColor(.inkSecondary)
    }

    /// Button label — Rounded 16 semibold. Color comes from the button.
    func dgButtonLabel() -> some View {
        font(.system(size: 16, weight: .semibold, design: .rounded))
    }

    /// Grid values, percent, counters — Rounded light, tabular digits.
    /// 26pt in rows, up to 64pt in drawing mode.
    func dgNumeral(_ size: CGFloat, weight: Font.Weight = .light) -> some View {
        font(.system(size: size, weight: weight, design: .rounded))
            .monospacedDigit()
            .foregroundColor(.ink)
    }
}
