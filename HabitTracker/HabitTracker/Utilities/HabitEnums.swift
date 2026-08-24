import Foundation

enum HabitStatus: String, Codable, CaseIterable, Identifiable {
    case active
    case paused
    case ended
    case archived

    var id: String { rawValue }

    var title: String { rawValue.capitalized }
}

enum FrequencyType: String, Codable, CaseIterable, Identifiable {
    case daily
    case weekdays
    case everyNDays
    case nTimesPerWeek
    case monthly

    var id: String { rawValue }

    var title: String {
        switch self {
        case .daily: return "Daily"
        case .weekdays: return "Specific days"
        case .everyNDays: return "Every N days"
        case .nTimesPerWeek: return "N times / week"
        case .monthly: return "Monthly"
        }
    }
}

enum HabitKind: String, Codable, CaseIterable, Identifiable {
    case build
    case avoid

    var id: String { rawValue }

    var title: String {
        switch self {
        case .build: return "Build"
        case .avoid: return "Avoid"
        }
    }
}

enum TrackingMode: String, Codable, CaseIterable, Identifiable {
    case binary
    case count
    case duration

    var id: String { rawValue }

    var title: String {
        switch self {
        case .binary: return "Yes / No"
        case .count: return "Count"
        case .duration: return "Duration (min)"
        }
    }
}

enum TimeOfDaySlot: String, Codable, CaseIterable, Identifiable {
    case morning
    case afternoon
    case evening
    case anytime

    var id: String { rawValue }

    var title: String {
        switch self {
        case .morning: return "Morning"
        case .afternoon: return "Afternoon"
        case .evening: return "Evening"
        case .anytime: return "Anytime"
        }
    }

    /// Hour ranges used for auto-slot from reminder time.
    var hourRange: Range<Int>? {
        switch self {
        case .morning: return 5..<12
        case .afternoon: return 12..<17
        case .evening: return 17..<22
        case .anytime: return nil
        }
    }

    static func inferred(hour: Int) -> TimeOfDaySlot {
        if (5..<12).contains(hour) { return .morning }
        if (12..<17).contains(hour) { return .afternoon }
        if (17..<22).contains(hour) { return .evening }
        return .anytime
    }
}

/// ISO weekday: 1 = Sunday … 7 = Saturday (Calendar.Component.weekday)
enum Weekday: Int, CaseIterable, Identifiable, Codable {
    case sunday = 1
    case monday = 2
    case tuesday = 3
    case wednesday = 4
    case thursday = 5
    case friday = 6
    case saturday = 7

    var id: Int { rawValue }

    var shortTitle: String {
        switch self {
        case .sunday: return "S"
        case .monday: return "M"
        case .tuesday: return "T"
        case .wednesday: return "W"
        case .thursday: return "T"
        case .friday: return "F"
        case .saturday: return "S"
        }
    }

    var title: String {
        switch self {
        case .sunday: return "Sun"
        case .monday: return "Mon"
        case .tuesday: return "Tue"
        case .wednesday: return "Wed"
        case .thursday: return "Thu"
        case .friday: return "Fri"
        case .saturday: return "Sat"
        }
    }
}

struct ReminderTime: Hashable, Identifiable, Codable {
    var hour: Int
    var minute: Int

    var id: String { "\(hour):\(minute)" }

    var label: String {
        String(format: "%02d:%02d", hour, minute)
    }
}
