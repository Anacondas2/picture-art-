import SwiftUI

struct SquareDetailView: View {
    @Binding var project: ArtProject
    @State var currentIndex: Int
    @EnvironmentObject var lm: LocalizationManager
    @Environment(\.dismiss) var dismiss

    @ObservedObject private var store: ProjectStore = .shared
    @State private var dominantColors: [UIColor] = []
    @State private var tileImage: UIImage?

    private var square: GridSquare { project.squares[currentIndex] }
    private var isCompleted: Bool { square.isCompleted }
    private var canGoPrev: Bool { currentIndex > 0 }
    private var canGoNext: Bool { currentIndex < project.squares.count - 1 }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Square position indicator
                HStack {
                    Text("R\(square.row + 1) × C\(square.col + 1)")
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
                            .overlay(
                                ProgressView()
                            )
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
                if !dominantColors.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(lm.t("square.colors"))
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.horizontal)

                        HStack(spacing: 10) {
                            ForEach(Array(dominantColors.enumerated()), id: \.offset) { _, color in
                                ColorSwatch(color: Color(color))
                            }
                            Spacer()
                        }
                        .padding(.horizontal)
                    }
                    .padding(.bottom, 8)
                }

                Divider()

                // Navigation + Mark Done
                VStack(spacing: 12) {
                    Button {
                        markDone()
                    } label: {
                        HStack {
                            Image(systemName: isCompleted ? "checkmark.seal.fill" : "checkmark.seal")
                            Text(isCompleted ? lm.t("square.done") : lm.t("square.markDone"))
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
                                Text(lm.t("canvas.next").replacingOccurrences(of: "→", with: "").trimmingCharacters(in: .whitespaces))
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
                                Text(lm.t("canvas.next").replacingOccurrences(of: "→", with: "").trimmingCharacters(in: .whitespaces))
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
        tileImage = store.loadTile(row: square.row, col: square.col, for: project)
        dominantColors = []
        if let img = tileImage {
            DispatchQueue.global(qos: .userInitiated).async {
                let colors = ColorExtractor().dominantColors(in: img, count: 6)
                DispatchQueue.main.async { dominantColors = colors }
            }
        }
    }

    private func markDone() {
        if !isCompleted {
            project.markCompleted(row: square.row, col: square.col)
            store.save(project)
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
