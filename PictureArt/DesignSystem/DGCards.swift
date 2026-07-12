import SwiftUI

// ═══════════════════════════════════════════════════════════════
//  DrawGrid AI — Card system
//  One glass elevation with explicit states, plus the two
//  reusable card shells the workflow screens will need.
//  Rule: a card holds one idea.
// ═══════════════════════════════════════════════════════════════

extension View {
    /// Glass card with selection/disabled states.
    /// Selected = the glass turns solid white; content switches to ink.
    /// Disabled = 40% opacity, shadow removed.
    @ViewBuilder
    func dgGlassCard(
        radius: CGFloat = DG.Radius.l,
        selected: Bool = false,
        disabled: Bool = false
    ) -> some View {
        let shape = RoundedRectangle(cornerRadius: radius, style: .continuous)

        self
            .background(.ultraThinMaterial)
            .background(selected ? Color.glassSelected : Color.glassFill)
            .clipShape(shape)
            .overlay(
                shape.strokeBorder(
                    selected
                        ? AnyShapeStyle(Color.white)
                        : AnyShapeStyle(LinearGradient(
                            colors: [Color.glassShine, Color.glassEdge.opacity(0.35)],
                            startPoint: .top, endPoint: .bottom
                          )),
                    lineWidth: 1
                )
            )
            .shadow(
                color: disabled ? .clear : Color.glassShadow.opacity(selected ? 0.22 : 0.16),
                radius: 22, x: 0, y: 10
            )
            .shadow(
                color: disabled ? .clear : Color.glassShadow.opacity(0.08),
                radius: 4, x: 0, y: 2
            )
            .opacity(disabled ? 0.4 : 1)
            .allowsHitTesting(!disabled)
    }
}

/// Compact selectable option card — grid sizes, paper sizes, styles.
/// Big rounded value + caption; selection reads as solid glass.
struct DGOptionCard: View {
    let value: String
    let caption: String
    var isSelected: Bool = false
    var isDisabled: Bool = false
    let action: () -> Void

    var body: some View {
        Button {
            UISelectionFeedbackGenerator().selectionChanged()
            action()
        } label: {
            VStack(spacing: DG.Space.xs) {
                Text(value)
                    .dgNumeral(24, weight: isSelected ? .regular : .light)
                Text(caption)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.inkSecondary)
                    .lineLimit(1)
            }
            .frame(minWidth: 72, minHeight: 64)
            .padding(.horizontal, DG.Space.m - 4)
            .padding(.vertical, DG.Space.s + 2)
            .dgGlassCard(radius: DG.Radius.s, selected: isSelected, disabled: isDisabled)
        }
        .buttonStyle(.plain)
        .disabled(isDisabled)
        .accessibilityLabel("\(value), \(caption)")
        .accessibilityAddTraits(isSelected ? .isSelected : [])
        .animation(DGMotion.press, value: isSelected)
    }
}

/// Selectable chip — paper sizes, mediums, crop aspects.
/// Selection reads as the glass turning solid.
struct DGChip: View {
    var icon: String? = nil
    let label: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button {
            UISelectionFeedbackGenerator().selectionChanged()
            action()
        } label: {
            HStack(spacing: 6) {
                if let icon {
                    Image(systemName: icon)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(isSelected ? .brand : .inkSecondary)
                }
                Text(label)
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundColor(.ink)
            }
            .padding(.horizontal, DG.Space.m)
            .frame(minHeight: DG.touchTarget)
            .background(.ultraThinMaterial)
            .background(isSelected ? Color.glassSelected : Color.glassFill.opacity(0.6))
            .clipShape(Capsule())
            .overlay(
                Capsule().strokeBorder(
                    isSelected ? Color.white : Color.glassEdge.opacity(0.7),
                    lineWidth: 1
                )
            )
            .shadow(
                color: isSelected ? Color.glassShadow.opacity(0.20) : .clear,
                radius: 8, x: 0, y: 4
            )
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
        .animation(DGMotion.press, value: isSelected)
    }
}

/// Floating bottom control bar — for drawing mode.
/// Thick material because it sits over the user's artwork.
struct DGFloatingBar<Content: View>: View {
    @ViewBuilder var content: Content

    var body: some View {
        HStack(spacing: DG.Space.m) {
            content
        }
        .padding(.horizontal, DG.Space.m + 4)
        .padding(.vertical, DG.Space.m - 4)
        .background(.thickMaterial)
        .clipShape(RoundedRectangle(cornerRadius: DG.Radius.l, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: DG.Radius.l, style: .continuous)
                .strokeBorder(Color.white.opacity(0.55), lineWidth: 1)
        )
        .shadow(color: Color.glassShadow.opacity(0.22), radius: 28, x: 0, y: 14)
    }
}
