import SwiftUI

struct StyleSelectionView: View {
    let image: UIImage
    @Binding var projectName: String
    @Binding var selectedStyle: DrawingStyle
    @Binding var selectedMedium: DrawingMedium
    @Binding var gridRows: Int
    @Binding var gridCols: Int
    @Binding var selectedPaperSize: PaperSize
    @Binding var selectedSkillLevel: SkillLevel
    var onGenerate: () -> Void

    @EnvironmentObject var lm: LocalizationManager
    @ObservedObject private var store: ProjectStore = .shared

    private var availableMediums: [DrawingMedium] {
        selectedStyle == .none ? DrawingMedium.allCases : selectedStyle.compatibleMediums
    }

    private var cellDifficulty: PaperSize.CellDifficulty {
        selectedPaperSize.difficulty(rows: gridRows, cols: gridCols)
    }

    private var showApiKeyWarning: Bool {
        selectedStyle != .none && store.apiKey.isEmpty
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {

                // Preview thumbnail
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(maxWidth: .infinity)
                    .frame(height: 180)
                    .clipped()
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.glassBorder, lineWidth: 0.5)
                    )
                    .padding(.horizontal)

                // Project name
                VStack(alignment: .leading, spacing: 8) {
                    sectionLabel(lm.t("newproject.name"))
                    TextField(lm.t("newproject.namePlaceholder"), text: $projectName)
                        .foregroundColor(.labelPrimary)
                        .accentColor(.brand)
                        .padding(12)
                        .glassCard(radius: 10)
                        .padding(.horizontal)
                }

                // Skill level
                VStack(alignment: .leading, spacing: 12) {
                    sectionLabel(lm.t("style.skillLevel"))
                        .padding(.horizontal)

                    HStack(spacing: 10) {
                        ForEach(SkillLevel.allCases, id: \.self) { level in
                            SkillLevelCard(
                                level: level,
                                isSelected: selectedSkillLevel == level,
                                lang: lm.currentLanguage
                            ) {
                                selectedSkillLevel = level
                                gridRows = level.defaultGridSize
                                gridCols = level.defaultGridSize
                            }
                        }
                    }
                    .padding(.horizontal)
                }

