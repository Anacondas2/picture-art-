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

    @State private var statusMessage = ""
    @State private var progress: Double = 0
    @State private var processingTask: Task<Void, Never>?
    @State private var isPulsing = false

    var body: some View {
        ZStack {
            LinearGradient.appBg.ignoresSafeArea()

            VStack(spacing: 32) {
                Spacer()

                ZStack {
                    Circle()
                        .fill(Color.brand.opacity(isPulsing ? 0.12 : 0.06))
                        .frame(width: 100, height: 100)
                        .blur(radius: isPulsing ? 12 : 6)
                        .animation(.easeInOut(duration: 1.1).repeatForever(autoreverses: true), value: isPulsing)

                    Image(systemName: "paintbrush.fill")
                        .font(.system(size: 52))
                        .foregroundColor(.brand)
                        .scaleEffect(isPulsing ? 1.07 : 0.93)
                        .opacity(isPulsing ? 1.0 : 0.6)
                        .shadow(color: .brand.opacity(isPulsing ? 0.7 : 0.2), radius: isPulsing ? 24 : 8)
                        .animation(.easeInOut(duration: 0.9).repeatForever(autoreverses: true), value: isPulsing)
                }
                .onAppear { isPulsing = true }

                VStack(spacing: 8) {
                    Text(lm.t("processing.title"))
                        .font(.title2.bold())
                        .foregroundColor(.labelPrimary)
                    Text(statusMessage)
                        .font(.subheadline)
                        .foregroundColor(.labelSecondary)
                        .multilineTextAlignment(.center)
                }

                VStack(spacing: 6) {
                    ProgressView(value: progress)
                        .tint(.brand)
                        .padding(.horizontal, 40)
                    Text("\(Int(progress * 100))%")
                        .font(.caption.monospacedDigit())
                        .foregroundColor(.labelTertiary)
                }

                Spacer()

                Button {
                    processingTask?.cancel()
                    onCancel()
                } label: {
                    Text(lm.t("processing.cancel"))
                        .font(.subheadline.weight(.medium))
                        .foregroundColor(.labelSecondary)
                        .padding(.horizontal, 28)
                        .padding(.vertical, 11)
                }
                .buttonStyle(GlassSecondaryStyle())
                .padding(.bottom, 36)
            }
            .padding()
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
