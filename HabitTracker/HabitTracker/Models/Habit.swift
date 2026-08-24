import Foundation
import SwiftData

@Model
final class Habit {
    var id: UUID
    var title: String
    var notes: String
    var colorHex: String
    var iconName: String
    var startDate: Date
    var endDate: Date?
    var frequencyRaw: String
    /// Comma-separated weekday ints when frequency is weekdays (e.g. "2,4,6")
    var weekdaysRaw: String
    var intervalDays: Int
    var timesPerWeek: Int
    var dayOfMonth: Int
    var reminderEnabled: Bool
    var reminderHour: Int
    var reminderMinute: Int
    /// Extra times as "H:M,H:M"
    var extraReminderTimesRaw: String
    var snoozeMinutes: Int
    var statusRaw: String
    var kindRaw: String
    var trackingModeRaw: String
    var targetValue: Double
    var timeOfDayRaw: String
    var isArchived: Bool
    var createdAt: Date
    var sortOrder: Int

    @Relationship(deleteRule: .cascade, inverse: \Completion.habit)
    var completions: [Completion] = []

    @Relationship(inverse: \Tag.habits)
    var tags: [Tag] = []

    init(
        title: String,
        notes: String = "",
        colorHex: String = HabitCatalog.colors[0].hex,
        iconName: String = HabitCatalog.icons[0],
        startDate: Date = CalendarDay.startOfDay(),
        endDate: Date? = nil,
        frequency: FrequencyType = .daily,
        weekdays: [Int] = [],
        intervalDays: Int = 2,
        timesPerWeek: Int = 3,
        dayOfMonth: Int = 1,
        reminderEnabled: Bool = false,
        reminderHour: Int = 8,
        reminderMinute: Int = 0,
        extraReminderTimes: [ReminderTime] = [],
        snoozeMinutes: Int = 10,
        status: HabitStatus = .active,
        kind: HabitKind = .build,
        trackingMode: TrackingMode = .binary,
        targetValue: Double = 1,
        timeOfDay: TimeOfDaySlot = .anytime,
        isArchived: Bool = false,
        sortOrder: Int = 0
    ) {
        self.id = UUID()
        self.title = title
        self.notes = notes
        self.colorHex = colorHex
        self.iconName = iconName
        self.startDate = CalendarDay.startOfDay(startDate)
        self.endDate = endDate.map { CalendarDay.startOfDay($0) }
        self.frequencyRaw = frequency.rawValue
        self.weekdaysRaw = weekdays.sorted().map(String.init).joined(separator: ",")
        self.intervalDays = max(1, intervalDays)
        self.timesPerWeek = max(1, min(7, timesPerWeek))
        self.dayOfMonth = max(1, min(31, dayOfMonth))
        self.reminderEnabled = reminderEnabled
        self.reminderHour = reminderHour
        self.reminderMinute = reminderMinute
        self.extraReminderTimesRaw = Self.encodeTimes(extraReminderTimes)
        self.snoozeMinutes = max(0, snoozeMinutes)
        self.statusRaw = status.rawValue
        self.kindRaw = kind.rawValue
        self.trackingModeRaw = trackingMode.rawValue
        self.targetValue = max(0, targetValue)
        self.timeOfDayRaw = timeOfDay.rawValue
        self.isArchived = isArchived
        self.createdAt = Date()
        self.sortOrder = sortOrder
    }

    var frequency: FrequencyType {
        get { FrequencyType(rawValue: frequencyRaw) ?? .daily }
        set { frequencyRaw = newValue.rawValue }
    }

    var status: HabitStatus {
        get { HabitStatus(rawValue: statusRaw) ?? .active }
        set { statusRaw = newValue.rawValue }
    }

    var kind: HabitKind {
        get { HabitKind(rawValue: kindRaw) ?? .build }
        set { kindRaw = newValue.rawValue }
    }

    var trackingMode: TrackingMode {
        get { TrackingMode(rawValue: trackingModeRaw) ?? .binary }
        set { trackingModeRaw = newValue.rawValue }
    }

    var timeOfDay: TimeOfDaySlot {
        get { TimeOfDaySlot(rawValue: timeOfDayRaw) ?? .anytime }
        set { timeOfDayRaw = newValue.rawValue }
    }

    var weekdays: [Int] {
        get {
            weekdaysRaw
                .split(separator: ",")
                .compactMap { Int($0) }
                .sorted()
        }
        set {
            weekdaysRaw = newValue.sorted().map(String.init).joined(separator: ",")
        }
    }

    var reminderTimes: [ReminderTime] {
        get {
            var times = [ReminderTime(hour: reminderHour, minute: reminderMinute)]
            times.append(contentsOf: Self.decodeTimes(extraReminderTimesRaw))
            // unique by id
            var seen = Set<String>()
            return times.filter { seen.insert($0.id).inserted }.sorted {
                ($0.hour, $0.minute) < ($1.hour, $1.minute)
            }
        }
        set {
            let sorted = newValue.sorted { ($0.hour, $0.minute) < ($1.hour, $1.minute) }
            if let first = sorted.first {
                reminderHour = first.hour
                reminderMinute = first.minute
                extraReminderTimesRaw = Self.encodeTimes(Array(sorted.dropFirst()))
            } else {
                reminderHour = 8
                reminderMinute = 0
                extraReminderTimesRaw = ""
            }
        }
    }

    var isVisibleInLists: Bool {
        !isArchived && status != .archived && status != .ended
    }

    private static func encodeTimes(_ times: [ReminderTime]) -> String {
        times.map { "\($0.hour):\($0.minute)" }.joined(separator: ",")
    }

    private static func decodeTimes(_ raw: String) -> [ReminderTime] {
        raw.split(separator: ",").compactMap { part in
            let bits = part.split(separator: ":")
            guard bits.count == 2, let h = Int(bits[0]), let m = Int(bits[1]) else { return nil }
            return ReminderTime(hour: h, minute: m)
        }
    }
}
