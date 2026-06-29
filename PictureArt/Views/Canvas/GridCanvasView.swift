import SwiftUI

struct GridCanvasView: View {
    @Binding var project: ArtProject
    @EnvironmentObject var lm: LocalizationManager
    @ObservedObject private var store: ProjectStore = .shared

    @State private var displayImage: UIImage?
    @State private var showDetail = false
    @State private var selectedSquareIndex = 0

    private var completedCount: Int { project.completedCount }
    private var totalCount: Int { project.totalCount }
    private var allDone: Bool { completedCount == totalCount }

    var body: some View {
        VStack(spacing: 0) {
            // Canvas area
            GeometryReader { geo in
                ZStack(alignment: .topLeading) {
                    // Background
                    Color(UIColor.systemBackground)

                    if let img = displayImage {
                        let imgSize = fittedSize(image: img, in: geo.size)
                        let offsetX = (geo.size.width - imgSize.width) / 2
                        let offsetY = (geo.size.height - imgSize.height) / 2

                        ZStack(alignment: .topLeading) {
                            // Image
                            Image(uiImage: img)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: imgSize.width, height: imgSize.height)

                            // Grid overlay + completed overlays
                            Canvas { context, size in
                                drawGrid(context: &context, size: size)
                            }
                            .frame(width: imgSize.width, height: imgSize.height)
                            .allowsHitTesting(false)

                            // Completed cell overlays
                            completedOverlays(imgSize: imgSize)

                            // Tap gesture
                            Color.clear
                                .contentShape(Rectangle())
                                .gesture(
                                    DragGesture(minimumDistance: 0)
                                        .onEnded { value in
                                            handleTap(location: value.location, size: imgSize)
                                        }
                                )
                        }
                        .frame(width: imgSize.width, height: imgSize.height)
                        .offset(x: offsetX, y: offsetY)
                    } else {
                        ProgressView()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                }
            }

            // Bottom bar
            bottomBar
        }
        .navigationTitle(lm.t("canvas.title"))
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { displayImage = store.loadDisplayImage(for: project) }
        .sheet(isPresented: $showDetail) {
            SquareDetailView(project: $project, currentIndex: selectedSquareIndex)
                .environmentObject(lm)
        }
    }

    // MARK: - Sub-views

    private var bottomBar: some View {
        VStack(spacing: 8) {
            // Progress
            HStack {
                Text("\(completedCount) / \(totalCount) \(lm.t("canvas.completed"))")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Spacer()
                if allDone {
                    Text(lm.t("canvas.allDone"))
                        .font(.subheadline.bold())
                        .foregroundColor(.green)
                }
            }

            ProgressView(value: project.progress)
                .tint(allDone ? .green : .accentColor)

            if !allDone {
                Button {
                    if let idx = project.firstUncompletedIndex {
                        selectedSquareIndex = idx
                        showDetail = true
                    }
                } label: {
                    Text(lm.t("canvas.next"))
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color.accentColor)
                        .cornerRadius(10)
                }
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 12)
        .background(Color(UIColor.systemBackground).shadow(color: .black.opacity(0.08), radius: 8, y: -2))
    }

    @ViewBuilder
    private func completedOverlays(imgSize: CGSize) -> some View {
        let cellW = imgSize.width / CGFloat(project.gridCols)
        let cellH = imgSize.height / CGFloat(project.gridRows)

        ForEach(project.squares.filter { $0.isCompleted }) { sq in
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: min(cellW, cellH) * 0.35))
                .foregroundColor(.green)
                .frame(width: cellW, height: cellH)
                .background(Color.green.opacity(0.25))
                .position(
                    x: CGFloat(sq.col) * cellW + cellW / 2,
                    y: CGFloat(sq.row) * cellH + cellH / 2
                )
        }
    }

    // MARK: - Helpers

    private func fittedSize(image: UIImage, in container: CGSize) -> CGSize {
        let imgAspect = image.size.width / image.size.height
        let conAspect = container.width / container.height
        if imgAspect > conAspect {
            return CGSize(width: container.width, height: container.width / imgAspect)
        } else {
            return CGSize(width: container.height * imgAspect, height: container.height)
        }
    }

    private func drawGrid(context: inout GraphicsContext, size: CGSize) {
        let cellW = size.width / CGFloat(project.gridCols)
        let cellH = size.height / CGFloat(project.gridRows)
        var path = Path()

        for col in 1..<project.gridCols {
            let x = CGFloat(col) * cellW
            path.move(to: CGPoint(x: x, y: 0))
            path.addLine(to: CGPoint(x: x, y: size.height))
        }
        for row in 1..<project.gridRows {
            let y = CGFloat(row) * cellH
            path.move(to: CGPoint(x: 0, y: y))
            path.addLine(to: CGPoint(x: size.width, y: y))
        }
        context.stroke(path, with: .color(.white.opacity(0.55)), lineWidth: 0.6)

        // Border
        var border = Path()
        border.addRect(CGRect(origin: .zero, size: size))
        context.stroke(border, with: .color(.white.opacity(0.8)), lineWidth: 1)
    }

    private func handleTap(location: CGPoint, size: CGSize) {
        let cellW = size.width / CGFloat(project.gridCols)
        let cellH = size.height / CGFloat(project.gridRows)
        let col = min(Int(location.x / cellW), project.gridCols - 1)
        let row = min(Int(location.y / cellH), project.gridRows - 1)
        guard row >= 0 && col >= 0 else { return }
        selectedSquareIndex = project.squareIndex(row: row, col: col)
        showDetail = true
    }
}
