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

    /// The project the user most likely wants to resume:
    /// newest in-progress one, or the newest overall if all are complete.
    private var continueProject: ArtProject? {
        store.projects.first(where: { $0.progress < 1 }) ?? store.projects.first
    }

    var body: some View {
        NavigationStack {
            ZStack {
                MistBackground()

                Group {
                    if store.projects.isEmpty {
                        emptyState
                    } else {
                        returningState
                    }
                }
            }
            .navigationTitle("DrawGrid AI")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.light, for: .navigationBar)
            .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    if !store.projects.isEmpty {
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

    // MARK: - Empty state — the promise

    private var emptyState: some View {
        GeometryReader { geo in
            let compact = geo.size.height < 660

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {

                    // Hero: bright + ghost headline in the deep mist band
                    VStack(alignment: .leading, spacing: DG.Space.m - 4) {
                        (
                            Text(isRU ? "Любое фото станет " : "Any photo becomes ")
                                .foregroundColor(.mistText)
                            + Text(isRU ? "рисунком — вашими руками" : "art you draw by hand")
                                .foregroundColor(.mistTextGhost)
                        )
                        .font(.system(.largeTitle, design: .rounded, weight: .semibold))
                        .lineSpacing(3)
                        .minimumScaleFactor(0.8)
                        .fixedSize(horizontal: false, vertical: true)

                        Text(isRU
                             ? "Сетка разбивает картинку на простые клетки — вы переносите их на бумагу одну за другой."
                             : "A grid breaks the image into simple squares — you redraw them on paper, one at a time.")
                            .font(.subheadline)
                            .foregroundColor(.mistTextSoft)
                            .lineSpacing(4)
                            .frame(maxWidth: 300, alignment: .leading)
                    }
                    .padding(.horizontal, DG.Space.margin + 8)
                    .padding(.top, DG.Space.l)
                    .heroEntrance(appeared: listAppeared, reduceMotion: reduceMotion, delay: 0.05)

                    // The one visual: the method itself as a paper sheet
                    HStack {
                        Spacer()
                        PaperGridMotif()
                            .frame(width: compact
                                   ? min(geo.size.width * 0.32, 130)
                                   : min(geo.size.width * 0.46, 190))
                        Spacer()
                    }
                    .padding(.top, compact ? DG.Space.m : DG.Space.l)
                    .padding(.bottom, compact ? DG.Space.m : DG.Space.l + 4)
                    .heroEntrance(appeared: listAppeared, reduceMotion: reduceMotion, delay: 0.18)

                    // Primary action
                    DGPrimaryButton(
                        title: isRU ? "Создать работу" : "Create New Artwork",
                        systemImage: "plus"
                    ) {
                        showNewProject = true
                    }
                    .padding(.horizontal, DG.Space.margin)
                    .heroEntrance(appeared: listAppeared, reduceMotion: reduceMotion, delay: 0.30)

                    Text(isRU
                         ? "Бумага и карандаш — всё, что нужно"
                         : "All you need is paper and a pencil")
                        .font(.footnote)
                        .foregroundColor(.ink)
                        .frame(maxWidth: .infinity)
                        .padding(.top, DG.Space.s + 2)
                        .heroEntrance(appeared: listAppeared, reduceMotion: reduceMotion, delay: 0.34)

                    // The method, named — three quiet steps
                    VStack(spacing: DG.Space.m) {
                        ForEach(Array(processSteps.enumerated()), id: \.offset) { idx, step in
                            HStack(alignment: .firstTextBaseline, spacing: DG.Space.m) {
                                Text("\(idx + 1)")
                                    .dgNumeral(26)
                                    .foregroundColor(.brand)
                                    .frame(width: 26, alignment: .center)
                                VStack(alignment: .leading, spacing: 1) {
                                    Text(step.label).dgCardTitle()
                                    Text(step.detail).dgCaption()
                                }
                                Spacer(minLength: 0)
                            }
                        }
                    }
                    .padding(DG.Space.l - 4)
                    .dgGlassCard(radius: DG.Radius.l)
                    .padding(.horizontal, DG.Space.margin)
                    .padding(.top, DG.Space.xl)
                    .heroEntrance(appeared: listAppeared, reduceMotion: reduceMotion, delay: 0.42)

                    Spacer(minLength: DG.Space.xl)
                }
            }
        }
        .onAppear { listAppeared = true }
        .onDisappear { listAppeared = false }
    }

    private var processSteps: [(label: String, detail: String)] {
        isRU
            ? [(label: "Загрузите фото",     detail: "Из галереи или камеры"),
               (label: "Выберите стиль",     detail: "Акварель, карандаш, масло…"),
               (label: "Рисуйте по клеткам", detail: "Спокойно, клетка за клеткой")]
            : [(label: "Upload a photo",     detail: "From your library or camera"),
               (label: "Pick a style",       detail: "Watercolor, pencil, oil…"),
               (label: "Draw by square",     detail: "Calmly, one cell at a time")]
    }

    // MARK: - Returning state — continue is king

    private var returningState: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {

                // Dominant: resume the last work
                if let project = continueProject {
                    ContinueCard(project: project, lm: lm) {
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        activeProject = project
                        navigateToProject = true
                    }
                    .padding(.horizontal, DG.Space.m)
                    .padding(.top, DG.Space.l)
                    .heroEntrance(appeared: listAppeared, reduceMotion: reduceMotion, delay: 0.02)
                }

                // Second intent: start something new
                DGPrimaryButton(
                    title: isRU ? "Создать работу" : "Create New Artwork",
                    systemImage: "plus"
                ) {
                    showNewProject = true
                }
                .padding(.horizontal, DG.Space.m)
                .padding(.top, DG.Space.m - 4)
                .heroEntrance(appeared: listAppeared, reduceMotion: reduceMotion, delay: 0.10)

                // Archive — the continue project lives in the card above, not here
                if store.projects.count > 1 {
                    Text(isRU ? "Недавние" : "Recent")
                        .dgSectionTitle()
                        .padding(.horizontal, DG.Space.margin)
                        .padding(.top, DG.Space.xl)
                        .padding(.bottom, DG.Space.m - 4)
                }

                LazyVStack(spacing: DG.Space.m - 4) {
                    ForEach(Array($store.projects.enumerated()), id: \.element.id) { idx, $project in
                        if project.id != continueProject?.id {
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
                            .heroEntrance(
                                appeared: listAppeared,
                                reduceMotion: reduceMotion,
                                delay: 0.16 + Double(idx) * 0.05
                            )
                        }
                    }
                }
                .padding(.horizontal, DG.Space.m)

                Spacer(minLength: DG.Space.xl)
            }
        }
        .onAppear { listAppeared = true }
        .onDisappear { listAppeared = false }
    }
}

