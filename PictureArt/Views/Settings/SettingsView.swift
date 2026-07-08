import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var lm: LocalizationManager
    @ObservedObject var store: ProjectStore = .shared

    @State private var apiKey: String = ProjectStore.shared.apiKey
    @State private var showAPIKeySaved = false

    var body: some View {
        ZStack {
            LinearGradient.appBg.ignoresSafeArea()

            Form {
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(lm.t("settings.apiKey"))
                            .font(.subheadline)
                            .foregroundColor(.labelSecondary)
                        SecureField(lm.t("settings.apiKeyHint"), text: $apiKey)
                            .textContentType(.password)
                            .autocorrectionDisabled()
                            .foregroundColor(.labelPrimary)
                            .accentColor(.brand)
                            .onSubmit { saveAPIKey() }
                        Text(lm.t("settings.apiKeyInfo"))
                            .font(.caption)
                            .foregroundColor(.labelTertiary)
                    }
                    .padding(.vertical, 4)
                    .listRowBackground(Color.bgSurface)

                    Button {
                        saveAPIKey()
                    } label: {
                        HStack {
                            Text(showAPIKeySaved
                                 ? (lm.currentLanguage == "ru" ? "Сохранено ✓" : "Saved ✓")
                                 : (lm.currentLanguage == "ru" ? "Сохранить ключ" : "Save Key"))
                            Spacer()
                            Image(systemName: showAPIKeySaved ? "checkmark" : "square.and.arrow.down")
                        }
                    }
                    .foregroundColor(showAPIKeySaved ? .green : .brand)
                    .listRowBackground(Color.bgSurface)
                } header: {
                    Text(lm.t("settings.apiSection"))
                        .foregroundColor(.labelTertiary)
                }

                Section {
                    HStack {
                        Text(lm.t("settings.language"))
                            .foregroundColor(.labelPrimary)
                        Spacer()
                        Picker("", selection: $lm.currentLanguage) {
                            Text(lm.t("settings.languageRu")).tag("ru")
                            Text(lm.t("settings.languageEn")).tag("en")
                        }
                        .pickerStyle(.segmented)
                        .frame(width: 160)
                    }
                    .listRowBackground(Color.bgSurface)
                } header: {
                    Text(lm.t("settings.language"))
                        .foregroundColor(.labelTertiary)
                }

                Section {
                    HStack {
                        Text(lm.t("settings.appName"))
                            .foregroundColor(.labelPrimary)
                        Spacer()
                        Text(lm.t("settings.version"))
                            .foregroundColor(.labelSecondary)
                    }
                    .listRowBackground(Color.bgSurface)
                } header: {
                    Text(lm.t("settings.about"))
                        .foregroundColor(.labelTertiary)
                }
            }
            .scrollContentBackground(.hidden)
        }
        .navigationTitle(lm.t("settings.title"))
        .toolbarColorScheme(.light, for: .navigationBar)
        .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .onAppear { apiKey = store.apiKey }
    }

    private func saveAPIKey() {
        store.apiKey = apiKey
        withAnimation {
            showAPIKeySaved = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            showAPIKeySaved = false
        }
    }
}
