#if DEBUG
import SwiftUI

// ═══════════════════════════════════════════════════════════════
//  DrawGrid AI — Design System Gallery (DEBUG only)
//  The Stage-2 acceptance artifact: every token and component on
//  one scrollable screen. Open the SwiftUI preview and judge the
//  whole system against the quality bar before Stage 3.
// ═══════════════════════════════════════════════════════════════

struct DGPreviewGallery: View {
    @State private var segSelection = "A4"
    @State private var gridValue = 16
    @State private var sliderValue: Double = 12
    @State private var selectedOption = 1
    @State private var loading = false

    var body: some View {
        ZStack {
            MistBackground()

            ScrollView {
                VStack(alignment: .leading, spacing: DG.Space.xl) {

                    // ── Hero zone: mist text on the deep band ──
                    VStack(alignment: .leading, spacing: DG.Space.m) {
                        (
                            Text("Turn any photo into ").foregroundColor(.mistText)
                            + Text("art you can draw").foregroundColor(.mistTextGhost)
                        )
                        .font(.system(size: 34, weight: .semibold, design: .rounded))
                        .fixedSize(horizontal: false, vertical: true)

                        Text("Hero zone: bright + ghost display text on mistDeep. Body-size mist text uses mistTextSoft.")
                            .font(.subheadline)
                            .foregroundColor(.mistTextSoft)
                    }
                    .padding(.top, DG.Space.l)

                    // ── Typography ──
                    section("Typography") {
                        VStack(alignment: .leading, spacing: DG.Space.s + 2) {
                            Text("Large Title 34").dgLargeTitle()
                            Text("Screen Title 28").dgScreenTitle()
                            Text("Section Title 20").dgSectionTitle()
                            Text("Card Title 17").dgCardTitle()
                            Text("Body 17 — reading text sits in ink, never gray, with comfortable line spacing for long guidance copy.").dgBody()
                            Text("Caption 13 — metadata and helper text").dgCaption()
                            HStack(alignment: .firstTextBaseline, spacing: 2) {
                                Text("64").dgNumeral(64)
                                Text("%").dgNumeral(20, weight: .medium)
                                Spacer()
                                Text("26").dgNumeral(26)
                                Text("12×12").dgNumeral(20, weight: .regular)
                            }
                        }
                    }

                    // ── Buttons ──
                    section("Buttons") {
                        VStack(spacing: DG.Space.m - 4) {
                            DGPrimaryButton(title: "Start Drawing", systemImage: "plus", isLoading: loading) {
                                loading = true
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { loading = false }
                            }
                            DGPrimaryButton(title: "Disabled Primary", isDisabled: true) {}
                            HStack(spacing: DG.Space.s + 4) {
                                DGSecondaryButton(title: "Secondary", systemImage: "square.grid.3x3") {}
                                DGIconButton(systemImage: "gearshape", accessibilityLabel: "Settings") {}
                                DGIconButton(systemImage: "square.and.arrow.up", accessibilityLabel: "Share") {}
                            }
                            HStack(spacing: DG.Space.m) {
                                DGGhostButton(title: "Choose different photo") {}
                                Spacer()
                                DGDestructiveButton(title: "Delete") {}
                            }
                        }
                    }

                    // ── Cards & selection states ──
                    section("Cards · selection = glass turns solid") {
                        HStack(spacing: DG.Space.s + 4) {
                            ForEach(0..<3, id: \.self) { idx in
                                DGOptionCard(
                                    value: ["8×8", "16×16", "24×24"][idx],
                                    caption: ["Easy", "Balanced", "Detailed"][idx],
                                    isSelected: selectedOption == idx
                                ) { selectedOption = idx }
                            }
                        }
                        HStack(spacing: DG.Space.s + 4) {
                            DGOptionCard(value: "A4", caption: "21 × 29.7 cm", isSelected: true) {}
                            DGOptionCard(value: "○ 30", caption: "Disabled", isDisabled: true) {}
                        }
                    }

                    // ── Controls ──
                    section("Controls") {
                        VStack(spacing: DG.Space.l - 4) {
                            DGSegmented(
                                options: [("A5", "A5"), ("A4", "A4"), ("A3", "A3"), ("Custom", "Custom")],
                                selection: $segSelection
                            )
                            DGStepper(
                                value: gridValue,
                                range: 4...32,
                                detail: "each square ≈ 1.8 cm on A4"
                            ) { gridValue = $0 }
                            DGLabeledSlider(
                                label: "Grid density",
                                value: $sliderValue,
                                range: 4...32
                            )
                            Toggle(isOn: .constant(true)) {
                                Text("Keep original photo").dgBody()
                            }
                            .tint(.progressTeal)
                        }
                    }

                    // ── Floating bar (drawing mode HUD) ──
                    section("Floating control bar · thickMaterial over artwork") {
                        DGFloatingBar {
                            DGIconButton(systemImage: "chevron.left", accessibilityLabel: "Previous square") {}
                            VStack(spacing: 2) {
                                Text("B7").dgNumeral(26, weight: .regular)
                                Text("square 23 of 144").dgCaption()
                            }
                            .frame(maxWidth: .infinity)
                            DGIconButton(systemImage: "checkmark", accessibilityLabel: "Mark done", tint: .progressTeal) {}
                        }
                    }

                    // ── Functional colors ──
                    section("Functional accents · always icon + text, never color alone") {
                        VStack(alignment: .leading, spacing: DG.Space.s + 2) {
                            Label("144 of 144 squares complete", systemImage: "checkmark.circle.fill")
                                .font(.system(size: 17, weight: .semibold, design: .rounded))
                                .foregroundColor(.progressTeal)
                            Label("No API key — original photo will be used", systemImage: "exclamationmark.triangle.fill")
                                .font(.system(size: 14, weight: .medium)).foregroundColor(.warning)
                            Label("Delete project", systemImage: "trash")
                                .font(.system(size: 14, weight: .medium)).foregroundColor(.destructive)
                        }
                    }

                    Spacer(minLength: DG.Space.xl)
                }
                .padding(.horizontal, DG.Space.margin)
            }
        }
    }

    @ViewBuilder
    private func section(_ title: String, @ViewBuilder content: () -> some View) -> some View {
        VStack(alignment: .leading, spacing: DG.Space.m) {
            Text(title).dgSectionTitle()
            VStack(alignment: .leading, spacing: DG.Space.m) {
                content()
            }
            .padding(DG.Space.l - 4)
            .frame(maxWidth: .infinity, alignment: .leading)
            .dgGlassCard(radius: DG.Radius.l)
        }
    }
}

#Preview("Design System") {
    DGPreviewGallery()
}

#Preview("Dynamic Type XL") {
    DGPreviewGallery()
        .environment(\.sizeCategory, .accessibilityLarge)
}
#endif
