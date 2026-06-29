import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var lm: LocalizationManager
    @ObservedObject var store: ProjectStore = .shared

    @State private var apiKey: String = ProjectStore.shared.apiKey
    @State private var showAPIKeySaved = false

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(lm.t("settings.apiKey"))
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        SecureField(lm.t("settings.apiKeyHint"), text: $apiKey)
                            .textContentType(.password)
                            .autocorrectionDisabled()
                            .onSubmit { saveAPIKey() }
                        Text(lm.t("settings.apiKeyInfo"))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 4)

                    Button {
                        saveAPIKey()
                    } label: {
                        HStack {
                            Text(showAPIKeySaved ? "✓ \(lm.t("error.ok"))" : lm.t("settings.apiKey"))
                            Spacer()
                            Image(systemName: showAPIKeySaved ? "checkmark" : "square.and.arrow.down")
                        }
                    }
                } header: {
                    Text(lm.t("settings.apiSection"))
                }

                Section {
                    HStack {
                        Text(lm.t("settings.language"))
                        Spacer()
                        Picker("", selection: $lm.currentLanguage) {
                            Text(lm.t("settings.languageRu")).tag("ru")
                            Text(lm.t("settings.languageEn")).tag("en")
                        }
                        .pickerStyle(.segmented)
                        .frame(width: 160)
                    }
                } header: {
                    Text(lm.t("settings.language"))
                }

                Section {
                    HStack {
                        Text(lm.t("settings.appName"))
                        Spacer()
                        Text(lm.t("settings.version"))
                            .foregroundColor(.secondary)
                    }
                } header: {
                    Text(lm.t("settings.about"))
                }
            }
            .navigationTitle(lm.t("settings.title"))
        }
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
