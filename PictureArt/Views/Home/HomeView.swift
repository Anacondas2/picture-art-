import SwiftUI
import PhotosUI

struct HomeView: View {
    @EnvironmentObject var lm: LocalizationManager
    @ObservedObject var store: ProjectStore = .shared
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var showNewProject = false
    @State private var activeProject: ArtProject?
    @State private var navigateToProject = false
    @State private var projectToDelete: ArtProject?
    @State private var showDeleteConfirm = false
    @State private var listAppeared = false

    private var isRU: Bool { lm.currentLanguage == "ru" }

    var body: some View {
        NavigationStack {
            ZStack {
                MistBackground()

                Group {
                    if store.projects.isEmpty {
                        emptyState
                    } else {
                        projectList
                    }
                }
            }
            .navigationTitle(lm.t("home.title"))
            .toolbarColorScheme(.light, for: .navigationBar)
            .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        showNewProject = true
                    } label: {
                        ZStack {
                            Circle()
                                .fill(Color.white.opacity(0.85))
                                .frame(width: 34, height: 34)
                                .shadow(color: Color.glassShadow.opacity(0.20), radius: 6, x: 0, y: 3)
                            Image(systemName: "plus")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(.ink)
                        }
                    }
                    .accessibilityLabel(lm.t("home.newProject"))
                }
                ToolbarItem(placement: .topBarLeading) {
                    NavigationLink {
                        SettingsView().environmentObject(lm)
                    } label: {
                        Image(systemName: "gearshape")
                            .foregroundColor(.inkSecondary)
                    }
                    .accessibilityLabel("Settings")
                }
            }
            .navigationDestination(isPresented: $navigateToProject) {
                if let project = activeProject,
                   let idx = store.projects.firstIndex(where: { $0.id == project.id }) {
                    GridCanvasView(project: $store.projects[idx])
                        .environmentObject(lm)
                }
            }
            .sheet(isPresented: $showNewProject) {
                NewProjectSheet { createdProject in
                    activeProject = createdProject
                    showNewProject = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                        navigateToProject = true
                    }
                }
                .environmentObject(lm)
            }
            .alert(lm.t("home.deleteConfirm"), isPresented: $showDeleteConfirm, actions: {
                Button(lm.t("home.delete"), role: .destructive) {
                    if let p = projectToDelete { store.delete(p) }
                }
                Button(lm.t("error.cancel"), role: .cancel) {}
            }, message: {
                Text(lm.t("home.deleteMessage"))
            })
        }
    }

    // MARK: - Empty state — "the promise"

    private var emptyState: some View {
        VStack(alignment: .leading, spacing: 0) {
            Spacer(minLength: DG.Space.l)

            // Hero headline: bright + ghost, on the deep mist zone
            VStack(alignment: .leading, spacing: DG.Space.m) {
                (
                    Text(isRU ? "Преврати любое фото " : "Turn any photo into ")
                        .foregroundColor(.mistText)
                    + Text(isRU ? "в настоящий рисунок" : "art you can draw")
                        .foregroundColor(.mistTextGhost)
                )
                .font(.display(34, weight: .semibold))
                .lineSpacing(4)
                .fixedSize(horizontal: false, vertical: true)

                Text(isRU
                     ? "Сфотографируй что угодно — получи спокойный гид по клеткам для бумаги или холста."
                     : "Photograph anything — get a calm, square-by-square guide for real paper or canvas.")
                    .font(.subheadline)
                    .foregroundColor(.mistTextSoft)
                    .lineSpacing(4)
                    .frame(maxWidth: 300, alignment: .leading)
            }
            .padding(.horizontal, DG.Space.margin + 8)
            .opacity(listAppeared ? 1 : 0)
            .offset(y: listAppeared ? 0 : 14)
            .animation(reduceMotion ? nil : DGMotion.entrance(delay: 0.05), value: listAppeared)

            Spacer(minLength: DG.Space.xl)

            // How it works — one glass card, three steps
            VStack(spacing: DG.Space.m) {
                ForEach(Array(emptyStateSteps.enumerated()), id: \.offset) { idx, step in
                    HStack(spacing: DG.Space.m) {
                        ZStack {
                            Circle()
                                .fill(Color.white.opacity(0.55))
                                .frame(width: 44, height: 44)
                            Image(systemName: step.icon)
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(.brand)
                        }
                        VStack(alignment: .leading, spacing: 2) {
                            Text(step.label)
                                .font(.display(15, weight: .semibold))
                                .foregroundColor(.ink)
                            Text(step.detail)
                                .font(.caption)
                                .foregroundColor(.inkSecondary)
                        }
                        Spacer()
                        Text("\(idx + 1)")
                            .font(.numeral(24, weight: .light))
                            .foregroundColor(.inkTertiary)
                    }
                    .opacity(listAppeared ? 1 : 0)
                    .offset(y: listAppeared ? 0 : 16)
                    .animation(reduceMotion ? nil : DGMotion.entrance(delay: 0.15 + Double(idx) * 0.07), value: listAppeared)
                }
            }
            .padding(DG.Space.l)
            .glassCard(radius: DG.Radius.l)
            .padding(.horizontal, DG.Space.margin)

            Spacer(minLength: DG.Space.xl)

            // CTA — white pill
            VStack(spacing: DG.Space.s + 2) {
                Button {
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    showNewProject = true
                } label: {
                    HStack(spacing: DG.Space.s) {
                        Image(systemName: "plus")
                            .font(.system(size: 16, weight: .semibold))
                        Text(lm.t("home.newProject"))
                            .font(.display(16, weight: .semibold))
                    }
                    .foregroundColor(.ink)
                    .frame(maxWidth: .infinity)
                    .frame(minHeight: 54)
                }
                .buttonStyle(GlassCTAStyle())
                .padding(.horizontal, DG.Space.margin)

                Text(isRU
                     ? "Бумага и карандаш — всё, что нужно"
                     : "All you need is paper and a pencil")
                    .font(.footnote)
                    .foregroundColor(.inkTertiary)
            }
            .opacity(listAppeared ? 1 : 0)
            .offset(y: listAppeared ? 0 : 12)
            .animation(reduceMotion ? nil : DGMotion.entrance(delay: 0.42), value: listAppeared)

            Spacer(minLength: DG.Space.xl + DG.Space.m)
        }
        .onAppear { listAppeared = true }
        .onDisappear { listAppeared = false }
    }

    private var emptyStateSteps: [(icon: String, label: String, detail: String)] {
        isRU
            ? [(icon: "photo.on.rectangle", label: "Загрузите фото",   detail: "Из галереи или камеры"),
               (icon: "sparkles",           label: "Выберите стиль",   detail: "Акварель, карандаш, масло…"),
               (icon: "squareshape.split.3x3", label: "Рисуйте по клеткам", detail: "Спокойно, клетка за клеткой")]
            : [(icon: "photo.on.rectangle", label: "Upload a photo",   detail: "From your library or camera"),
               (icon: "sparkles",           label: "Pick a style",     detail: "Watercolor, pencil, oil…"),
               (icon: "squareshape.split.3x3", label: "Draw by square", detail: "Calmly, one cell at a time")]
    }

    // MARK: - Project list

    private var projectList: some View {
        ScrollView {
            LazyVStack(spacing: DG.Space.m - 4) {
                ForEach(Array($store.projects.enumerated()), id: \.element.id) { idx, $project in
                    ProjectRow(project: $project, lm: lm)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                            activeProject = project
                            navigateToProject = true
                        }
                        .contextMenu {
                            Button(role: .destructive) {
                                projectToDelete = project
                                showDeleteConfirm = true
                            } label: {
                                Label(lm.t("home.delete"), systemImage: "trash")
                            }
                        }
                        .opacity(listAppeared ? 1 : 0)
                        .offset(y: listAppeared ? 0 : 24)
                        .animation(
                            reduceMotion ? nil : DGMotion.entrance(delay: Double(idx) * 0.06),
                            value: listAppeared
                        )
                }
            }
            .padding(.horizontal, DG.Space.m)
            .padding(.vertical, DG.Space.m)
        }
        .onAppear { listAppeared = true }
        .onDisappear { listAppeared = false }
    }
}

