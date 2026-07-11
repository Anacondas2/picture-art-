import SwiftUI

// ═══════════════════════════════════════════════════════════════
//  DrawGrid AI — Typography roles
//  SF Pro = working voice · SF Pro Rounded = display voice.
//  Views use roles, never raw sizes. Every text role is built on
//  a platform text style, so all copy scales with Dynamic Type.
//  Exception: dgNumeral is fixed-size by design — large counters
//  are layout-critical (rings, steppers, HUD) and stay stable.
// ═══════════════════════════════════════════════════════════════

extension View {

    /// Home large title — Rounded largeTitle (34) semibold, ink. Scales.
    func dgLargeTitle() -> some View {
        font(.system(.largeTitle, design: .rounded, weight: .semibold))
            .foregroundColor(.ink)
    }

    /// Screen header — Rounded title (28) semibold, ink. Scales.
    func dgScreenTitle() -> some View {
        font(.system(.title, design: .rounded, weight: .semibold))
            .foregroundColor(.ink)
    }

    /// Section header — Rounded title3 (20) semibold, ink. Scales.
    func dgSectionTitle() -> some View {
        font(.system(.title3, design: .rounded, weight: .semibold))
            .foregroundColor(.ink)
    }

    /// Card / list-row title — Rounded headline (17 semibold), ink. Scales.
    func dgCardTitle() -> some View {
        font(.system(.headline, design: .rounded))
            .foregroundColor(.ink)
    }

    /// Reading text — body (17), ink, comfortable line spacing. Scales.
    func dgBody() -> some View {
        font(.body)
            .foregroundColor(.ink)
            .lineSpacing(4)
    }

    /// Metadata / helper text — footnote (13), secondary ink. Scales.
    func dgCaption() -> some View {
        font(.footnote)
            .foregroundColor(.inkSecondary)
    }

    /// Button label — Rounded callout (16) semibold. Color comes from the button. Scales.
    func dgButtonLabel() -> some View {
        font(.system(.callout, design: .rounded, weight: .semibold))
    }

    /// Grid values, percent, counters — Rounded light, tabular digits.
    /// Fixed size by documented exception: these numerals anchor layout
    /// (progress rings, steppers, drawing-mode HUD) and must not reflow.
    func dgNumeral(_ size: CGFloat, weight: Font.Weight = .light) -> some View {
        font(.system(size: size, weight: weight, design: .rounded))
            .monospacedDigit()
            .foregroundColor(.ink)
    }
}
