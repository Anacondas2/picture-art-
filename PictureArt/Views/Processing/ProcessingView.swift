import SwiftUI

struct ProcessingView: View {
    let image: UIImage
    let style: DrawingStyle
    let medium: DrawingMedium
    let gridRows: Int
    let gridCols: Int
    let projectName: String
    var onComplete: (ArtProject) -> Void
    var onError: (String) -> Void

    @EnvironmentObject var lm: LocalizationManager
    @ObservedObject var store: ProjectStore = .shared

    @State private var statusMessage = ""
    @State private var progress: Double = 0

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            Image(systemName: "paintbrush.fill")
                .font(.system(size: 56))
                .foregroundColor(.accentColor)
                .rotationEffect(.degrees(progress > 0 ? 360 : 0))
                .animation(.linear(duration: 2).repeatForever(autoreverses: false), value: progress)

            VStack(spacing: 8) {
                Text(lm.t("processing.title"))
                    .font(.title2.bold())
                Text(statusMessage)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }

            ProgressView(value: progress)
                .padding(.horizontal, 40)
                .tint(.accentColor)

            Spacer()
        }
        .padding()
        .task { await process() }
        .onAppear { statusMessage = lm.t("processing.applyingStyle") }
    }

    @MainActor
    private func process() async {
        let aiService = StabilityAIService()
        let splitter = ImageSplitter()

        var styledImage = image

        // Step 1: AI style transfer
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
                onError(lm.t("error.api") + error.localizedDescription)
                return
            }
        } else {
            progress = 0.4
        }

        // Step 2: Split into grid
        statusMessage = lm.t("processing.splitting")
        progress = 0.5

        let tiles = splitter.split(image: styledImage, rows: gridRows, cols: gridCols)
        progress = 0.7

        // Step 3: Save everything
        statusMessage = lm.t("processing.saving")
        var project = ArtProject(
            name: projectName.isEmpty ? lm.t("newproject.namePlaceholder") : projectName,
            style: style,
            medium: medium,
            gridRows: gridRows,
            gridCols: gridCols
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
        onComplete(project)
    }
}
