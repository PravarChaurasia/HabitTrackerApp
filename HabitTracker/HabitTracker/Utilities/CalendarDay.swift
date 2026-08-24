import Foundation

enum CalendarDay {
    static var calendar: Calendar {
        var cal = Calendar.current
        cal.timeZone = .current
        return cal
    }

    /// Start of the local calendar day for `date`.
    static func startOfDay(_ date: Date = Date()) -> Date {
        calendar.startOfDay(for: date)
    }

    static func weekday(for date: Date = Date()) -> Int {
        calendar.component(.weekday, from: date)
    }

    static func isSameDay(_ a: Date, _ b: Date) -> Bool {
        calendar.isDate(a, inSameDayAs: b)
    }

    static func daysBetween(_ from: Date, _ to: Date) -> Int {
        let start = startOfDay(from)
        let end = startOfDay(to)
        return calendar.dateComponents([.day], from: start, to: end).day ?? 0
    }

    static func date(byAddingDays days: Int, to date: Date) -> Date {
        calendar.date(byAdding: .day, value: days, to: startOfDay(date)) ?? startOfDay(date)
    }

    static func formatted(_ date: Date, style: DateFormatter.Style = .medium) -> String {
        let f = DateFormatter()
        f.dateStyle = style
        f.timeStyle = .none
        f.calendar = calendar
        f.timeZone = .current
        return f.string(from: date)
    }
}