// MARK: - Entrance helper

private extension View {
    /// Staggered rise-in that collapses to a fade under Reduce Motion.
    @ViewBuilder
    func heroEntrance(appeared: Bool, reduceMotion: Bool, delay: Double) -> some View {
        self
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared || reduceMotion ? 0 : 16)
            .animation(
                reduceMotion ? .easeOut(duration: 0.15) : DGMotion.entrance(delay: delay),
                value: appeared
            )
    }
}

/// Press feedback for large tappable cards.
private struct PressScaleStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(DGMotion.press, value: configuration.isPressed)
    }
}

// MARK: - Paper grid motif — the method, drawn

/// The product's identity visual: a sheet of paper with a drawing grid,
/// a few squares already done. Geometric, token-colored, no decoration.
private struct PaperGridMotif: View {
    private let cols = 4
    private let rows = 5
    /// (row, col) cells that read as "already drawn"
    private let doneCells: Set<[Int]> = [[0, 0], [0, 1], [1, 0]]
    /// The cell the artist is "on" right now
    private let currentCell = [1, 1]

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            let cellW = w / CGFloat(cols)
            let cellH = h / CGFloat(rows)

            ZStack {
                // Completed cells — quiet teal wash
                ForEach(Array(doneCells), id: \.self) { cell in
                    Rectangle()
                        .fill(Color.progressTeal.opacity(0.22))
                        .frame(width: cellW, height: cellH)
                        .position(
                            x: cellW * (CGFloat(cell[1]) + 0.5),
                            y: cellH * (CGFloat(cell[0]) + 0.5)
                        )
                }

                // Current cell — solid white focus with pencil
                Rectangle()
                    .fill(Color.white.opacity(0.85))
                    .overlay(
                        Image(systemName: "pencil")
                            .font(.system(size: min(cellW, cellH) * 0.42, weight: .medium))
                            .foregroundColor(.brand)
                    )
                    .frame(width: cellW, height: cellH)
                    .position(
                        x: cellW * (CGFloat(currentCell[1]) + 0.5),
                        y: cellH * (CGFloat(currentCell[0]) + 0.5)
                    )

                // Grid lines
                Path { path in
                    for c in 1..<cols {
                        let x = cellW * CGFloat(c)
                        path.move(to: CGPoint(x: x, y: 0))
                        path.addLine(to: CGPoint(x: x, y: h))
                    }
                    for r in 1..<rows {
                        let y = cellH * CGFloat(r)
                        path.move(to: CGPoint(x: 0, y: y))
                        path.addLine(to: CGPoint(x: w, y: y))
                    }
                }
                .stroke(Color.ink.opacity(0.22), lineWidth: 1)
            }
        }
        .aspectRatio(1 / 1.414, contentMode: .fit) // A-series paper
        .background(.ultraThinMaterial)
        .background(Color.white.opacity(0.55))
        .clipShape(RoundedRectangle(cornerRadius: DG.Radius.s, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: DG.Radius.s, style: .continuous)
                .strokeBorder(Color.white.opacity(0.9), lineWidth: 1)
        )
        .rotationEffect(.degrees(-2))
        .shadow(color: Color.glassShadow.opacity(0.22), radius: 20, x: 0, y: 10)
        .accessibilityHidden(true)
    }
}