// MARK: - Project Row

private struct ProjectRow: View {
    @Binding var project: ArtProject
    let lm: LocalizationManager
    @ObservedObject private var store: ProjectStore = .shared
    @State private var isPressed = false

    private var isDone: Bool { project.progress >= 1 }
    private var percent: Int { Int((project.progress * 100).rounded()) }

    var body: some View {
        HStack(spacing: DG.Space.m) {
            ThumbnailView(project: project)

            VStack(alignment: .leading, spacing: 5) {
                Text(project.name)
                    .font(.display(16, weight: .semibold))
                    .foregroundColor(.ink)
                    .lineLimit(1)

                Text("\(project.gridRows)×\(project.gridCols) · \(project.style.displayName(lang: lm.currentLanguage)) · \(project.medium.displayName(lang: lm.currentLanguage))")
                    .font(.caption)
                    .foregroundColor(.inkTertiary)
                    .lineLimit(1)

                HStack(spacing: DG.Space.s) {
                    ProgressView(value: project.progress)
                        .tint(isDone ? .progressTeal : .brand)
                    Text("\(project.completedCount)/\(project.totalCount)")
                        .font(.caption2.monospacedDigit())
                        .foregroundColor(.inkSecondary)
                }
            }

            Spacer(minLength: DG.Space.s)

            // Big rounded numeral — the app's most-seen character
            if isDone {
                Image(systemName: "checkmark.circle.fill")
                    .font(.title2)
                    .foregroundColor(.progressTeal)
                    .transition(.scale.combined(with: .opacity))
                    .accessibilityLabel(lm.currentLanguage == "ru" ? "Готово" : "Done")
            } else {
                HStack(alignment: .firstTextBaseline, spacing: 1) {
                    Text("\(percent)")
                        .font(.numeral(26, weight: .light))
                        .foregroundColor(.ink)
                        .monospacedDigit()
                    Text("%")
                        .font(.numeral(12, weight: .medium))
                        .foregroundColor(.inkTertiary)
                }
                .accessibilityLabel("\(percent)%")
            }
        }
        .padding(.vertical, DG.Space.m)
        .padding(.horizontal, DG.Space.m)
        .glassCard(radius: DG.Radius.m + 2)
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .animation(DGMotion.press, value: isPressed)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
    }
}

