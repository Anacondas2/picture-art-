import SwiftUI
import PhotosUI

// ═══════════════════════════════════════════════════════════════
//  DrawGrid AI — Photo Import (Stage 6)
//  One photo becomes the drawing reference. Explicit state model,
//  off-main decoding, stale-selection guard, no library permission
//  (PhotosPicker is out-of-process — the app receives only the
//  chosen item).
// ═══════════════════════════════════════════════════════════════

/// The imported photo: full-resolution original for later stages,
/// bounded preview for display.
struct ImportedImage {
    let original: UIImage   // normalized, full size — crop/split consume this
    let preview: UIImage    // ≤1600px — what the screen shows
}

struct PhotoImportView: View {
    /// Downstream contract: the sheet's configure step reads this.
    @Binding var image: UIImage?
    var onContinue: () -> Void

    @EnvironmentObject var lm: LocalizationManager
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private enum ImportState {
        case idle
        case loading(id: UUID)
        case loaded(ImportedImage)
        case failed(String)
    }

    @State private var state: ImportState = .idle
    @State private var pickerItem: PhotosPickerItem?
    @State private var showPicker = false
    @State private var loadTask: Task<Void, Never>?

    private var isRU: Bool { lm.currentLanguage == "ru" }
    private var isLoaded: Bool { if case .loaded = state { return true }; return false }

    // MARK: - Copy

    private var t: (instruction: String, support: String, choose: String,
                    replace: String, remove: String, loading: String,
                    failed: String, retry: String, cont: String,
                    privacy: String, previewLabel: String) {
        isRU
        ? ("Выберите фото, которое будете рисовать",
           "Одно фото станет вашим референсом.",
           "Выбрать фото", "Заменить", "Убрать", "Готовим фото…",
           "Не удалось открыть это фото. Попробуйте другое.",
           "Выбрать другое", "Продолжить",
           "Приложение получает только выбранное вами фото.",
           "Выбранное фото — ваш референс для рисования")
        : ("Choose the photo you'll draw",
           "One photo becomes your drawing reference.",
           "Choose Photo", "Replace", "Remove", "Preparing photo…",
           "This photo couldn't be opened. Try another one.",
           "Choose Another", "Continue",
           "The app only receives the photo you choose.",
           "Selected photo — your drawing reference")
    }

    // MARK: - Body

    var body: some View {
        GeometryReader { geo in
            let compact = geo.size.height < 660
            let previewMaxHeight = geo.size.height * 0.55

            VStack(spacing: 0) {
                ScrollView {
                    VStack(spacing: 0) {
                        switch state {
                        case .idle:
                            emptyState(compact: compact)
                        case .loading:
                            loadingState(maxHeight: previewMaxHeight)
                        case .failed(let message):
                            failedState(message: message)
                        case .loaded(let imported):
                            previewState(imported, maxHeight: previewMaxHeight)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, compact ? DG.Space.m : DG.Space.l)
                    .padding(.bottom, DG.Space.l)
                    .animation(reduceMotion ? nil : DGMotion.spring, value: isLoaded)
                }

                bottomBar
            }
        }
        .photosPicker(isPresented: $showPicker, selection: $pickerItem, matching: .images)
        .onChange(of: pickerItem) { item in
            guard let item else { return }   // cancellation → silent no-op
            startLoading(item)
        }
        .onAppear {
            // Returning from Configure: the selection survives the session.
            if case .idle = state, let existing = image {
                state = .loaded(ImportedImage(
                    original: existing,
                    preview: existing.resizedToFit(maxDimension: 1600)
                ))
            }
        }
        .onDisappear { loadTask?.cancel() }
    }

    // MARK: - Empty state

    @ViewBuilder
    private func emptyState(compact: Bool) -> some View {
        VStack(spacing: 0) {
            Text(t.instruction)
                .dgSectionTitle()
                .multilineTextAlignment(.center)
                .padding(.horizontal, DG.Space.l)

            Text(t.support)
                .dgCaption()
                .padding(.top, DG.Space.s)

            // The reference sheet, waiting for its photo
            RoundedRectangle(cornerRadius: DG.Radius.s, style: .continuous)
                .fill(Color.clear)
                .aspectRatio(1 / 1.414, contentMode: .fit)
                .frame(width: compact ? 130 : 170)
                .background(.ultraThinMaterial)
                .background(Color.white.opacity(0.40))
                .clipShape(RoundedRectangle(cornerRadius: DG.Radius.s, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: DG.Radius.s, style: .continuous)
                        .strokeBorder(Color.glassEdge, lineWidth: 1)
                )
                .overlay(
                    Image(systemName: "photo")
                        .font(.system(size: 34, weight: .light))
                        .foregroundColor(.inkTertiary)
                )
                .rotationEffect(.degrees(-2))
                .shadow(color: Color.glassShadow.opacity(0.18), radius: 16, x: 0, y: 8)
                .padding(.vertical, compact ? DG.Space.l : DG.Space.xl)
                .accessibilityHidden(true)

            DGPrimaryButton(title: t.choose, systemImage: "photo.on.rectangle") {
                showPicker = true
            }
            .padding(.horizontal, DG.Space.margin)

            Text(t.privacy)
                .dgCaption()
                .multilineTextAlignment(.center)
                .padding(.top, DG.Space.m)
                .padding(.horizontal, DG.Space.l)
        }
    }

    // MARK: - Loading state

    @ViewBuilder
    private func loadingState(maxHeight: CGFloat) -> some View {
        VStack(spacing: DG.Space.m) {
            RoundedRectangle(cornerRadius: DG.Radius.m, style: .continuous)
                .fill(Color.white.opacity(0.30))
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: DG.Radius.m, style: .continuous))
                .frame(height: maxHeight * 0.8)
                .overlay(ProgressView().tint(.brand).scaleEffect(1.3))
                .padding(.horizontal, DG.Space.margin)

            Text(t.loading)
                .dgCaption()
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(t.loading)
    }

