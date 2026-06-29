import SwiftUI

struct StyleSelectionView: View {
    let image: UIImage
    @Binding var projectName: String
    @Binding var selectedStyle: DrawingStyle
    @Binding var selectedMedium: DrawingMedium
    @Binding var gridRows: Int
    @Binding var gridCols: Int
    var onGenerate: () -> Void

    @EnvironmentObject var lm: LocalizationManager

    private let gridOptions = [8, 12, 16, 20, 24, 32]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {

                // Preview thumbnail
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(maxWidth: .infinity)
                    .frame(height: 200)
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

                // Style selection
                VStack(alignment: .leading, spacing: 12) {
                    Text(lm.t("style.title"))
                        .font(.headline)
                        .padding(.horizontal)
                    Text(lm.t("style.subtitle"))
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .padding(.horizontal)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(DrawingStyle.allCases, id: \.self) { style in
                                StyleCard(
                                    style: style,
                                    isSelected: selectedStyle == style,
                                    lang: lm.currentLanguage
                                ) {
                                    selectedStyle = style
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }

                // Medium selection
                VStack(alignment: .leading, spacing: 12) {
                    Text(lm.t("style.medium"))
                        .font(.headline)
                        .padding(.horizontal)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(DrawingMedium.allCases, id: \.self) { medium in
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

                    HStack(spacing: 16) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(lm.t("style.rows"))
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Picker("", selection: $gridRows) {
                                ForEach(gridOptions, id: \.self) { v in
                                    Text("\(v)").tag(v)
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
                                    Text("\(v)").tag(v)
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
    }
}

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
