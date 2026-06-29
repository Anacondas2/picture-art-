import SwiftUI

struct HomeView: View {
    @EnvironmentObject var lm: LocalizationManager
    @ObservedObject var store: ProjectStore = .shared

    @State private var showNewProject = false
    @State private var activeProject: ArtProject?
    @State private var navigateToProject = false
    @State private var projectToDelete: ArtProject?
    @State private var showDeleteConfirm = false

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
                        showNewProject = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title3)
                            .foregroundColor(.brand)
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
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
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

    private var emptyState: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: 28) {
                VStack(spacing: 6) {
                    Text(lm.currentLanguage == "ru" ? "Как это работает" : "How it works")
                        .font(.caption)
                        .foregroundColor(.labelTertiary)
                        .textCase(.uppercase)
                        .tracking(1.2)

                    HStack(spacing: 0) {
                        ForEach(emptyStateSteps, id: \.icon) { step in
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

                            if step.icon != emptyStateSteps.last?.icon {
                                Image(systemName: "chevron.right")
                                    .font(.caption2)
                                    .foregroundColor(.labelTertiary)
                                    .padding(.bottom, 20)
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 24)
                .glassCard(radius: 20)
                .padding(.horizontal, 32)

                VStack(spacing: 10) {
                    Button {
                        showNewProject = true
                    } label: {
                        Label(lm.t("home.newProject"), systemImage: "plus")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 15)
                    }
                    .buttonStyle(GlassCTAStyle())
                    .padding(.horizontal, 32)

                    Text(lm.currentLanguage == "ru"
                         ? "Загрузите фото и начните рисовать"
                         : "Upload a photo and start drawing")
                        .font(.footnote)
                        .foregroundColor(.labelTertiary)
                }
            }

            Spacer()
        }
    }

    private var emptyStateSteps: [(icon: String, label: String)] {
        lm.currentLanguage == "ru"
            ? [(icon: "photo", label: "Загрузить\nфото"),
               (icon: "sparkles", label: "Выбрать\nстиль"),
               (icon: "grid", label: "Рисовать\nпо сетке")]
            : [(icon: "photo", label: "Upload\nphoto"),
               (icon: "sparkles", label: "Pick a\nstyle"),
               (icon: "grid", label: "Draw\nsquare by square")]
    }

    private var projectList: some View {
        List {
            ForEach($store.projects) { $project in
                ProjectRow(project: $project, lm: lm)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        activeProject = project
                        navigateToProject = true
                    }
                    .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        Button(role: .destructive) {
                            projectToDelete = project
                            showDeleteConfirm = true
                        } label: {
                            Label(lm.t("home.delete"), systemImage: "trash")
                        }
                    }
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
    }
}

// MARK: - Project Row

private struct ProjectRow: View {
    @Binding var project: ArtProject
    let lm: LocalizationManager
    @ObservedObject private var store: ProjectStore = .shared

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
                        .background(Color.brand.opacity(0.18))
                        .foregroundColor(.brandLight)
                        .cornerRadius(6)

                    Text(project.medium.displayName(lang: lm.currentLanguage))
                        .font(.caption)
                        .foregroundColor(.labelSecondary)
                }

                HStack(spacing: 6) {
                    ProgressView(value: project.progress)
                        .tint(project.progress >= 1 ? .green : .brand)
                    Text("\(project.completedCount)/\(project.totalCount)")
                        .font(.caption2)
                        .foregroundColor(.labelSecondary)
                }
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 12)
        .glassCard(radius: 16)
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
            } else {
                Color.bgSurface
                    .overlay(Image(systemName: "photo").foregroundColor(.labelTertiary))
            }
        }
        .frame(width: 72, height: 72)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.glassBorder, lineWidth: 0.5)
        )
        .onAppear {
            if image == nil {
                image = store.loadDisplayImage(for: project)
            }
        }
    }
}

// MARK: - New Project Sheet

private struct NewProjectSheet: View {
    var onComplete: (ArtProject) -> Void

    @EnvironmentObject var lm: LocalizationManager
    @Environment(\.dismiss) var dismiss

    @State private var step: Step = .pickImage
    @State private var selectedImage: UIImage?
    @State private var projectName: String = ""
    @State private var selectedStyle: DrawingStyle = .none
    @State private var selectedMedium: DrawingMedium = .brush
    @State private var gridRows: Int = 16
    @State private var gridCols: Int = 16
    @State private var selectedPaperSize: PaperSize = .a4
    @State private var selectedSkillLevel: SkillLevel = .intermediate
    @State private var errorMessage: String?
    @State private var showError = false

    enum Step { case pickImage, configure, processing }

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient.appBg.ignoresSafeArea()

                switch step {
                case .pickImage:
                    ImagePickerView(selectedImage: $selectedImage, onCancel: { dismiss() })
                        .ignoresSafeArea()
                        .onChange(of: selectedImage) { img in
                            if img != nil { step = .configure }
                        }
                        .navigationTitle(lm.t("newproject.choosePhoto"))
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbarColorScheme(.dark, for: .navigationBar)
                        .toolbar {
                            ToolbarItem(placement: .topBarLeading) {
                                Button(lm.t("error.cancel")) { dismiss() }
                                    .foregroundColor(.labelSecondary)
                            }
                        }

                case .configure:
                    if let image = selectedImage {
                        StyleSelectionView(
                            image: image,
                            projectName: $projectName,
                            selectedStyle: $selectedStyle,
                            selectedMedium: $selectedMedium,
                            gridRows: $gridRows,
                            gridCols: $gridCols,
                            selectedPaperSize: $selectedPaperSize,
                            selectedSkillLevel: $selectedSkillLevel,
                            onGenerate: { step = .processing }
                        )
                        .toolbarColorScheme(.dark, for: .navigationBar)
                        .toolbar {
                            ToolbarItem(placement: .topBarLeading) {
                                Button {
                                    selectedImage = nil
                                    step = .pickImage
                                } label: {
                                    Image(systemName: "chevron.left")
                                        .foregroundColor(.labelSecondary)
                                }
                            }
                        }
                    }

                case .processing:
                    if let image = selectedImage {
                        ProcessingView(
                            image: image,
                            style: selectedStyle,
                            medium: selectedMedium,
                            gridRows: gridRows,
                            gridCols: gridCols,
                            projectName: projectName,
                            paperSize: selectedPaperSize,
                            skillLevel: selectedSkillLevel,
                            onComplete: { project in
                                onComplete(project)
                            },
                            onError: { msg in
                                errorMessage = msg
                                showError = true
                                step = .configure
                            },
                            onCancel: {
                                step = .configure
                            }
                        )
                        .navigationTitle(lm.t("processing.title"))
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbarColorScheme(.dark, for: .navigationBar)
                        .interactiveDismissDisabled()
                    }
                }
            }
        }
        .alert(lm.t("error.api"), isPresented: $showError, actions: {
            Button(lm.t("error.ok"), role: .cancel) {}
        }, message: {
            Text(errorMessage ?? "")
        })
    }
}
