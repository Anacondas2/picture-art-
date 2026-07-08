import SwiftUI

// ═══════════════════════════════════════════════════════════════
//  DrawGrid AI — Input & control system
//  Frosted tracks, solid-white selection, rounded numerals.
//  System controls (Toggle, Menu, wheel pickers) stay native.
// ═══════════════════════════════════════════════════════════════

/// Segmented control — frosted track, sliding solid-white thumb.
struct DGSegmented<T: Hashable>: View {
    let options: [(value: T, label: String)]
    @Binding var selection: T
    @Namespace private var thumb

    var body: some View {
        HStack(spacing: 2) {
            ForEach(options, id: \.value) { option in
                let isSelected = option.value == selection
                Button {
                    UISelectionFeedbackGenerator().selectionChanged()
                    withAnimation(DGMotion.press) { selection = option.value }
                } label: {
                    Text(option.label)
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundColor(isSelected ? .ink : .inkSecondary)
                        .frame(maxWidth: .infinity)
                        .frame(minHeight: DG.touchTarget - 6)
                        .background {
                            if isSelected {
                                Capsule()
                                    .fill(Color.glassSelected)
                                    .shadow(color: Color.glassShadow.opacity(0.18), radius: 6, x: 0, y: 3)
                                    .matchedGeometryEffect(id: "thumb", in: thumb)
                            }
                        }
                        .contentShape(Capsule())
                }
                .buttonStyle(.plain)
                .accessibilityAddTraits(isSelected ? .isSelected : [])
            }
        }
        .padding(3)
        .background(.ultraThinMaterial)
        .background(Color.white.opacity(0.20))
        .clipShape(Capsule())
        .overlay(Capsule().strokeBorder(Color.white.opacity(0.50), lineWidth: 1))
    }
}

/// Stepper — frosted capsule with 44pt −/+ and a big rounded value.
/// Pass a `detail` line to translate the value into the physical world
/// ("each square ≈ 2.6 cm") — that translation is part of the control.
struct DGStepper: View {
    let value: Int
    let range: ClosedRange<Int>
    var step: Int = 1
    var detail: String? = nil
    let onChange: (Int) -> Void

    var body: some View {
        VStack(spacing: DG.Space.s - 2) {
            HStack(spacing: 0) {
                stepButton(systemImage: "minus", enabled: value - step >= range.lowerBound) {
                    onChange(max(range.lowerBound, value - step))
                }

                Text("\(value)")
                    .dgNumeral(26, weight: .regular)
                    .frame(minWidth: 64)
                    .contentTransition(.numericText())

                stepButton(systemImage: "plus", enabled: value + step <= range.upperBound) {
                    onChange(min(range.upperBound, value + step))
                }
            }
            .background(.ultraThinMaterial)
            .background(Color.white.opacity(0.24))
            .clipShape(Capsule())
            .overlay(Capsule().strokeBorder(Color.white.opacity(0.55), lineWidth: 1))

            if let detail {
                Text(detail)
                    .dgCaption()
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityValue("\(value)")
    }

    private func stepButton(systemImage: String, enabled: Bool, action: @escaping () -> Void) -> some View {
        Button {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            withAnimation(DGMotion.press) { action() }
        } label: {
            Image(systemName: systemImage)
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(enabled ? .ink : .inkTertiary)
                .frame(width: DG.touchTarget, height: DG.touchTarget)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .disabled(!enabled)
    }
}

/// Labeled slider — visible label, ink-blue track, rounded value readout.
struct DGLabeledSlider: View {
    let label: String
    @Binding var value: Double
    let range: ClosedRange<Double>
    var step: Double = 1
    var format: (Double) -> String = { "\(Int($0))" }

    var body: some View {
        VStack(alignment: .leading, spacing: DG.Space.s - 2) {
            HStack {
                Text(label)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.inkSecondary)
                Spacer()
                Text(format(value))
                    .dgNumeral(20, weight: .regular)
                    .contentTransition(.numericText())
            }
            Slider(value: $value, in: range, step: step)
                .tint(.brand)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(label)
        .accessibilityValue(format(value))
    }
}
