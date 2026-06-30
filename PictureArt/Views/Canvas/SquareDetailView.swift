import SwiftUI

struct SquareDetailView: View {
    @Binding var project: ArtProject
    @State var currentIndex: Int
    @EnvironmentObject var lm: LocalizationManager
    @Environment(\.dismiss) var dismiss
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @ObservedObject private var store: ProjectStore = .shared
    @State private var dominantColors: [UIColor] = []
    @State private var isLoadingColors = false
    @State private var tileImage: UIImage?

    // Swipe gesture state
    @State private var swipeOffset: CGFloat = 0
    @State private var isHorizontalSwipe: Bool? = nil
    @State private var showSwipeHint = false
    @State private var swipeHintDismissed = false

    private var square: GridSquare? {
        guard currentIndex >= 0 && currentIndex < project.squares.count else { return nil }
        return project.squares[currentIndex]
    }
    private var isCompleted: Bool { square?.isCompleted ?? false }
    private var canGoPrev: Bool { currentIndex > 0 }
    private var canGoNext: Bool { currentIndex < project.squares.count - 1 }

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient.appBg.ignoresSafeArea()

                VStack(spacing: 0) {
                    if let sq = square {
                        // Position indicator
                        HStack {
                            Text("\(lm.t("square.row")) \(sq.row + 1), \(lm.t("square.col")) \(sq.col + 1)")
                                .font(.caption.monospaced())
                                .foregroundColor(.labelTertiary)
                            Spacer()
                            Text("\(currentIndex + 1) \(lm.t("square.of")) \(project.totalCount)")
                                .font(.caption)
                                .foregroundColor(.labelTertiary)
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 10)
                        .padding(.bottom, 6)

                        // Tile image with swipe gesture
                        tileArea
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .padding(.horizontal, 16)

                        // Completed badge
                        if isCompleted {
                            HStack(spacing: 6) {
                                Image(systemName: "checkmark.seal.fill")
                                    .foregroundColor(.green)
                                    .font(.subheadline)
                                Text(lm.t("square.done"))
                                    .foregroundColor(.green)
                                    .font(.subheadline.bold())
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color.green.opacity(0.12))
                            .clipShape(Capsule())
                            .overlay(Capsule().stroke(Color.green.opacity(0.3), lineWidth: 0.5))
                            .padding(.vertical, 6)
                            .transition(.scale.combined(with: .opacity))
                        }

                        // Color swatches
                        colorSwatchRow
                            .padding(.bottom, 10)

                    } else {
                        Text(lm.t("error.imageLoad"))
                            .foregroundColor(.labelSecondary)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }

                    // Divider
                    Color.glassBorder.frame(height: 0.5)

                    // Action bar
                    bottomActionBar
                }
            }
            .navigationTitle(lm.t("square.title"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(lm.t("error.ok")) { dismiss() }
                        .foregroundColor(.brand)
                }
            }
        }
        .onAppear {
            loadContent()
            // Show swipe hint after a short delay on first open
            if !swipeHintDismissed {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                    withAnimation(reduceMotion ? nil : .easeOut(duration: 0.3)) {
                        showSwipeHint = true
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        withAnimation(reduceMotion ? nil : .easeOut(duration: 0.3)) {
                            showSwipeHint = false
                            swipeHintDismissed = true
                        }
                    }
                }
            }
        }
        .onChange(of: currentIndex) { _ in loadContent() }
    }

    // MARK: - Tile area with swipe

    private var tileArea: some View {
        ZStack {
            tileImageView
                .offset(x: swipeOffset)
                .gesture(
                    DragGesture(minimumDistance: 12)
                        .onChanged { val in
                            if isHorizontalSwipe == nil {
                                let h = abs(val.translation.width)
                                let v = abs(val.translation.height)
                                if h > v + 4 { isHorizontalSwipe = true }
                                else if v > h + 4 { isHorizontalSwipe = false }
                            }
                            guard isHorizontalSwipe == true else { return }
                            showSwipeHint = false
                            swipeHintDismissed = true
                            let w = val.translation.width
                            let isEdge = (w > 0 && !canGoPrev) || (w < 0 && !canGoNext)
                            swipeOffset = isEdge ? w * 0.22 : w
                        }
                        .onEnded { val in
                            defer { isHorizontalSwipe = nil }
                            guard isHorizontalSwipe == true else { return }

                            let velocity = val.predictedEndTranslation.width
                            let threshold: CGFloat = 80

                            if velocity < -threshold && canGoNext {
                                slideTo(direction: -1)
                            } else if velocity > threshold && canGoPrev {
                                slideTo(direction: 1)
                            } else {
                                // Snap back
                                withAnimation(reduceMotion ? nil : .spring(response: 0.35, dampingFraction: 0.8)) {
                                    swipeOffset = 0
                                }
                            }
                        }
                )

            // Swipe hint overlay
            if showSwipeHint && (canGoPrev || canGoNext) {
                swipeHintView
            }
        }
    }

    @ViewBuilder
    private var tileImageView: some View {
        Group {
            if let img = tileImage {
                Image(uiImage: img)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(
                                isCompleted ? Color.green : Color.glassBorder,
                                lineWidth: isCompleted ? 2 : 0.5
                            )
                    )
                    .shadow(
                        color: isCompleted ? .green.opacity(0.25) : .brand.opacity(0.15),
                        radius: 16, x: 0, y: 6
                    )
                    .animation(reduceMotion ? nil : .easeOut(duration: 0.2), value: isCompleted)
            } else {
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color.bgSurface)
                    .overlay(ProgressView().tint(.brand))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(Color.glassBorder, lineWidth: 0.5)
                    )
            }
        }
    }

    private var swipeHintView: some View {
        HStack(spacing: 20) {
            if canGoPrev {
                Label(
                    lm.currentLanguage == "ru" ? "Назад" : "Prev",
                    systemImage: "chevron.left"
                )
                .font(.caption.weight(.medium))
                .foregroundColor(.labelTertiary)
            }
            Spacer()
            if canGoNext {
                Label(
                    lm.currentLanguage == "ru" ? "Вперёд" : "Next",
                    systemImage: "chevron.right"
                )
                .labelStyle(ReversedLabelStyle())
                .font(.caption.weight(.medium))
                .foregroundColor(.labelTertiary)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
        .glassCard(radius: 12)
        .padding(.horizontal, 20)
        .transition(.opacity.combined(with: .scale(scale: 0.96)))
    }

    // MARK: - Color swatches

    private var colorSwatchRow: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(lm.t("square.colors"))
                    .font(.caption)
                    .foregroundColor(.labelTertiary)
                if isLoadingColors {
                    ProgressView()
                        .scaleEffect(0.6)
                        .tint(.brand)
                }
            }
            .padding(.horizontal, 16)

            if !dominantColors.isEmpty {
                HStack(spacing: 12) {
                    ForEach(Array(dominantColors.enumerated()), id: \.offset) { idx, color in
                        ColorSwatch(color: Color(color))
                            .opacity(1)
                            .scaleEffect(1)
                            .animation(
                                reduceMotion ? nil :
                                    .spring(response: 0.4, dampingFraction: 0.7).delay(Double(idx) * 0.04),
                                value: dominantColors.count
                            )
                    }
                    Spacer()
                }
                .padding(.horizontal, 16)
            } else if !isLoadingColors {
                Text(lm.t("square.loadingColors"))
                    .font(.caption)
                    .foregroundColor(.labelTertiary)
                    .padding(.horizontal, 16)
            }
        }
    }

    // MARK: - Bottom action bar

    private var bottomActionBar: some View {
        VStack(spacing: 12) {
            // Mark done / undo button
            Button {
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                toggleDone()
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: isCompleted ? "checkmark.seal.fill" : "checkmark.seal")
                    Text(isCompleted ? lm.t("square.markUndone") : lm.t("square.markDone"))
                }
                .font(.headline)
                .foregroundColor(isCompleted ? .green : .white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
            }
            .background(
                Group {
                    if isCompleted {
                        AnyView(Color.green.opacity(0.12))
                    } else {
                        AnyView(LinearGradient.brandGradient)
                    }
                }
            )
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(isCompleted ? Color.green.opacity(0.4) : Color.clear, lineWidth: 0.5)
            )
            .shadow(color: isCompleted ? .green.opacity(0.2) : .brand.opacity(0.4), radius: 12, x: 0, y: 5)
            .animation(reduceMotion ? nil : .easeOut(duration: 0.2), value: isCompleted)

            // Prev / Next navigation buttons
            HStack(spacing: 12) {
                Button {
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    slideTo(direction: 1)
                } label: {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text(lm.currentLanguage == "ru" ? "Назад" : "Prev")
                    }
                    .font(.subheadline.weight(.medium))
                    .foregroundColor(canGoPrev ? .labelPrimary : .labelTertiary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                }
                .buttonStyle(GlassSecondaryStyle())
                .disabled(!canGoPrev)

                Button {
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    slideTo(direction: -1)
                } label: {
                    HStack {
                        Text(lm.currentLanguage == "ru" ? "Вперёд" : "Next")
                        Image(systemName: "chevron.right")
                    }
                    .font(.subheadline.weight(.medium))
                    .foregroundColor(canGoNext ? .labelPrimary : .labelTertiary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                }
                .buttonStyle(GlassSecondaryStyle())
                .disabled(!canGoNext)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(.ultraThinMaterial)
        .background(Color.bgDeep.opacity(0.6))
    }

    // MARK: - Logic

    private func slideTo(direction: Int) {
        // direction: -1 = go next (slide left), +1 = go prev (slide right)
        let targetIndex = currentIndex + (direction == -1 ? 1 : -1)
        guard targetIndex >= 0 && targetIndex < project.squares.count else { return }

        if reduceMotion {
            currentIndex = targetIndex
            swipeOffset = 0
            return
        }

        let screenWidth = UIScreen.main.bounds.width
        withAnimation(.easeIn(duration: 0.16)) {
            swipeOffset = CGFloat(direction) * screenWidth
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.16) {
            currentIndex = targetIndex
            swipeOffset = CGFloat(-direction) * screenWidth
            withAnimation(.spring(response: 0.32, dampingFraction: 0.88)) {
                swipeOffset = 0
            }
        }
    }

    private func loadContent() {
        guard let sq = square else { return }
        tileImage = store.loadTile(row: sq.row, col: sq.col, for: project)
        dominantColors = []
        guard let img = tileImage else { return }
        isLoadingColors = true
        DispatchQueue.global(qos: .userInitiated).async {
            let colors = ColorExtractor().dominantColors(in: img, count: 6)
            DispatchQueue.main.async {
                dominantColors = colors
                isLoadingColors = false
            }
        }
    }

    private func toggleDone() {
        guard let sq = square else { return }
        let wasCompleted = sq.isCompleted
        project.toggleCompleted(row: sq.row, col: sq.col)
        store.save(project)

        if !wasCompleted {
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            if let nextUncompleted = project.squares.dropFirst(currentIndex + 1)
                .firstIndex(where: { !$0.isCompleted }) {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.28) {
                    slideTo(direction: -1)
                    _ = nextUncompleted  // already navigated sequentially
                }
            }
        }
    }
}

// MARK: - Color Swatch

private struct ColorSwatch: View {
    let color: Color

    var body: some View {
        color
            .frame(width: 36, height: 36)
            .clipShape(Circle())
            .shadow(color: .neuLight, radius: 4, x: -2, y: -2)
            .shadow(color: .neuDark, radius: 4, x: 2, y: 2)
            .overlay(Circle().stroke(Color.glassBorder, lineWidth: 0.5))
    }
}

// MARK: - Reversed label style helper

private struct ReversedLabelStyle: LabelStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack(spacing: 4) {
            configuration.title
            configuration.icon
        }
    }
}
