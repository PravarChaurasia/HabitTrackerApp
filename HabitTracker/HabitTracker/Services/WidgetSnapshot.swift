import Foundation

/// Lightweight snapshot for the home-screen widget (App Group, offline).
struct WidgetSnapshot: Codable {
    var updatedAt: Date
    var items: [Item]

    struct Item: Codable, Identifiable {
        var id: UUID
        var title: String
        var iconName: String
        var colorHex: String
        var isDone: Bool
    }

    static let suiteName = SharedStore.appGroupID
    static let key = "widget.snapshot"

    static func load() -> WidgetSnapshot {
        guard let defaults = UserDefaults(suiteName: suiteName),
              let data = defaults.data(forKey: key),
              let snap = try? JSONDecoder().decode(WidgetSnapshot.self, from: data) else {
            return WidgetSnapshot(updatedAt: Date(), items: [])
        }
        return snap
    }

    @MainActor
    static func save(from habits: [Habit]) {
        let today = habits
            .filter { $0.isVisibleInLists && HabitScheduling.isScheduled(on: Date(), habit: $0) }
            .prefix(6)
            .map {
                Item(
                    id: $0.id,
                    title: $0.title,
                    iconName: $0.iconName,
                    colorHex: $0.colorHex,
                    isDone: HabitScheduling.isCompleted(on: Date(), habit: $0)
                )
            }
        let snap = WidgetSnapshot(updatedAt: Date(), items: Array(today))
        if let data = try? JSONEncoder().encode(snap),
           let defaults = UserDefaults(suiteName: suiteName) {
            defaults.set(data, forKey: key)
        } else if let data = try? JSONEncoder().encode(snap) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }
}