    // MARK: - Failed state

    @ViewBuilder
    private func failedState(message: String) -> some View {
        VStack(spacing: DG.Space.m) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 30, weight: .light))
                .foregroundColor(.warning)

            Text(message)
                .dgBody()
                .multilineTextAlignment(.center)

            DGSecondaryButton(title: t.retry, systemImage: "photo.on.rectangle") {
                showPicker = true
            }
        }
        .padding(DG.Space.l)
        .frame(maxWidth: .infinity)
        .dgGlassCard(radius: DG.Radius.l)
        .padding(.horizontal, DG.Space.margin)
        .padding(.top, DG.Space.xl)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(message)
    }

    // MARK: - Preview state

    @ViewBuilder
    private func previewState(_ imported: ImportedImage, maxHeight: CGFloat) -> some View {
        VStack(spacing: DG.Space.m) {
            // The artwork — sharpest thing on screen, deepest shadow
            Image(uiImage: imported.preview)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxHeight: maxHeight)
                .clipShape(RoundedRectangle(cornerRadius: DG.Radius.m, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: DG.Radius.m, style: .continuous)
                        .strokeBorder(Color.glassEdge, lineWidth: 1)
                )
                .shadow(color: Color.glassShadow.opacity(0.22), radius: 20, x: 0, y: 10)
                .padding(.horizontal, DG.Space.margin)
                .accessibilityLabel(t.previewLabel)

            HStack(spacing: DG.Space.m) {
                DGSecondaryButton(title: t.replace, systemImage: "arrow.triangle.2.circlepath") {
                    showPicker = true
                }
                DGGhostButton(title: t.remove, role: .destructive) {
                    removeImage()
                }
            }
        }
    }

    // MARK: - Bottom bar

    private var bottomBar: some View {
        VStack(spacing: 0) {
            DGPrimaryButton(title: t.cont, isDisabled: !isLoaded) {
                onContinue()
            }
            .padding(.horizontal, DG.Space.margin)
            .padding(.top, DG.Space.m - 4)
            .padding(.bottom, DG.Space.s)
        }
        .background(.ultraThinMaterial)
        .overlay(alignment: .top) {
            Rectangle().fill(Color.white.opacity(0.40)).frame(height: 1)
        }
    }

    // MARK: - Loading pipeline

    private func startLoading(_ item: PhotosPickerItem) {
        loadTask?.cancel()
        let id = UUID()
        state = .loading(id: id)
        UIAccessibility.post(notification: .announcement, argument: t.loading)

        loadTask = Task {
            let data = try? await item.loadTransferable(type: Data.self)

            // Decode + orient + downscale off the main actor
            let result: ImportedImage? = await Task.detached(priority: .userInitiated) {
                guard let data, let ui = UIImage(data: data) else { return nil }
                let normalized = ui.normalized()
                return ImportedImage(
                    original: normalized,
                    preview: normalized.resizedToFit(maxDimension: 1600)
                )
            }.value

            await MainActor.run {
                // Stale guard: apply only if this is still the current load
                guard case .loading(let current) = state, current == id, !Task.isCancelled else { return }

                if let result {
                    state = .loaded(result)
                    image = result.original
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                } else {
                    state = .failed(t.failed)
                    image = nil
                    UIAccessibility.post(notification: .announcement, argument: t.failed)
                }
            }
        }
    }

    private func removeImage() {
        loadTask?.cancel()
        withAnimation(reduceMotion ? nil : DGMotion.spring) {
            state = .idle
            image = nil
            pickerItem = nil
        }
    }
}

// MARK: - Previews

#if DEBUG
#Preview("Import — Empty") {
    ZStack {
        MistBackground()
        PhotoImportView(image: .constant(nil), onContinue: {})
            .environmentObject(LocalizationManager.shared)
    }
}
#endif
