import SwiftUI

struct ProcessingView: View {
    let image: UIImage
    let style: DrawingStyle
    let medium: DrawingMedium
    let gridRows: Int
    let gridCols: Int
    let projectName: String
    let paperSize: PaperSize
    let skillLevel: SkillLevel
    var onComplete: (ArtProject) -> Void
    var onError: (String) -> Void
    var onCancel: () -> Void

    @EnvironmentObject var lm: LocalizationManager
    @ObservedObject var store: ProjectStore = .shared
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var statusMessage = ""
    @State private var progress: Double = 0
    @State private var processingTask: Task<Void, Never>?
    @State private var isPulsing = false

    var body: some View {
        ZStack {
            MistBackground()

            VStack(spacing: DG.Space.xl) {
                Spacer()

                // Calm breathing brush on a frosted disc
                ZStack {
                    Circle()
                        .fill(.ultraThinMaterial)
                        .background(Circle().fill(Color.white.opacity(0.35)))
                        .frame(width: 110, height: 110)
                        .overlay(Circle().strokeBorder(Color.glassEdge, lineWidth: 1))
                        .shadow(color: Color.glassShadow.opacity(0.18), radius: 18, x: 0, y: 8)
                        .scaleEffect(isPulsing && !reduceMotion ? 1.05 : 1.0)
                        .animation(
                            reduceMotion ? nil : .easeInOut(duration: 1.4).repeatForever(autoreverses: true),
                            value: isPulsing
                        )

                    Image(systemName: "paintbrush.fill")
                        .font(.system(size: 42, weight: .light))
                        .foregroundColor(.brand)
                        .opacity(isPulsing && !reduceMotion ? 1.0 : 0.75)
                        .animation(
                            reduceMotion ? nil : .easeInOut(duration: 1.4).repeatForever(autoreverses: true),
                            value: isPulsing
                        )
                }
                .onAppear { isPulsing = true }
                .accessibilityHidden(true)

                VStack(spacing: DG.Space.s) {
                    Text(lm.t("processing.title"))
                        .dgSectionTitle()
                    Text(statusMessage)
                        .font(.subheadline)
                        .foregroundColor(.inkSecondary)
                        .multilineTextAlignment(.center)
                }

                VStack(spacing: DG.Space.s) {
                    ProgressView(value: progress)
                        .tint(.brand)
                        .padding(.horizontal, DG.Space.xl + 8)
                    HStack(alignment: .firstTextBaseline, spacing: 1) {
                        Text("\(Int(progress * 100))").dgNumeral(26)
                        Text("%")
                            .dgNumeral(13, weight: .medium)
                            .foregroundColor(.inkTertiary)
                    }
                }
                .accessibilityElement(children: .combine)
                .accessibilityLabel("\(lm.t("processing.title")), \(Int(progress * 100))%")

                Spacer()

                Button {
                    processingTask?.cancel()
                    onCancel()
                } label: {
                    Text(lm.t("processing.cancel"))
                        .dgButtonLabel()
                        .foregroundColor(.inkSecondary)
                        .padding(.horizontal, DG.Space.l)
                        .frame(minHeight: DG.touchTarget)
                }
                .buttonStyle(GlassSecondaryStyle())
                .padding(.bottom, DG.Space.xl)
            }
            .padding(DG.Space.m)
        }
        .onAppear {
            statusMessage = lm.t("processing.applyingStyle")
            processingTask = Task { await process() }
        }
        .onDisappear {
            processingTask?.cancel()
        }
    }

    @MainActor
    private func process() async {
        guard !Task.isCancelled else { return }
        let aiService = StabilityAIService()
        let splitter = ImageSplitter()

        var styledImage = image

        if style != .none {
            let apiKey = store.apiKey
            statusMessage = lm.t("processing.applyingStyle")
            progress = 0.1
            do {
                styledImage = try await aiService.transform(image: image, style: style, apiKey: apiKey)
                progress = 0.4
            } catch AIServiceError.noAPIKey {
                onError(lm.t("error.noApiKey"))
                return
            } catch {
                if Task.isCancelled { return }
                onError(lm.t("error.api") + error.localizedDescription)
                return
            }
        } else {
            progress = 0.4
        }

        guard !Task.isCancelled else { return }

        statusMessage = lm.t("processing.splitting")
        progress = 0.5

        let tiles = splitter.split(image: styledImage, rows: gridRows, cols: gridCols)
        progress = 0.7

        guard !Task.isCancelled else { return }

        statusMessage = lm.t("processing.saving")
        var project = ArtProject(
            name: projectName.isEmpty ? lm.t("newproject.namePlaceholder") : projectName,
            style: style,
            medium: medium,
            gridRows: gridRows,
            gridCols: gridCols,
            paperSize: paperSize,
            skillLevel: skillLevel
        )

        store.saveOriginalImage(image, for: project)
        store.saveStyledImage(styledImage, for: project)

        for (rowIdx, row) in tiles.enumerated() {
            for (colIdx, tile) in row.enumerated() {
                store.saveTile(tile, row: rowIdx, col: colIdx, for: project)
            }
        }

        store.save(project)
        progress = 1.0

        try? await Task.sleep(nanoseconds: 300_000_000)
        guard !Task.isCancelled else { return }
        onComplete(project)
    }
}
