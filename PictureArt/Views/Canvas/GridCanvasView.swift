import SwiftUI

struct GridCanvasView: View {
    @Binding var project: ArtProject
    @EnvironmentObject var lm: LocalizationManager
    @ObservedObject private var store: ProjectStore = .shared

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var displayImage: UIImage?
    @State private var showDetail = false
    @State private var selectedSquareIndex = 0
    @State private var hasShownTapHint = false
    @State private var showCelebration = false
    @State private var celebrationTriggered = false

    private var completedCount: Int { project.completedCount }
    private var totalCount: Int { project.totalCount }
    private var allDone: Bool { completedCount == totalCount && totalCount > 0 }

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
                        .animation(reduceMotion ? nil : .easeOut(duration: 0.3), value: hasShownTapHint)
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
        .toolbarColorScheme(.light, for: .navigationBar)
        .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .onAppear { displayImage = store.loadDisplayImage(for: project) }
        .onChange(of: completedCount) { newValue in
            if newValue == totalCount && totalCount > 0 && !celebrationTriggered {
                celebrationTriggered = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    UINotificationFeedbackGenerator().notificationOccurred(.success)
                    withAnimation(reduceMotion ? nil : .easeOut(duration: 0.25)) {
                        showCelebration = true
                    }
                }
            }
        }
        .sheet(isPresented: $showDetail) {
            SquareDetailView(project: $project, currentIndex: selectedSquareIndex)
                .environmentObject(lm)
        }
        .overlay {
            if showCelebration {
                CelebrationOverlay(
                    totalCount: totalCount,
                    lm: lm,
                    reduceMotion: reduceMotion
                ) {
                    withAnimation(reduceMotion ? nil : .easeIn(duration: 0.2)) {
                        showCelebration = false
                    }
                }
                .transition(.opacity)
            }
        }
    }

    // MARK: - Bottom bar

    private var bottomBar: some View {
        HStack(spacing: 14) {
            // Ring progress
            RingProgress(
                progress: project.progress,
                allDone: allDone,
                reduceMotion: reduceMotion
            )

            // Count text
            VStack(alignment: .leading, spacing: 2) {
                Text("\(completedCount) / \(totalCount)")
                    .font(.headline.monospacedDigit())
                    .foregroundColor(allDone ? .green : .labelPrimary)
                Text(lm.t("canvas.completed"))
                    .font(.caption)
                    .foregroundColor(.labelTertiary)
            }

            Spacer()

            if allDone {
                HStack(spacing: 6) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    Text(lm.t("canvas.allDone"))
                        .font(.subheadline.bold())
                        .foregroundColor(.green)
                }
                .transition(.scale.combined(with: .opacity))
            } else {
                Button {
                    if let idx = project.firstUncompletedIndex {
                        selectedSquareIndex = idx
                        showDetail = true
                    }
                } label: {
                    Text(lm.t("canvas.next"))
                        .font(.headline)
                        .foregroundColor(.ink)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
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
        .animation(reduceMotion ? nil : .spring(response: 0.4, dampingFraction: 0.8), value: allDone)
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

// MARK: - Ring Progress

private struct RingProgress: View {
    let progress: Double
    let allDone: Bool
    let reduceMotion: Bool

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.white.opacity(0.1), lineWidth: 3.5)

            Circle()
                .trim(from: 0, to: CGFloat(progress))
                .stroke(
                    allDone ? Color.green : Color.brand,
                    style: StrokeStyle(lineWidth: 3.5, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(reduceMotion ? nil : .spring(response: 0.5, dampingFraction: 0.75), value: progress)

            if allDone {
                Image(systemName: "checkmark")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.green)
                    .transition(.scale.combined(with: .opacity))
            } else {
                Text("\(Int(progress * 100))")
                    .font(.system(size: 9, weight: .semibold).monospacedDigit())
                    .foregroundColor(.labelSecondary)
            }
        }
        .frame(width: 36, height: 36)
    }
}

// MARK: - Celebration Overlay

private struct CelebrationOverlay: View {
    let totalCount: Int
    let lm: LocalizationManager
    let reduceMotion: Bool
    let onDismiss: () -> Void

    @State private var appeared = false

    private var isRU: Bool { lm.currentLanguage == "ru" }

    var body: some View {
        ZStack {
            Color.bgDeep.opacity(0.93)
                .ignoresSafeArea()

            VStack(spacing: 32) {
                // Icon with rings
                ZStack {
                    ForEach([1.4, 1.9, 2.4] as [CGFloat], id: \.self) { scale in
                        Circle()
                            .stroke(Color.green.opacity(0.08), lineWidth: 1)
                            .frame(width: 64, height: 64)
                            .scaleEffect(appeared ? scale : 1)
                            .opacity(appeared ? 0 : 1)
                            .animation(
                                reduceMotion ? nil :
                                .easeOut(duration: 1.8).repeatForever(autoreverses: false)
                                    .delay(Double(scale - 1.4) * 0.4),
                                value: appeared
                            )
                    }

                    Circle()
                        .fill(Color.green.opacity(0.12))
                        .frame(width: 96, height: 96)

                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 52, weight: .medium))
                        .foregroundColor(.green)
                        .shadow(color: .green.opacity(0.5), radius: 20)
                        .scaleEffect(appeared ? 1 : (reduceMotion ? 1 : 0.3))
                        .animation(
                            reduceMotion ? nil : .spring(response: 0.55, dampingFraction: 0.55),
                            value: appeared
                        )
                }

                // Text
                VStack(spacing: 10) {
                    Text(isRU ? "Шедевр готов!" : "Masterpiece Complete!")
                        .font(.title2.bold())
                        .foregroundColor(.white)

                    Text(isRU
                         ? "Все \(totalCount) клеток завершены"
                         : "All \(totalCount) squares done")
                        .font(.subheadline)
                        .foregroundColor(.labelSecondary)
                }
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : (reduceMotion ? 0 : 20))
                .animation(
                    reduceMotion ? nil : .spring(response: 0.5, dampingFraction: 0.8).delay(0.18),
                    value: appeared
                )

                // Dismiss button
                Button(action: onDismiss) {
                    Text(isRU ? "Отлично!" : "Amazing!")
                        .font(.headline)
                        .foregroundColor(.ink)
                        .padding(.horizontal, 48)
                        .padding(.vertical, 14)
                }
                .buttonStyle(GlassCTAStyle())
                .opacity(appeared ? 1 : 0)
                .animation(
                    reduceMotion ? nil : .easeOut(duration: 0.3).delay(0.35),
                    value: appeared
                )
            }
        }
        .onAppear {
            appeared = true
            // Auto-dismiss after 5 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                onDismiss()
            }
        }
    }
}
