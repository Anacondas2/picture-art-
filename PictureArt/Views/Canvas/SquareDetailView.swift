import SwiftUI

struct SquareDetailView: View {
    @Binding var project: ArtProject
    @State var currentIndex: Int
    @EnvironmentObject var lm: LocalizationManager
    @Environment(\.dismiss) var dismiss

    @ObservedObject private var store: ProjectStore = .shared
    @State private var dominantColors: [UIColor] = []
    @State private var isLoadingColors = false
    @State private var tileImage: UIImage?

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

                        // Tile image
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
                            } else {
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(Color.bgSurface)
                                    .overlay(
                                        ProgressView().tint(.brand)
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 14)
                                            .stroke(Color.glassBorder, lineWidth: 0.5)
                                    )
                            }
                        }
                        .padding(.horizontal, 16)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)

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
                        }

                        // Color swatches
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
                                    ForEach(Array(dominantColors.enumerated()), id: \.offset) { _, color in
                                        ColorSwatch(color: Color(color))
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
                        .padding(.bottom, 10)
                    } else {
                        Text(lm.t("error.imageLoad"))
                            .foregroundColor(.labelSecondary)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }

                    // Divider
                    Color.glassBorder
                        .frame(height: 0.5)

                    // Navigation + Mark Done
                    VStack(spacing: 12) {
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
                        .animation(.easeOut(duration: 0.2), value: isCompleted)

                        HStack(spacing: 12) {
                            Button {
                                navigate(by: -1)
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
                                navigate(by: 1)
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
        .onAppear { loadContent() }
        .onChange(of: currentIndex) { _ in loadContent() }
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
            if let nextUncompleted = project.squares.dropFirst(currentIndex + 1).firstIndex(where: { !$0.isCompleted }) {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                    currentIndex = nextUncompleted
                }
            }
        }
    }

    private func navigate(by delta: Int) {
        let newIndex = currentIndex + delta
        guard newIndex >= 0 && newIndex < project.squares.count else { return }
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        currentIndex = newIndex
    }
}

private struct ColorSwatch: View {
    let color: Color

    var body: some View {
        color
            .frame(width: 36, height: 36)
            .clipShape(Circle())
            .shadow(color: .neuLight, radius: 4, x: -2, y: -2)
            .shadow(color: .neuDark, radius: 4, x: 2, y: 2)
            .overlay(
                Circle().stroke(Color.glassBorder, lineWidth: 0.5)
            )
    }
}
