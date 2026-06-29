import SwiftUI

@main
struct PictureArtApp: App {
    @StateObject private var lm = LocalizationManager.shared
    @StateObject private var store = ProjectStore.shared
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false

    var body: some Scene {
        WindowGroup {
            if !hasCompletedOnboarding {
                LanguageSelectionView(hasCompletedOnboarding: $hasCompletedOnboarding)
                    .environmentObject(lm)
            } else {
                HomeView()
                    .environmentObject(lm)
                    .environmentObject(store)
            }
        }
        .tint(.brand)
    }
}
