import SwiftUI

struct LanguageSelectionView: View {
    @EnvironmentObject var lm: LocalizationManager
    @Binding var hasCompletedOnboarding: Bool

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(red: 0.17, green: 0.43, blue: 0.86), Color(red: 0.55, green: 0.27, blue: 0.86)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 40) {
                Spacer()

                VStack(spacing: 12) {
                    Image(systemName: "paintbrush.pointed.fill")
                        .font(.system(size: 64))
                        .foregroundColor(.white)

                    Text("PictureArt")
                        .font(.largeTitle.bold())
                        .foregroundColor(.white)
                }

                VStack(spacing: 16) {
                    Text(lm.currentLanguage == "ru" ? "Выберите язык" : "Choose your language")
                        .font(.title2)
                        .foregroundColor(.white.opacity(0.85))

                    VStack(spacing: 12) {
                        LanguageCard(flag: "🇷🇺", name: "Русский", selected: lm.currentLanguage == "ru") {
                            lm.currentLanguage = "ru"
                        }
                        LanguageCard(flag: "🇬🇧", name: "English", selected: lm.currentLanguage == "en") {
                            lm.currentLanguage = "en"
                        }
                    }
                    .padding(.horizontal, 32)
                }

                Spacer()

                Button {
                    hasCompletedOnboarding = true
                } label: {
                    Text(lm.currentLanguage == "ru" ? "Продолжить" : "Continue")
                        .font(.headline)
                        .foregroundColor(Color(red: 0.17, green: 0.43, blue: 0.86))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.white)
                        .cornerRadius(14)
                        .padding(.horizontal, 32)
                }
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
                Text(flag).font(.system(size: 36))
                Text(name)
                    .font(.title3.bold())
                    .foregroundColor(selected ? .white : .white.opacity(0.7))
                Spacer()
                if selected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.white)
                        .font(.title3)
                }
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(selected ? Color.white.opacity(0.25) : Color.white.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(selected ? Color.white : Color.clear, lineWidth: 2)
                    )
            )
        }
        .buttonStyle(.plain)
    }
}