                // Paper size
                VStack(alignment: .leading, spacing: 12) {
                    sectionLabel(lm.t("style.paperSize"))
                        .padding(.horizontal)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(PaperSize.allCases, id: \.self) { size in
                                PaperSizeCard(
                                    size: size,
                                    isSelected: selectedPaperSize == size,
                                    lang: lm.currentLanguage
                                ) {
                                    selectedPaperSize = size
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }

                // Style selection
                VStack(alignment: .leading, spacing: 12) {
                    sectionLabel(lm.t("style.title"))
                        .padding(.horizontal)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(selectedSkillLevel.allowedStyles, id: \.self) { style in
                                StyleCard(
                                    style: style,
                                    isSelected: selectedStyle == style,
                                    lang: lm.currentLanguage
                                ) {
                                    selectedStyle = style
                                    if !availableMediums.contains(selectedMedium) {
                                        selectedMedium = availableMediums.first ?? .brush
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }

                // API key warning
                if showApiKeyWarning {
                    HStack(spacing: 10) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.accentBlue)
                        Text(lm.t("style.apiKeyWarning"))
                            .font(.caption)
                            .foregroundColor(.labelSecondary)
                    }
                    .padding(12)
                    .glassCard(radius: 10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.accentBlue.opacity(0.4), lineWidth: 1)
                    )
                    .padding(.horizontal)
                }

                // Medium selection
                VStack(alignment: .leading, spacing: 12) {
                    sectionLabel(lm.t("style.medium"))
                        .padding(.horizontal)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(availableMediums, id: \.self) { medium in
                                MediumCard(
                                    medium: medium,
                                    isSelected: selectedMedium == medium,
                                    lang: lm.currentLanguage
                                ) {
                                    selectedMedium = medium
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }

                // Grid size
                VStack(alignment: .leading, spacing: 12) {
                    sectionLabel(lm.t("style.gridSize"))
                        .padding(.horizontal)

                    HStack(spacing: 8) {
                        let cellStr = selectedPaperSize.cellSizeComment(rows: gridRows, cols: gridCols, lang: lm.currentLanguage)
                        Image(systemName: "ruler")
                            .font(.caption)
                            .foregroundColor(.labelTertiary)
                        Text(cellStr)
                            .font(.caption)
                            .foregroundColor(.labelSecondary)
                        Spacer()
                        let diff = cellDifficulty
                        Text(diff.label(lang: lm.currentLanguage))
                            .font(.caption.bold())
                            .foregroundColor(difficultyColor(diff))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(difficultyColor(diff).opacity(0.15))
                            .cornerRadius(6)
                    }
                    .padding(.horizontal)

                    let recommended = Set(selectedSkillLevel.recommendedGridSizes).union(Set(selectedPaperSize.recommendedGridSizes))
                    let gridOptions = [8, 10, 12, 14, 16, 18, 20, 24, 32].filter { _ in true }

                    HStack(spacing: 16) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(lm.t("style.rows"))
                                .font(.subheadline)
                                .foregroundColor(.labelSecondary)
                            Picker("", selection: $gridRows) {
                                ForEach(gridOptions, id: \.self) { v in
                                    Text("\(v)\(recommended.contains(v) ? " ★" : "")").tag(v)
                                        .foregroundColor(.labelPrimary)
                                }
                            }
                            .pickerStyle(.wheel)
                            .frame(height: 80)
                            .clipped()
                            .colorScheme(.dark)
                        }
                        VStack(alignment: .leading, spacing: 4) {
                            Text(lm.t("style.cols"))
                                .font(.subheadline)
                                .foregroundColor(.labelSecondary)
                            Picker("", selection: $gridCols) {
                                ForEach(gridOptions, id: \.self) { v in
                                    Text("\(v)\(recommended.contains(v) ? " ★" : "")").tag(v)
                                        .foregroundColor(.labelPrimary)
                                }
                            }
                            .pickerStyle(.wheel)
                            .frame(height: 80)
                            .clipped()
                            .colorScheme(.dark)
                        }
                        Spacer()

                        VStack(spacing: 4) {
                            Text("\(gridRows)×\(gridCols)")
                                .font(.title.bold())
                                .foregroundColor(.brand)
                            Text("\(gridRows * gridCols)")
                                .font(.caption)
                                .foregroundColor(.labelSecondary)
                        }
                        .padding(.trailing)
                    }
                    .padding(.horizontal)
                }

                // Generate button
                Button(action: onGenerate) {
                    Text(lm.t("style.generate"))
                        .font(.headline)
                        .foregroundColor(.ink)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                }
                .buttonStyle(GlassCTAStyle())
                .padding(.horizontal)
                .padding(.bottom, 32)
            }
            .padding(.top)
        }
        .background(LinearGradient.appBg.ignoresSafeArea())
        .navigationTitle(lm.t("newproject.title"))
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.light, for: .navigationBar)
        .onAppear {
            if !availableMediums.contains(selectedMedium) {
                selectedMedium = availableMediums.first ?? .brush
            }
        }
    }

    private func sectionLabel(_ text: String) -> some View {
        Text(text)
            .font(.subheadline.weight(.semibold))
            .foregroundColor(.labelSecondary)
    }

    private func difficultyColor(_ diff: PaperSize.CellDifficulty) -> Color {
        switch diff {
        case .easy:   return .green
        case .medium: return Color(red: 0.4, green: 0.6, blue: 1.0)
        case .hard:   return Color(red: 1.0, green: 0.4, blue: 0.4)
        }
    }
}

// MARK: - Skill Level Card

