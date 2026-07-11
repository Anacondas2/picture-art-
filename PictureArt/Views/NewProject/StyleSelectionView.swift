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
            VStack(alignment: .leading, spacing: DG.Space.l) {

                // Preview thumbnail — the artwork gets the deepest shadow
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(maxWidth: .infinity)
                    .frame(height: 180)
                    .clipped()
                    .clipShape(RoundedRectangle(cornerRadius: DG.Radius.m, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: DG.Radius.m, style: .continuous)
                            .strokeBorder(Color.glassEdge, lineWidth: 1)
                    )
                    .shadow(color: Color.glassShadow.opacity(0.22), radius: 20, x: 0, y: 10)
                    .padding(.horizontal, DG.Space.margin)

                // Project name
                VStack(alignment: .leading, spacing: DG.Space.s) {
                    sectionLabel(lm.t("newproject.name"))
                        .padding(.horizontal, DG.Space.margin)
                    TextField(lm.t("newproject.namePlaceholder"), text: $projectName)
                        .foregroundColor(.ink)
                        .accentColor(.brand)
                        .padding(.horizontal, DG.Space.m)
                        .frame(minHeight: 50)
                        .background(.ultraThinMaterial)
                        .background(Color.glassFill)
                        .clipShape(RoundedRectangle(cornerRadius: DG.Radius.s, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: DG.Radius.s, style: .continuous)
                                .strokeBorder(Color.glassEdge, lineWidth: 1)
                        )
                        .padding(.horizontal, DG.Space.margin)
                }

                // Skill level
                VStack(alignment: .leading, spacing: DG.Space.s + 4) {
                    sectionLabel(lm.t("style.skillLevel"))
                        .padding(.horizontal, DG.Space.margin)

                    HStack(spacing: DG.Space.s + 2) {
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
                    .padding(.horizontal, DG.Space.margin)
                }

                // Paper size
                VStack(alignment: .leading, spacing: DG.Space.s + 4) {
                    sectionLabel(lm.t("style.paperSize"))
                        .padding(.horizontal, DG.Space.margin)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: DG.Space.s + 2) {
                            ForEach(PaperSize.allCases, id: \.self) { size in
                                ChipCard(
                                    icon: size.icon,
                                    label: size.displayName(lang: lm.currentLanguage),
                                    isSelected: selectedPaperSize == size
                                ) {
                                    selectedPaperSize = size
                                }
                            }
                        }
                        .padding(.horizontal, DG.Space.margin)
                    }
                }

                // Style selection
                VStack(alignment: .leading, spacing: DG.Space.s + 4) {
                    sectionLabel(lm.t("style.title"))
                        .padding(.horizontal, DG.Space.margin)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: DG.Space.s + 4) {
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
                        .padding(.horizontal, DG.Space.margin)
                    }
                }

                // API key warning
                if showApiKeyWarning {
                    HStack(spacing: DG.Space.s + 2) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.warning)
                        Text(lm.t("style.apiKeyWarning"))
                            .font(.caption)
                            .foregroundColor(.inkSecondary)
                    }
                    .padding(DG.Space.m - 4)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(.ultraThinMaterial)
                    .background(Color.warning.opacity(0.10))
                    .clipShape(RoundedRectangle(cornerRadius: DG.Radius.s, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: DG.Radius.s, style: .continuous)
                            .strokeBorder(Color.warning.opacity(0.35), lineWidth: 1)
                    )
                    .padding(.horizontal, DG.Space.margin)
                }

                // Medium selection
                VStack(alignment: .leading, spacing: DG.Space.s + 4) {
                    sectionLabel(lm.t("style.medium"))
                        .padding(.horizontal, DG.Space.margin)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: DG.Space.s + 2) {
                            ForEach(availableMediums, id: \.self) { medium in
                                ChipCard(
                                    icon: medium.icon,
                                    label: medium.displayName(lang: lm.currentLanguage),
                                    isSelected: selectedMedium == medium
                                ) {
                                    selectedMedium = medium
                                }
                            }
                        }
                        .padding(.horizontal, DG.Space.margin)
                    }
                }

                // Grid size
                VStack(alignment: .leading, spacing: DG.Space.s + 4) {
                    sectionLabel(lm.t("style.gridSize"))
                        .padding(.horizontal, DG.Space.margin)

                    // Physical translation + difficulty
                    HStack(spacing: DG.Space.s) {
                        let cellStr = selectedPaperSize.cellSizeComment(rows: gridRows, cols: gridCols, lang: lm.currentLanguage)
                        Image(systemName: "ruler")
                            .font(.caption)
                            .foregroundColor(.inkTertiary)
                        Text(cellStr)
                            .font(.caption)
                            .foregroundColor(.inkSecondary)
                        Spacer()
                        let diff = cellDifficulty
                        Text(diff.label(lang: lm.currentLanguage))
                            .font(.system(size: 12, weight: .semibold, design: .rounded))
                            .foregroundColor(difficultyColor(diff))
                            .padding(.horizontal, DG.Space.s + 2)
                            .padding(.vertical, 4)
                            .background(difficultyColor(diff).opacity(0.14))
                            .clipShape(Capsule())
                    }
                    .padding(.horizontal, DG.Space.margin)

                    let recommended = Set(selectedSkillLevel.recommendedGridSizes).union(Set(selectedPaperSize.recommendedGridSizes))
                    let gridOptions = [8, 10, 12, 14, 16, 18, 20, 24, 32]

                    HStack(spacing: DG.Space.m) {
                        VStack(alignment: .leading, spacing: DG.Space.xs) {
                            Text(lm.t("style.rows"))
                                .font(.caption)
                                .foregroundColor(.inkSecondary)
                            Picker("", selection: $gridRows) {
                                ForEach(gridOptions, id: \.self) { v in
                                    Text("\(v)\(recommended.contains(v) ? " ★" : "")").tag(v)
                                        .foregroundColor(.ink)
                                }
                            }
                            .pickerStyle(.wheel)
                            .frame(height: 80)
                            .clipped()
                        }
                        VStack(alignment: .leading, spacing: DG.Space.xs) {
                            Text(lm.t("style.cols"))
                                .font(.caption)
                                .foregroundColor(.inkSecondary)
                            Picker("", selection: $gridCols) {
                                ForEach(gridOptions, id: \.self) { v in
                                    Text("\(v)\(recommended.contains(v) ? " ★" : "")").tag(v)
                                        .foregroundColor(.ink)
                                }
                            }
                            .pickerStyle(.wheel)
                            .frame(height: 80)
                            .clipped()
                        }
                        Spacer()

                        VStack(spacing: 2) {
                            Text("\(gridRows)×\(gridCols)")
                                .dgNumeral(30, weight: .regular)
                            Text(lm.currentLanguage == "ru"
                                 ? "\(gridRows * gridCols) клеток"
                                 : "\(gridRows * gridCols) squares")
                                .dgCaption()
                        }
                        .padding(.trailing, DG.Space.s)
                    }
                    .padding(.horizontal, DG.Space.margin)
                }

                // Generate CTA
                Button(action: onGenerate) {
                    Text(lm.t("style.generate"))
                        .dgButtonLabel()
                        .foregroundColor(.ink)
                        .frame(maxWidth: .infinity)
                        .frame(minHeight: 54)
                }
                .buttonStyle(GlassCTAStyle())
                .padding(.horizontal, DG.Space.margin)
                .padding(.bottom, DG.Space.xl)
            }
            .padding(.top, DG.Space.m)
        }
        .background(MistBackground())
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
            .font(.system(size: 13, weight: .semibold, design: .rounded))
            .foregroundColor(.inkSecondary)
    }

    private func difficultyColor(_ diff: PaperSize.CellDifficulty) -> Color {
        switch diff {
        case .easy:   return .progressTeal
        case .medium: return .brand
        case .hard:   return .destructive
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
        Button {
            UISelectionFeedbackGenerator().selectionChanged()
            action()
        } label: {
            VStack(spacing: 6) {
                Image(systemName: level.icon)
                    .font(.title3)
                    .foregroundColor(.brand)
                Text(level.displayName(lang: lang))
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundColor(.ink)
                Text(level.description(lang: lang))
                    .font(.system(size: 10))
                    .foregroundColor(.inkSecondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.vertical, DG.Space.s + 4)
            .padding(.horizontal, DG.Space.xs)
            .frame(maxWidth: .infinity, minHeight: 88)
            .dgGlassCard(radius: DG.Radius.s, selected: isSelected)
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
        .animation(DGMotion.press, value: isSelected)
    }
}

// MARK: - Chip Card (paper size, medium)

private struct ChipCard: View {
    let icon: String
    let label: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button {
            UISelectionFeedbackGenerator().selectionChanged()
            action()
        } label: {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(isSelected ? .brand : .inkSecondary)
                Text(label)
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundColor(.ink)
            }
            .padding(.horizontal, DG.Space.m)
            .frame(minHeight: DG.touchTarget)
            .background(.ultraThinMaterial)
            .background(isSelected ? Color.glassSelected : Color.glassFill.opacity(0.6))
            .clipShape(Capsule())
            .overlay(
                Capsule().strokeBorder(
                    isSelected ? Color.white : Color.glassEdge.opacity(0.7),
                    lineWidth: 1
                )
            )
            .shadow(
                color: isSelected ? Color.glassShadow.opacity(0.20) : .clear,
                radius: 8, x: 0, y: 4
            )
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
        .animation(DGMotion.press, value: isSelected)
    }
}

// MARK: - Style Card

private struct StyleCard: View {
    let style: DrawingStyle
    let isSelected: Bool
    let lang: String
    let action: () -> Void

    var body: some View {
        Button {
            UISelectionFeedbackGenerator().selectionChanged()
            action()
        } label: {
            VStack(spacing: DG.Space.s) {
                ZStack {
                    Circle()
                        .fill(isSelected ? Color.glassSelected : Color.white.opacity(0.35))
                        .frame(width: 56, height: 56)
                        .overlay(
                            Circle().strokeBorder(
                                isSelected ? style.accentColor.opacity(0.6) : Color.glassEdge.opacity(0.6),
                                lineWidth: isSelected ? 1.5 : 1
                            )
                        )
                        .shadow(
                            color: isSelected ? Color.glassShadow.opacity(0.20) : .clear,
                            radius: 8, x: 0, y: 4
                        )

                    Image(systemName: style.icon)
                        .font(.title3)
                        .foregroundColor(isSelected ? style.accentColor : .inkSecondary)
                }

                Text(style.displayName(lang: lang))
                    .font(.system(size: 12, weight: isSelected ? .semibold : .regular, design: .rounded))
                    .foregroundColor(isSelected ? .ink : .inkSecondary)
                    .multilineTextAlignment(.center)
                    .frame(width: 72)
            }
            .padding(.vertical, DG.Space.s + 2)
            .padding(.horizontal, DG.Space.xs)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
        .animation(DGMotion.press, value: isSelected)
    }
}
