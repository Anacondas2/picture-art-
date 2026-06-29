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
                    .cornerRadius(12)
                    .padding(.horizontal)

                // Project name
                VStack(alignment: .leading, spacing: 8) {
                    Text(lm.t("newproject.name"))
                        .font(.headline)
                        .padding(.horizontal)
                    TextField(lm.t("newproject.namePlaceholder"), text: $projectName)
                        .textFieldStyle(.roundedBorder)
                        .padding(.horizontal)
                }

                // Skill level
                VStack(alignment: .leading, spacing: 12) {
                    Text(lm.t("style.skillLevel"))
                        .font(.headline)
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
                    Text(lm.t("style.paperSize"))
                        .font(.headline)
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
                    Text(lm.t("style.title"))
                        .font(.headline)
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
                            .foregroundColor(.orange)
                        Text(lm.t("style.apiKeyWarning"))
                            .font(.caption)
                            .foregroundColor(.orange)
                    }
                    .padding(12)
                    .background(Color.orange.opacity(0.1))
                    .cornerRadius(10)
                    .padding(.horizontal)
                }

                // Medium selection
                VStack(alignment: .leading, spacing: 12) {
                    Text(lm.t("style.medium"))
                        .font(.headline)
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
                    Text(lm.t("style.gridSize"))
                        .font(.headline)
                        .padding(.horizontal)

                    // Cell size info
                    HStack(spacing: 8) {
                        let cellStr = selectedPaperSize.cellSizeComment(rows: gridRows, cols: gridCols, lang: lm.currentLanguage)
                        Image(systemName: "ruler")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(cellStr)
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                        let diff = cellDifficulty
                        Text(diff.label(lang: lm.currentLanguage))
                            .font(.caption.bold())
                            .foregroundColor(difficultyColor(diff))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(difficultyColor(diff).opacity(0.12))
                            .cornerRadius(6)
                    }
                    .padding(.horizontal)

                    let recommended = Set(selectedSkillLevel.recommendedGridSizes).union(Set(selectedPaperSize.recommendedGridSizes))
                    let gridOptions = [8, 10, 12, 14, 16, 18, 20, 24, 32].filter { _ in true }

                    HStack(spacing: 16) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(lm.t("style.rows"))
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Picker("", selection: $gridRows) {
                                ForEach(gridOptions, id: \.self) { v in
                                    Text("\(v)\(recommended.contains(v) ? " ★" : "")").tag(v)
                                }
                            }
                            .pickerStyle(.wheel)
                            .frame(height: 80)
                            .clipped()
                        }
                        VStack(alignment: .leading, spacing: 4) {
                            Text(lm.t("style.cols"))
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Picker("", selection: $gridCols) {
                                ForEach(gridOptions, id: \.self) { v in
                                    Text("\(v)\(recommended.contains(v) ? " ★" : "")").tag(v)
                                }
                            }
                            .pickerStyle(.wheel)
                            .frame(height: 80)
                            .clipped()
                        }
                        Spacer()

                        VStack(spacing: 4) {
                            Text("\(gridRows)×\(gridCols)")
                                .font(.title.bold())
                                .foregroundColor(.accentColor)
                            Text("\(gridRows * gridCols)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(.trailing)
                    }
                    .padding(.horizontal)
                }

                // Generate button
                Button(action: onGenerate) {
                    Text(lm.t("style.generate"))
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.accentColor)
                        .cornerRadius(14)
                }
                .padding(.horizontal)
                .padding(.bottom, 32)
            }
            .padding(.top)
        }
        .navigationTitle(lm.t("newproject.title"))
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            if !availableMediums.contains(selectedMedium) {
                selectedMedium = availableMediums.first ?? .brush
            }
        }
    }

    private func difficultyColor(_ diff: PaperSize.CellDifficulty) -> Color {
        switch diff {
        case .easy:   return .green
        case .medium: return .orange
        case .hard:   return .red
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
                    .foregroundColor(isSelected ? .white : .accentColor)
                Text(level.displayName(lang: lang))
                    .font(.caption.bold())
                    .foregroundColor(isSelected ? .white : .primary)
                Text(level.description(lang: lang))
                    .font(.system(size: 10))
                    .foregroundColor(isSelected ? .white.opacity(0.85) : .secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity)
            .background(isSelected ? Color.accentColor : Color(UIColor.secondarySystemBackground))
            .cornerRadius(12)
        }
        .buttonStyle(.plain)
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
                    .foregroundColor(isSelected ? .white : .secondary)
                Text(size.displayName(lang: lang))
                    .font(.caption)
                    .foregroundColor(isSelected ? .white : .primary)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(isSelected ? Color.accentColor : Color(UIColor.secondarySystemBackground))
            .cornerRadius(20)
        }
        .buttonStyle(.plain)
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
                        .fill(isSelected ? Color.accentColor : Color(UIColor.secondarySystemBackground))
                        .frame(width: 56, height: 56)
                    Image(systemName: style.icon)
                        .font(.title3)
                        .foregroundColor(isSelected ? .white : .primary)
                }
                Text(style.displayName(lang: lang))
                    .font(.caption)
                    .foregroundColor(isSelected ? .accentColor : .primary)
                    .multilineTextAlignment(.center)
                    .frame(width: 72)
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 4)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.accentColor : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
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
                    .foregroundColor(isSelected ? .white : .primary)
                Text(medium.displayName(lang: lang))
                    .font(.subheadline)
                    .foregroundColor(isSelected ? .white : .primary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(isSelected ? Color.accentColor : Color(UIColor.secondarySystemBackground))
            .cornerRadius(20)
        }
        .buttonStyle(.plain)
    }
}
