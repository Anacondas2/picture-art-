import SwiftUI

struct LanguageSelectionView: View {
    @EnvironmentObject var lm: LocalizationManager
    @Binding var hasCompletedOnboarding: Bool

    var body: some View {
        ZStack {
            Color.inkSurface.ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                // Brand mark
                VStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(Color.brand.opacity(0.15))
                            .frame(width: 96, height: 96)
                        Image(systemName: "paintbrush.pointed.fill")
                            .font(.system(size: 40, weight: .medium))
                            .foregroundColor(.brand)
                    }

                    Text("PictureArt")
                        .font(.system(size: 34, weight: .bold, design: .default))
                        .foregroundColor(.white)

                    Text(lm.currentLanguage == "ru" ? "Выберите язык" : "Choose your language")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.5))
                        .tracking(0.5)
                }

                Spacer().frame(height: 48)

                // Language cards
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
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.brand)
                        .cornerRadius(14)
                }
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
                    .foregroundColor(selected ? .white : .white.opacity(0.6))
                Spacer()
                Image(systemName: selected ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(selected ? .brand : .white.opacity(0.2))
                    .font(.title3)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 18)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(selected ? Color.white.opacity(0.08) : Color.white.opacity(0.04))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(selected ? Color.brand.opacity(0.6) : Color.white.opacity(0.1), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(.plain)
        .animation(.easeOut(duration: 0.15), value: selected)
    }
}
