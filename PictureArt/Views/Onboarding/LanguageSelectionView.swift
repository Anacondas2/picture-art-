import SwiftUI

struct LanguageSelectionView: View {
    @EnvironmentObject var lm: LocalizationManager
    @Binding var hasCompletedOnboarding: Bool

    var body: some View {
        ZStack {
            LinearGradient.appBg.ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                VStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(Color.brand.opacity(0.12))
                            .frame(width: 96, height: 96)
                            .shadow(color: .brand.opacity(0.3), radius: 20, x: 0, y: 8)
                        Image(systemName: "paintbrush.pointed.fill")
                            .font(.system(size: 40, weight: .medium))
                            .foregroundColor(.brand)
                    }

                    Text("PictureArt")
                        .font(.system(size: 34, weight: .bold))
                        .foregroundColor(.labelPrimary)

                    Text(lm.currentLanguage == "ru" ? "Выберите язык" : "Choose your language")
                        .font(.subheadline)
                        .foregroundColor(.labelTertiary)
                        .tracking(0.5)
                }

                Spacer().frame(height: 48)

                VStack(spacing: 12) {
                    LanguageCard(flag: "🇷🇺", name: "Русский", selected: lm.currentLanguage == "ru") {
                        lm.currentLanguage = "ru"
                    }
                    LanguageCard(flag: "🇬🇧", name: "English", selected: lm.currentLanguage == "en") {
                        lm.currentLanguage = "en"
                    }
                }
                .padding(.horizontal, 32)

                Spacer()

                Button {
                    hasCompletedOnboarding = true
                } label: {
                    Text(lm.currentLanguage == "ru" ? "Продолжить" : "Continue")
                        .font(.headline)
                        .foregroundColor(.ink)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                }
                .buttonStyle(GlassCTAStyle())
                .padding(.horizontal, 32)
                .padding(.bottom, 48)
            }
        }
    }
}

private struct LanguageCard: View {
    let flag: String
    let name: String
    let selected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Text(flag).font(.system(size: 28))
                Text(name)
                    .font(.body.weight(selected ? .semibold : .regular))
                    .foregroundColor(selected ? .labelPrimary : .labelSecondary)
                Spacer()
                Image(systemName: selected ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(selected ? .brand : .labelTertiary)
                    .font(.title3)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 18)
            .background(selected ? Color.brand.opacity(0.12) : Color.glassLight)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        selected ? Color.brand.opacity(0.5) : Color.glassBorder,
                        lineWidth: selected ? 1.0 : 0.5
                    )
            )
            .shadow(color: selected ? .brand.opacity(0.2) : .clear, radius: 12, x: 0, y: 4)
        }
        .buttonStyle(.plain)
        .animation(.easeOut(duration: 0.18), value: selected)
    }
}
