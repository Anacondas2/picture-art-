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
            VStack(spacing: 0) {
                if let sq = square {
                    // Square position indicator
                    HStack {
                        Text("\(lm.t("square.row")) \(sq.row + 1), \(lm.t("square.col")) \(sq.col + 1)")
                            .font(.caption.monospaced())
                            .foregroundColor(.secondary)
                        Spacer()
                        Text("\(currentIndex + 1) \(lm.t("square.of")) \(project.totalCount)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)

                    // Tile image
                    Group {
                        if let img = tileImage {
                            Image(uiImage: img)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .cornerRadius(8)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(isCompleted ? Color.green : Color.clear, lineWidth: 3)
                                )
                        } else {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color(UIColor.secondarySystemBackground))
                                .overlay(ProgressView())
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

                    // Completed badge
                    if isCompleted {
                        HStack {
                            Image(systemName: "checkmark.seal.fill")
                                .foregroundColor(.green)
                            Text(lm.t("square.done"))
                                .foregroundColor(.green)
                                .font(.subheadline.bold())
                        }
                        .padding(.vertical, 4)
                    }

                    // Color swatches
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text(lm.t("square.colors"))
                                .font(.caption)
                                .foregroundColor(.secondary)
                            if isLoadingColors {
                                ProgressView()
                                    .scaleEffect(0.6)
                            }
                        }
                        .padding(.horizontal)

                        if !dominantColors.isEmpty {
                            HStack(spacing: 10) {
                                ForEach(Array(dominantColors.enumerated()), id: \.offset) { _, color in
                                    ColorSwatch(color: Color(color))
                                }
                                Spacer()
                            }
                            .padding(.horizontal)
                        } else if !isLoadingColors {
                            Text(lm.t("square.loadingColors"))
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .padding(.horizontal)
                        }
                    }
                    .padding(.bottom, 8)
                } else {
                    Text(lm.t("error.imageLoad"))
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }

                Divider()

                // Navigation + Mark Done
                VStack(spacing: 12) {
                    Button {
                        toggleDone()
                    } label: {
                        HStack {
                            Image(systemName: isCompleted ? "checkmark.seal.fill" : "checkmark.seal")
                            Text(isCompleted ? lm.t("square.markUndone") : lm.t("square.markDone"))
                        }
                        .font(.headline)
                        .foregroundColor(isCompleted ? .green : .white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(isCompleted ? Color.green.opacity(0.15) : Color.accentColor)
                        .cornerRadius(12)
                    }

                    HStack(spacing: 16) {
                        Button {
                            navigate(by: -1)
                        } label: {
                            HStack {
                                Image(systemName: "chevron.left")
                                Text(lm.currentLanguage == "ru" ? "Назад" : "Prev")
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(Color(UIColor.secondarySystemBackground))
                            .cornerRadius(10)
                        }
                        .disabled(!canGoPrev)

                        Button {
                            navigate(by: 1)
                        } label: {
                            HStack {
                                Text(lm.currentLanguage == "ru" ? "Вперёд" : "Next")
                                Image(systemName: "chevron.right")
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(Color(UIColor.secondarySystemBackground))
                            .cornerRadius(10)
                        }
                        .disabled(!canGoNext)
                    }
                    .foregroundColor(.primary)
                }
                .padding(.horizontal)
                .padding(.vertical, 12)
            }
            .navigationTitle(lm.t("square.title"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(lm.t("error.ok")) { dismiss() }
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

        // Auto-advance to next uncompleted when marking done
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
        currentIndex = newIndex
    }
}

private struct ColorSwatch: View {
    let color: Color

    var body: some View {
        color
            .frame(width: 32, height: 32)
            .clipShape(Circle())
            .overlay(
                Circle().stroke(Color(UIColor.systemBackground), lineWidth: 2)
                    .shadow(color: .black.opacity(0.15), radius: 2)
            )
    }
}
