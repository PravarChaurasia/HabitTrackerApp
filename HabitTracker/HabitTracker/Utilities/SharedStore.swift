import Foundation
import SwiftData

enum SharedStore {
    static let appGroupID = "group.com.local.HabitTracker"

    static func makeContainer() throws -> ModelContainer {
        let schema = Schema([Habit.self, HabitDayOverride.self, Tag.self, Completion.self])
        let url: URL
        if let containerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupID) {
            url = containerURL.appendingPathComponent("HabitTracker.store")
        } else {
            // Fallback to app support when App Group isn't available yet (unsigned / no team).
            let support = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
            try? FileManager.default.createDirectory(at: support, withIntermediateDirectories: true)
            url = support.appendingPathComponent("HabitTracker.store")
        }
        let config = ModelConfiguration(
            schema: schema,
            url: url,
            cloudKitDatabase: .none
        )
        return try ModelContainer(for: schema, configurations: [config])
    }
}