private struct ThumbnailView: View {
    let project: ArtProject
    @ObservedObject private var store: ProjectStore = .shared
    @State private var image: UIImage?

    var body: some View {
        Group {
            if let img = image {
                Image(uiImage: img)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .transition(.opacity.combined(with: .scale(scale: 0.9)))
            } else {
                Color.white.opacity(0.40)
                    .overlay(
                        Image(systemName: "photo")
                            .foregroundColor(.inkTertiary)
                            .font(.title3)
                    )
            }
        }
        .frame(width: 64, height: 64)
        .clipShape(RoundedRectangle(cornerRadius: DG.Radius.s, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: DG.Radius.s, style: .continuous)
                .strokeBorder(Color.glassEdge, lineWidth: 1)
        )
        .onAppear {
            if image == nil {
                DispatchQueue.global(qos: .userInteractive).async {
                    let img = store.loadDisplayImage(for: project)
                    DispatchQueue.main.async {
                        withAnimation(.easeOut(duration: 0.3)) {
                            self.image = img
                        }
                    }
                }
            }
        }
    }
}

// MARK: - New Project Sheet

private struct NewProjectSheet: View {
    var onComplete: (ArtProject) -> Void

    @EnvironmentObject var lm: LocalizationManager
    @Environment(\.dismiss) var dismiss
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var step: Step = .pickImage
    @State private var selectedImage: UIImage?
    @State private var photoPickerItem: PhotosPickerItem?
    @State private var showPhotoPicker = false
    @State private var isLoadingPhoto = false
    @State private var projectName: String = ""
    @State private var selectedStyle: DrawingStyle = .none
    @State private var selectedMedium: DrawingMedium = .brush
    @State private var gridRows: Int = 16
    @State private var gridCols: Int = 16
    @State private var selectedPaperSize: PaperSize = .a4
    @State private var selectedSkillLevel: SkillLevel = .intermediate
    @State private var errorMessage: String?
    @State private var showError = false

    enum Step: Int { case pickImage, configure, processing }
    private var isRU: Bool { lm.currentLanguage == "ru" }

