import SwiftUI

struct GridCanvasView: View {
    @Binding var project: ArtProject
    @EnvironmentObject var lm: LocalizationManager
    @ObservedObject private var store: ProjectStore = .shared

    @State private var displayImage: UIImage?
    @State private var showDetail = false
    @State private var selectedSquareIndex = 0
    @State private var hasShownTapHint = false

    private var completedCount: Int { project.completedCount }
    private var totalCount: Int { project.totalCount }
    private var allDone: Bool { completedCount == totalCount }

    var body: some View {
        VStack(spacing: 0) {
            GeometryReader { geo in
                ZStack(alignment: .topLeading) {
                    Color.bgDeep

                    if let img = displayImage {
                        let imgSize = fittedSize(image: img, in: geo.size)
                        let offsetX = (geo.size.width - imgSize.width) / 2
                        let offsetY = (geo.size.height - imgSize.height) / 2

                        ZStack(alignment: .topLeading) {
                            Image(uiImage: img)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: imgSize.width, height: imgSize.height)

                            Canvas { context, size in
                                drawGrid(context: &context, size: size)
                            }
                            .frame(width: imgSize.width, height: imgSize.height)
                            .allowsHitTesting(false)

                            completedOverlays(imgSize: imgSize)

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
                        .overlay(alignment: .bottom) {
                            if !hasShownTapHint && completedCount == 0 {
                                Text(lm.t("canvas.tap"))
                                    .font(.caption)
                                    .foregroundColor(.labelPrimary)
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 7)
                                    .glassCard(radius: 10)
                                    .padding(.bottom, 14)
                                    .transition(.opacity.combined(with: .scale(scale: 0.95)))
                            }
                        }
                        .animation(.easeOut(duration: 0.3), value: hasShownTapHint)
                    } else {
                        ProgressView()
                            .tint(.brand)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                }
            }

            bottomBar
        }
        .navigationTitle(lm.t("canvas.title"))
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .onAppear { displayImage = store.loadDisplayImage(for: project) }
        .sheet(isPresented: $showDetail) {
            SquareDetailView(project: $project, currentIndex: selectedSquareIndex)
                .environmentObject(lm)
        }
    }

    // MARK: - Bottom bar

    private var bottomBar: some View {
        VStack(spacing: 10) {
            HStack {
                Text("\(completedCount) / \(totalCount) \(lm.t("canvas.completed"))")
                    .font(.subheadline)
                    .foregroundColor(.labelSecondary)
                Spacer()
                if allDone {
                    HStack(spacing: 4) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text(lm.t("canvas.allDone"))
                            .font(.subheadline.bold())
                            .foregroundColor(.green)
                    }
                }
            }

            ProgressView(value: project.progress)
                .tint(allDone ? .green : .brand)

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
                        .padding(.vertical, 13)
                }
                .buttonStyle(GlassCTAStyle())
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(.ultraThinMaterial)
        .background(Color.bgDeep.opacity(0.7))
        .overlay(
            Rectangle()
                .frame(height: 0.5)
                .foregroundColor(.glassBorder),
            alignment: .top
        )
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
                .background(Color.green.opacity(0.18))
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
        let lineWidth = max(1.0, min(cellW, cellH) * 0.025)
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
        context.stroke(path, with: .color(.white.opacity(0.45)), lineWidth: lineWidth)

        var border = Path()
        border.addRect(CGRect(origin: .zero, size: size))
        context.stroke(border, with: .color(.white.opacity(0.7)), lineWidth: lineWidth * 1.5)
    }

    private func handleTap(location: CGPoint, size: CGSize) {
        let cellW = size.width / CGFloat(project.gridCols)
        let cellH = size.height / CGFloat(project.gridRows)
        let col = min(Int(location.x / cellW), project.gridCols - 1)
        let row = min(Int(location.y / cellH), project.gridRows - 1)
        guard row >= 0 && col >= 0 else { return }

        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        hasShownTapHint = true

        selectedSquareIndex = project.squareIndex(row: row, col: col)
        showDetail = true
    }
}
