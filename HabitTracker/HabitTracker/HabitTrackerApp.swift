import SwiftUI
import SwiftData

@main
struct HabitTrackerApp: App {
    @AppStorage("appearanceMode") private var appearanceMode = "system"

    init() {
        ReminderNotificationDelegate.configure()
    }

    var sharedModelContainer: ModelContainer = {
        do {
            return try SharedStore.makeContainer()
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            RootView()
                .preferredColorScheme(colorScheme)
        }
        .modelContainer(sharedModelContainer)
    }

    private var colorScheme: ColorScheme? {
        switch appearanceMode {
        case "light": return .light
        case "dark": return .dark
        default: return nil
        }
    }
}