// MARK: - Continue card — dominant element for returning users

private struct ContinueCard: View {
    let project: ArtProject
    let lm: LocalizationManager
    let action: () -> Void

    @ObservedObject private var store: ProjectStore = .shared
    @State private var image: UIImage?

    private var isRU: Bool { lm.currentLanguage == "ru" }
    private var isDone: Bool { project.progress >= 1 }
    private var percent: Int { Int((project.progress * 100).rounded()) }

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: DG.Space.m) {
                Text(isDone
                     ? (isRU ? "Завершено" : "Completed")
                     : (isRU ? "Продолжить" : "Continue"))
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundColor(isDone ? .progressTeal : .brand)

                HStack(spacing: DG.Space.m) {
                    // Artwork thumb — the deepest shadow on screen belongs to the art
                    Group {
                        if let img = image {
                            Image(uiImage: img)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        } else {
                            Color.white.opacity(0.40)
                                .overlay(
                                    Image(systemName: "photo")
                                        .foregroundColor(.inkTertiary)
                                )
                        }
                    }
                    .frame(width: 84, height: 84)
                    .clipShape(RoundedRectangle(cornerRadius: DG.Radius.s, style: .continuous))
                    .shadow(color: Color.glassShadow.opacity(0.22), radius: 12, x: 0, y: 6)

                    VStack(alignment: .leading, spacing: 5) {
                        Text(project.name)
                            .dgCardTitle()
                            .lineLimit(1)
                        Text(isRU
                             ? "\(project.completedCount) из \(project.totalCount) клеток"
                             : "\(project.completedCount) of \(project.totalCount) squares")
                            .dgCaption()
                        ProgressView(value: project.progress)
                            .tint(isDone ? .progressTeal : .brand)
                    }

                    Spacer(minLength: DG.Space.s)

                    if isDone {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 30))
                            .foregroundColor(.progressTeal)
                    } else {
                        HStack(alignment: .firstTextBaseline, spacing: 1) {
                            Text("\(percent)").dgNumeral(38)
                            Text("%")
                                .dgNumeral(15, weight: .medium)
                                .foregroundColor(.inkTertiary)
                        }
                    }
                }
            }
            .padding(DG.Space.l - 4)
            .frame(maxWidth: .infinity, alignment: .leading)
            .dgGlassCard(radius: DG.Radius.l)
        }
        .buttonStyle(PressScaleStyle())
        .accessibilityLabel(
            isRU
                ? "Продолжить \(project.name), готово \(percent) процентов"
                : "Continue \(project.name), \(percent) percent done"
        )
        .onAppear {
            if image == nil {
                DispatchQueue.global(qos: .userInteractive).async {
                    let img = store.loadDisplayImage(for: project)
                    DispatchQueue.main.async {
                        withAnimation(.easeOut(duration: 0.3)) { self.image = img }
                    }
                }
            }
        }
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
                    .dgCardTitle()
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

            if isDone {
                Image(systemName: "checkmark.circle.fill")
                    .font(.title2)
                    .foregroundColor(.progressTeal)
                    .accessibilityLabel(lm.currentLanguage == "ru" ? "Готово" : "Done")
            } else {
                HStack(alignment: .firstTextBaseline, spacing: 1) {
                    Text("\(percent)").dgNumeral(26)
                    Text("%")
                        .dgNumeral(12, weight: .medium)
                        .foregroundColor(.inkTertiary)
                }
                .accessibilityLabel("\(percent)%")
            }
        }
        .padding(.vertical, DG.Space.m)
        .padding(.horizontal, DG.Space.m)
        .dgGlassCard(radius: DG.Radius.m)
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

// MARK: - Previews

#if DEBUG
private func mockProject(name: String, done: Int, of total: Int = 256) -> ArtProject {
    var p = ArtProject(name: name, style: .watercolor, medium: .brush, gridRows: 16, gridCols: 16)
    for i in 0..<min(done, total) {
        p.squares[i].isCompleted = true
    }
    return p
}

#Preview("Home — Empty") {
    HomeView()
        .environmentObject(LocalizationManager.shared)
}

#Preview("Continue Card + Row") {
    ZStack {
        MistBackground()
        VStack(spacing: 16) {
            ContinueCard(project: mockProject(name: "Mountain Lake", done: 96), lm: .shared) {}
            ProjectRow(project: .constant(mockProject(name: "Portrait of Anna", done: 256)), lm: .shared)
            ProjectRow(project: .constant(mockProject(name: "Old Harbour", done: 31)), lm: .shared)
        }
        .padding(16)
    }
}

#Preview("Paper Motif") {
    ZStack {
        MistBackground()
        PaperGridMotif()
            .frame(width: 190)
    }
}
#endif

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
