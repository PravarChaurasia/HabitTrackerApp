import WidgetKit
import SwiftUI

struct HabitWidgetEntry: TimelineEntry {
    let date: Date
    let items: [WidgetSnapshotDTO.Item]
}

struct WidgetSnapshotDTO: Codable {
    var updatedAt: Date
    var items: [Item]

    struct Item: Codable, Identifiable {
        var id: UUID
        var title: String
        var iconName: String
        var colorHex: String
        var isDone: Bool
    }

    static let suiteName = "group.com.local.HabitTracker"
    static let key = "widget.snapshot"

    static func load() -> WidgetSnapshotDTO {
        if let defaults = UserDefaults(suiteName: suiteName),
           let data = defaults.data(forKey: key),
           let snap = try? JSONDecoder().decode(WidgetSnapshotDTO.self, from: data) {
            return snap
        }
        if let data = UserDefaults.standard.data(forKey: key),
           let snap = try? JSONDecoder().decode(WidgetSnapshotDTO.self, from: data) {
            return snap
        }
        return WidgetSnapshotDTO(updatedAt: Date(), items: [])
    }
}

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> HabitWidgetEntry {
        HabitWidgetEntry(date: Date(), items: [
            .init(id: UUID(), title: "Drink water", iconName: "drop.fill", colorHex: "#4F9DDE", isDone: false)
        ])
    }

    func getSnapshot(in context: Context, completion: @escaping (HabitWidgetEntry) -> Void) {
        let snap = WidgetSnapshotDTO.load()
        completion(HabitWidgetEntry(date: Date(), items: snap.items))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<HabitWidgetEntry>) -> Void) {
        let snap = WidgetSnapshotDTO.load()
        let entry = HabitWidgetEntry(date: Date(), items: snap.items)
        let next = Calendar.current.date(byAdding: .minute, value: 30, to: Date()) ?? Date()
        completion(Timeline(entries: [entry], policy: .after(next)))
    }
}

struct HabitTrackerWidgetEntryView: View {
    var entry: Provider.Entry

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Today")
                .font(.headline)
            if entry.items.isEmpty {
                Text("No habits yet")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } else {
                ForEach(entry.items.prefix(4)) { item in
                    HStack(spacing: 8) {
                        Image(systemName: item.isDone ? "checkmark.circle.fill" : "circle")
                            .foregroundStyle(color(item.colorHex))
                        Text(item.title)
                            .font(.caption)
                            .lineLimit(1)
                        Spacer(minLength: 0)
                    }
                }
            }
            Spacer(minLength: 0)
        }
        .padding(12)
        .containerBackground(.fill.tertiary, for: .widget)
    }

    private func color(_ hex: String) -> Color {
        var cleaned = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        if cleaned.hasPrefix("#") { cleaned.removeFirst() }
        guard cleaned.count == 6, let value = UInt64(cleaned, radix: 16) else { return .accentColor }
        return Color(
            red: Double((value >> 16) & 0xFF) / 255,
            green: Double((value >> 8) & 0xFF) / 255,
            blue: Double(value & 0xFF) / 255
        )
    }
}

@main
struct HabitTrackerWidget: Widget {
    let kind = "HabitTrackerWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            HabitTrackerWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Habit Tracker")
        .description("Today's habits at a glance. Fully on-device.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