private struct SkillLevelCard: View {
    let level: SkillLevel
    let isSelected: Bool
    let lang: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: level.icon)
                    .font(.title3)
                    .foregroundColor(isSelected ? .white : .brand)
                Text(level.displayName(lang: lang))
                    .font(.caption.bold())
                    .foregroundColor(isSelected ? .white : .labelPrimary)
                Text(level.description(lang: lang))
                    .font(.system(size: 10))
                    .foregroundColor(isSelected ? .white.opacity(0.75) : .labelSecondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity)
            .background(
                Group {
                    if isSelected {
                        LinearGradient.brandGradient
                    } else {
                        LinearGradient(colors: [.glassLight, .glassLight], startPoint: .top, endPoint: .bottom)
                    }
                }
            )
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.brand.opacity(0.6) : Color.glassBorder, lineWidth: isSelected ? 1 : 0.5)
            )
            .shadow(color: isSelected ? .brand.opacity(0.3) : .clear, radius: 10, x: 0, y: 4)
        }
        .buttonStyle(.plain)
        .animation(.easeOut(duration: 0.18), value: isSelected)
    }
}

// MARK: - Paper Size Card

private struct PaperSizeCard: View {
    let size: PaperSize
    let isSelected: Bool
    let lang: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: size.icon)
                    .font(.caption)
                    .foregroundColor(isSelected ? .white : .labelSecondary)
                Text(size.displayName(lang: lang))
                    .font(.caption)
                    .foregroundColor(isSelected ? .white : .labelPrimary)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 9)
            .background(
                Group {
                    if isSelected {
                        LinearGradient.brandGradient
                    } else {
                        LinearGradient(colors: [.glassLight, .glassLight], startPoint: .top, endPoint: .bottom)
                    }
                }
            )
            .background(.ultraThinMaterial)
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .stroke(isSelected ? Color.brand.opacity(0.6) : Color.glassBorder, lineWidth: 0.5)
            )
            .shadow(color: isSelected ? .brand.opacity(0.3) : .clear, radius: 8, x: 0, y: 3)
        }
        .buttonStyle(.plain)
        .animation(.easeOut(duration: 0.15), value: isSelected)
    }
}

// MARK: - Style Card

private struct StyleCard: View {
    let style: DrawingStyle
    let isSelected: Bool
    let lang: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(Color.bgSurface)
                        .frame(width: 56, height: 56)
                        .shadow(color: .neuLight, radius: 6, x: -3, y: -3)
                        .shadow(color: .neuDark, radius: 6, x: 3, y: 3)

                    if isSelected {
                        Circle()
                            .fill(style.accentColor.opacity(0.20))
                            .frame(width: 56, height: 56)
                    }

                    Image(systemName: style.icon)
                        .font(.title3)
                        .foregroundColor(isSelected ? style.accentColor : .labelSecondary)
                }
                .shadow(color: isSelected ? style.accentColor.opacity(0.45) : .clear, radius: 12, x: 0, y: 4)

                Text(style.displayName(lang: lang))
                    .font(.caption)
                    .foregroundColor(isSelected ? style.accentColor : .labelSecondary)
                    .multilineTextAlignment(.center)
                    .frame(width: 72)
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 4)
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(isSelected ? style.accentColor.opacity(0.55) : Color.clear, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .animation(.easeOut(duration: 0.15), value: isSelected)
    }
}

// MARK: - Medium Card

private struct MediumCard: View {
    let medium: DrawingMedium
    let isSelected: Bool
    let lang: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: medium.icon)
                    .foregroundColor(isSelected ? .white : .labelSecondary)
                Text(medium.displayName(lang: lang))
                    .font(.subheadline)
                    .foregroundColor(isSelected ? .white : .labelPrimary)
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 11)
            .background(
                Group {
                    if isSelected {
                        LinearGradient.brandGradient
                    } else {
                        LinearGradient(colors: [.glassLight, .glassLight], startPoint: .top, endPoint: .bottom)
                    }
                }
            )
            .background(.ultraThinMaterial)
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .stroke(isSelected ? Color.brand.opacity(0.6) : Color.glassBorder, lineWidth: 0.5)
            )
            .shadow(color: isSelected ? .brand.opacity(0.3) : .clear, radius: 8, x: 0, y: 3)
        }
        .buttonStyle(.plain)
        .animation(.easeOut(duration: 0.15), value: isSelected)
    }
}
