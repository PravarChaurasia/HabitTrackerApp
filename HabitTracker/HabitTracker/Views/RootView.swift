import SwiftUI

struct RootView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false

    var body: some View {
        Group {
            if hasCompletedOnboarding {
                MainTabView()
            } else {
                OnboardingView {
                    hasCompletedOnboarding = true
                }
            }
        }
    }
}

struct MainTabView: View {
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            TodayView()
                .tabItem { Label("Today", systemImage: "checkmark.circle") }
                .tag(0)
            HabitsView()
                .tabItem { Label("Habits", systemImage: "list.bullet") }
                .tag(1)
            InsightsView()
                .tabItem { Label("Insights", systemImage: "chart.bar") }
                .tag(2)
            TagsView()
                .tabItem { Label("Tags", systemImage: "tag") }
                .tag(3)
            SettingsView()
                .tabItem { Label("Settings", systemImage: "gearshape") }
                .tag(4)
        }
        .onReceive(NotificationCenter.default.publisher(for: .habitChangeTimeRequested)) { _ in
            selectedTab = 0
        }
        .onAppear {
            if UserDefaults.standard.string(forKey: "pendingChangeTimeHabitID") != nil {
                selectedTab = 0
            }
        }
    }
}