    var body: some View {
        NavigationStack {
            ZStack {
                MistBackground()

                // Animated content switching with directional slide
                ZStack {
                    if step == .pickImage {
                        photoPickStep
                            .transition(.asymmetric(
                                insertion: .move(edge: .leading).combined(with: .opacity),
                                removal: .move(edge: .leading).combined(with: .opacity)
                            ))
                    }
                    if step == .configure {
                        StyleSelectionView(
                            image: selectedImage ?? UIImage(),
                            projectName: $projectName,
                            selectedStyle: $selectedStyle,
                            selectedMedium: $selectedMedium,
                            gridRows: $gridRows,
                            gridCols: $gridCols,
                            selectedPaperSize: $selectedPaperSize,
                            selectedSkillLevel: $selectedSkillLevel,
                            onGenerate: {
                                withAnimation(reduceMotion ? nil : DGMotion.spring) {
                                    step = .processing
                                }
                            }
                        )
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .move(edge: .trailing).combined(with: .opacity)
                        ))
                    }
                    if step == .processing, let image = selectedImage {
                        ProcessingView(
                            image: image,
                            style: selectedStyle,
                            medium: selectedMedium,
                            gridRows: gridRows,
                            gridCols: gridCols,
                            projectName: projectName,
                            paperSize: selectedPaperSize,
                            skillLevel: selectedSkillLevel,
                            onComplete: { project in onComplete(project) },
                            onError: { msg in
                                errorMessage = msg
                                showError = true
                                withAnimation(reduceMotion ? nil : DGMotion.spring) {
                                    step = .configure
                                }
                            },
                            onCancel: {
                                withAnimation(reduceMotion ? nil : DGMotion.spring) {
                                    step = .configure
                                }
                            }
                        )
                        .transition(.opacity)
                        .navigationBarTitleDisplayMode(.inline)
                        .interactiveDismissDisabled()
                    }
                }
                .animation(DGMotion.spring, value: step)
            }
            .navigationTitle(stepTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.light, for: .navigationBar)
            .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    if step != .processing {
                        Button {
                            if step == .configure {
                                withAnimation(reduceMotion ? nil : DGMotion.spring) {
                                    selectedImage = nil
                                    step = .pickImage
                                }
                            } else {
                                dismiss()
                            }
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: step == .configure ? "chevron.left" : "xmark")
                                    .font(.system(size: 14, weight: .semibold))
                                Text(step == .configure ? (isRU ? "Фото" : "Photo") : (isRU ? "Закрыть" : "Close"))
                                    .font(.subheadline)
                            }
                            .foregroundColor(.inkSecondary)
                        }
                    }
                }

                // Step indicator
                ToolbarItem(placement: .principal) {
                    if step != .processing {
                        StepIndicator(current: step.rawValue, total: 2)
                    }
                }
            }
        }
        .photosPicker(isPresented: $showPhotoPicker, selection: $photoPickerItem, matching: .images)
        .onChange(of: photoPickerItem) { item in
            guard let item else { return }
            isLoadingPhoto = true
            Task {
                if let data = try? await item.loadTransferable(type: Data.self),
                   let uiImage = UIImage(data: data) {
                    await MainActor.run {
                        withAnimation(reduceMotion ? nil : .spring(response: 0.5, dampingFraction: 0.75)) {
                            selectedImage = uiImage.normalized()
                            isLoadingPhoto = false
                        }
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    }
                } else {
                    await MainActor.run { isLoadingPhoto = false }
                }
            }
        }
        .alert(lm.t("error.api"), isPresented: $showError, actions: {
            Button(lm.t("error.ok"), role: .cancel) {}
        }, message: {
            Text(errorMessage ?? "")
        })
    }

    private var stepTitle: String {
        switch step {
        case .pickImage:  return isRU ? "Новый проект" : "New Project"
        case .configure:  return isRU ? "Настройки" : "Configure"
        case .processing: return lm.t("processing.title")
        }
    }

    // MARK: - Photo pick step

    private var photoPickStep: some View {
        VStack(spacing: 0) {
            Spacer()

            if isLoadingPhoto {
                VStack(spacing: 20) {
                    ProgressView().tint(.brand).scaleEffect(1.5)
                    Text(isRU ? "Загрузка..." : "Loading...")
                        .font(.subheadline)
                        .foregroundColor(.inkSecondary)
                }
                .transition(.opacity)
            } else if let img = selectedImage {
                // Photo preview state
                photoPreview(img)
                    .transition(.scale(scale: 0.92).combined(with: .opacity))
            } else {
                // Choose photo state
                photoWelcome
                    .transition(.opacity)
            }

            Spacer()
        }
        .padding(.horizontal, DG.Space.l)
        .animation(DGMotion.spring, value: selectedImage == nil)
        .animation(.easeOut(duration: 0.2), value: isLoadingPhoto)
    }

    private var photoWelcome: some View {
        VStack(spacing: DG.Space.xl + 4) {
            // Hero visual
            ZStack {
                RoundedRectangle(cornerRadius: DG.Radius.l, style: .continuous)
                    .fill(Color.clear)
                    .frame(width: 180, height: 180)
                    .glassCard(radius: DG.Radius.l)

                VStack(spacing: 14) {
                    Image(systemName: "photo.on.rectangle.angled")
                        .font(.system(size: 52, weight: .light))
                        .foregroundColor(.brand)
                    Text(isRU ? "Ваше фото" : "Your photo")
                        .font(.caption.weight(.medium))
                        .foregroundColor(.inkSecondary)
                }
            }

            // Text
            VStack(spacing: 10) {
                Text(isRU ? "Выберите фото" : "Choose a photo")
                    .font(.display(24, weight: .semibold))
                    .foregroundColor(.ink)
                Text(isRU
                     ? "Мы разобьём его на сетку\nи поможем нарисовать"
                     : "We'll split it into a grid\nso you can draw it square by square")
                    .font(.subheadline)
                    .foregroundColor(.inkSecondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(3)
            }

            // CTA
            Button {
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                showPhotoPicker = true
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: "photo.stack")
                        .font(.headline)
                    Text(isRU ? "Выбрать из галереи" : "Choose from Gallery")
                        .font(.display(16, weight: .semibold))
                }
                .foregroundColor(.ink)
                .frame(maxWidth: .infinity)
                .frame(minHeight: 54)
            }
            .buttonStyle(GlassCTAStyle())
        }
    }

    @ViewBuilder
    private func photoPreview(_ img: UIImage) -> some View {
        VStack(spacing: DG.Space.l + 4) {
            // Photo
            Image(uiImage: img)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(maxWidth: .infinity)
                .frame(height: 260)
                .clipped()
                .clipShape(RoundedRectangle(cornerRadius: DG.Radius.m, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: DG.Radius.m, style: .continuous)
                        .strokeBorder(Color.glassEdge, lineWidth: 1)
                )
                .shadow(color: Color.glassShadow.opacity(0.22), radius: 20, x: 0, y: 10)

            // Success indicator
            HStack(spacing: DG.Space.s) {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.progressTeal)
                Text(isRU ? "Фото выбрано" : "Photo selected")
                    .font(.subheadline.weight(.medium))
                    .foregroundColor(.inkSecondary)
            }

            // Actions
            VStack(spacing: 12) {
                Button {
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    withAnimation(reduceMotion ? nil : DGMotion.spring) {
                        step = .configure
                    }
                } label: {
                    HStack(spacing: DG.Space.s) {
                        Text(isRU ? "Продолжить" : "Continue")
                            .font(.display(16, weight: .semibold))
                        Image(systemName: "arrow.right")
                            .font(.headline)
                    }
                    .foregroundColor(.ink)
                    .frame(maxWidth: .infinity)
                    .frame(minHeight: 54)
                }
                .buttonStyle(GlassCTAStyle())

                Button {
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    withAnimation(reduceMotion ? nil : .spring(response: 0.35, dampingFraction: 0.8)) {
                        selectedImage = nil
                        photoPickerItem = nil
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        showPhotoPicker = true
                    }
                } label: {
                    Text(isRU ? "Выбрать другое фото" : "Choose different photo")
                        .font(.subheadline)
                        .foregroundColor(.inkSecondary)
                        .padding(.vertical, 10)
                        .frame(minHeight: DG.touchTarget)
                }
            }
        }
    }
}

// MARK: - Step indicator dots

private struct StepIndicator: View {
    let current: Int
    let total: Int

    var body: some View {
        HStack(spacing: 6) {
            ForEach(0...total, id: \.self) { idx in
                Capsule()
                    .fill(idx == current ? Color.ink : Color.glassEdge)
                    .frame(width: idx == current ? 20 : 6, height: 6)
                    .animation(DGMotion.press, value: current)
            }
        }
    }
}
