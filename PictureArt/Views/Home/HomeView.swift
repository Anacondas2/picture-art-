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

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient.appBg.ignoresSafeArea()

                Group {
                    if store.projects.isEmpty {
                        emptyState
                    } else {
                        projectList
                    }
                }
            }
            .navigationTitle(lm.t("home.title"))
            .toolbarColorScheme(.dark, for: .navigationBar)
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
                                .fill(Color.brand.opacity(0.15))
                                .frame(width: 34, height: 34)
                            Image(systemName: "plus")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(.brand)
                        }
                    }
                }
                ToolbarItem(placement: .topBarLeading) {
                    NavigationLink {
                        SettingsView().environmentObject(lm)
                    } label: {
                        Image(systemName: "gearshape")
                            .foregroundColor(.labelSecondary)
                    }
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

    // MARK: - Empty state

    private var emptyState: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: 32) {
                // Animated hero icon
                ZStack {
                    Circle()
                        .fill(Color.brand.opacity(0.08))
                        .frame(width: 120, height: 120)
                        .blur(radius: 8)
                    Circle()
                        .fill(Color.brand.opacity(0.06))
                        .frame(width: 80, height: 80)
                    Image(systemName: "paintbrush.pointed.fill")
                        .font(.system(size: 36, weight: .medium))
                        .foregroundColor(.brand)
                        .shadow(color: .brand.opacity(0.5), radius: 12)
                }
                .opacity(listAppeared ? 1 : 0)
                .scaleEffect(listAppeared ? 1 : 0.6)
                .animation(reduceMotion ? nil : .spring(response: 0.6, dampingFraction: 0.7).delay(0.1), value: listAppeared)

                // How it works
                VStack(spacing: 6) {
                    Text(lm.currentLanguage == "ru" ? "Как это работает" : "How it works")
                        .font(.caption)
                        .foregroundColor(.labelTertiary)
                        .textCase(.uppercase)
                        .tracking(1.2)

                    HStack(spacing: 0) {
                        ForEach(Array(emptyStateSteps.enumerated()), id: \.offset) { idx, step in
                            VStack(spacing: 8) {
                                ZStack {
                                    Circle()
                                        .fill(Color.brand.opacity(0.12))
                                        .frame(width: 52, height: 52)
                                        .shadow(color: .brand.opacity(0.2), radius: 8, x: 0, y: 4)
                                    Image(systemName: step.icon)
                                        .font(.system(size: 22, weight: .medium))
                                        .foregroundColor(.brand)
                                }
                                Text(step.label)
                                    .font(.caption2)
                                    .foregroundColor(.labelSecondary)
                                    .multilineTextAlignment(.center)
                                    .frame(width: 72)
                            }
                            .opacity(listAppeared ? 1 : 0)
                            .offset(y: listAppeared ? 0 : 20)
                            .animation(
                                reduceMotion ? nil :
                                    .spring(response: 0.5, dampingFraction: 0.8).delay(0.2 + Double(idx) * 0.08),
                                value: listAppeared
                            )

                            if idx < emptyStateSteps.count - 1 {
                                Image(systemName: "chevron.right")
                                    .font(.caption2)
                                    .foregroundColor(.labelTertiary)
                                    .padding(.bottom, 20)
                                    .opacity(listAppeared ? 1 : 0)
                                    .animation(reduceMotion ? nil : .easeOut(duration: 0.3).delay(0.3), value: listAppeared)
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 24)
                .glassCard(radius: 20)
                .padding(.horizontal, 28)
                .opacity(listAppeared ? 1 : 0)
                .animation(reduceMotion ? nil : .easeOut(duration: 0.4).delay(0.15), value: listAppeared)

                // CTA
                VStack(spacing: 10) {
                    Button {
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        showNewProject = true
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "plus")
                                .font(.headline)
                            Text(lm.t("home.newProject"))
                                .font(.headline)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                    }
                    .buttonStyle(GlassCTAStyle())
                    .padding(.horizontal, 32)

                    Text(lm.currentLanguage == "ru"
                         ? "Загрузите фото и начните рисовать"
                         : "Upload a photo and start drawing")
                        .font(.footnote)
                        .foregroundColor(.labelTertiary)
                }
                .opacity(listAppeared ? 1 : 0)
                .offset(y: listAppeared ? 0 : 16)
                .animation(reduceMotion ? nil : .spring(response: 0.5, dampingFraction: 0.85).delay(0.45), value: listAppeared)
            }

            Spacer()
        }
        .onAppear { listAppeared = true }
        .onDisappear { listAppeared = false }
    }

    private var emptyStateSteps: [(icon: String, label: String)] {
        lm.currentLanguage == "ru"
            ? [(icon: "photo.on.rectangle", label: "Загрузить\nфото"),
               (icon: "sparkles", label: "Выбрать\nстиль"),
               (icon: "grid", label: "Рисовать\nпо сетке")]
            : [(icon: "photo.on.rectangle", label: "Upload\nphoto"),
               (icon: "sparkles", label: "Pick a\nstyle"),
               (icon: "grid", label: "Draw\nby square")]
    }

    // MARK: - Project list

    private var projectList: some View {
        ScrollView {
            LazyVStack(spacing: 10) {
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
                        .offset(y: listAppeared ? 0 : 30)
                        .animation(
                            reduceMotion ? nil :
                                .spring(response: 0.5, dampingFraction: 0.85).delay(Double(idx) * 0.07),
                            value: listAppeared
                        )
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
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

    var body: some View {
        HStack(spacing: 14) {
            ThumbnailView(project: project)

            VStack(alignment: .leading, spacing: 6) {
                Text(project.name)
                    .font(.headline)
                    .foregroundColor(.labelPrimary)
                    .lineLimit(1)

                HStack(spacing: 6) {
                    Text(project.style.displayName(lang: lm.currentLanguage))
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(Color.brand.opacity(0.15))
                        .foregroundColor(.brandLight)
                        .clipShape(Capsule())

                    Text(project.medium.displayName(lang: lm.currentLanguage))
                        .font(.caption)
                        .foregroundColor(.labelSecondary)
                }

                HStack(spacing: 8) {
                    ProgressView(value: project.progress)
                        .tint(project.progress >= 1 ? .green : .brand)
                    Text("\(project.completedCount)/\(project.totalCount)")
                        .font(.caption2.monospacedDigit())
                        .foregroundColor(.labelSecondary)
                }
            }

            Spacer()

            if project.progress >= 1 {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
                    .font(.title3)
                    .transition(.scale.combined(with: .opacity))
            } else {
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.labelTertiary)
            }
        }
        .padding(.vertical, 14)
        .padding(.horizontal, 14)
        .glassCard(radius: 18)
        .scaleEffect(isPressed ? 0.97 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isPressed)
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
                Color.bgSurface
                    .overlay(
                        Image(systemName: "photo")
                            .foregroundColor(.labelTertiary)
                            .font(.title3)
                    )
            }
        }
        .frame(width: 72, height: 72)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.glassBorder, lineWidth: 0.5)
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
                LinearGradient.appBg.ignoresSafeArea()

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
                                withAnimation(reduceMotion ? nil : .spring(response: 0.45, dampingFraction: 0.85)) {
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
                                withAnimation(reduceMotion ? nil : .spring(response: 0.45, dampingFraction: 0.85)) {
                                    step = .configure
                                }
                            },
                            onCancel: {
                                withAnimation(reduceMotion ? nil : .spring(response: 0.45, dampingFraction: 0.85)) {
                                    step = .configure
                                }
                            }
                        )
                        .transition(.opacity)
                        .navigationBarTitleDisplayMode(.inline)
                        .interactiveDismissDisabled()
                    }
                }
                .animation(.spring(response: 0.45, dampingFraction: 0.85), value: step)
            }
            .navigationTitle(stepTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    if step != .processing {
                        Button {
                            if step == .configure {
                                withAnimation(reduceMotion ? nil : .spring(response: 0.45, dampingFraction: 0.85)) {
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
                            .foregroundColor(.labelSecondary)
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
                        .foregroundColor(.labelSecondary)
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
        .padding(.horizontal, 24)
        .animation(.spring(response: 0.45, dampingFraction: 0.8), value: selectedImage == nil)
        .animation(.easeOut(duration: 0.2), value: isLoadingPhoto)
    }

    private var photoWelcome: some View {
        VStack(spacing: 36) {
            // Hero visual
            ZStack {
                RoundedRectangle(cornerRadius: 28)
                    .fill(Color.glassLight)
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 28))
                    .overlay(
                        RoundedRectangle(cornerRadius: 28)
                            .stroke(Color.glassBorder, lineWidth: 0.5)
                    )
                    .frame(width: 180, height: 180)
                    .shadow(color: .brand.opacity(0.12), radius: 20, x: 0, y: 10)

                VStack(spacing: 14) {
                    Image(systemName: "photo.on.rectangle.angled")
                        .font(.system(size: 52, weight: .light))
                        .foregroundColor(.brand)
                        .shadow(color: .brand.opacity(0.4), radius: 12)
                    Text(isRU ? "Ваше фото" : "Your photo")
                        .font(.caption.weight(.medium))
                        .foregroundColor(.labelSecondary)
                }
            }

            // Text
            VStack(spacing: 10) {
                Text(isRU ? "Выберите фото" : "Choose a photo")
                    .font(.title2.bold())
                    .foregroundColor(.labelPrimary)
                Text(isRU
                     ? "Мы разобьём его на сетку\nи поможем нарисовать"
                     : "We'll split it into a grid\nso you can draw it square by square")
                    .font(.subheadline)
                    .foregroundColor(.labelSecondary)
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
                        .font(.headline)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
            }
            .buttonStyle(GlassCTAStyle())
        }
    }

    @ViewBuilder
    private func photoPreview(_ img: UIImage) -> some View {
        VStack(spacing: 28) {
            // Photo
            Image(uiImage: img)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(maxWidth: .infinity)
                .frame(height: 260)
                .clipped()
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.glassBorder, lineWidth: 0.5)
                )
                .shadow(color: .brand.opacity(0.2), radius: 20, x: 0, y: 10)

            // Success indicator
            HStack(spacing: 8) {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
                Text(isRU ? "Фото выбрано" : "Photo selected")
                    .font(.subheadline.weight(.medium))
                    .foregroundColor(.labelSecondary)
            }

            // Actions
            VStack(spacing: 12) {
                Button {
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    withAnimation(reduceMotion ? nil : .spring(response: 0.45, dampingFraction: 0.85)) {
                        step = .configure
                    }
                } label: {
                    HStack(spacing: 8) {
                        Text(isRU ? "Продолжить" : "Continue")
                            .font(.headline)
                        Image(systemName: "arrow.right")
                            .font(.headline)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
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
                        .foregroundColor(.labelSecondary)
                        .padding(.vertical, 10)
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
                    .fill(idx == current ? Color.brand : Color.glassBorder)
                    .frame(width: idx == current ? 20 : 6, height: 6)
                    .animation(.spring(response: 0.35, dampingFraction: 0.7), value: current)
            }
        }
    }
}
