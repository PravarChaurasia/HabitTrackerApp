import Foundation
import UserNotifications

/// Schedules local notifications only — no network.
@MainActor
enum ReminderScheduler {
    private static let center = UNUserNotificationCenter.current()

    static func requestAuthorizationIfNeeded() async -> Bool {
        let settings = await center.notificationSettings()
        switch settings.authorizationStatus {
        case .authorized, .provisional, .ephemeral:
            return true
        case .notDetermined:
            do {
                return try await center.requestAuthorization(options: [.alert, .sound, .badge])
            } catch {
                return false
            }
        default:
            return false
        }
    }

    static func authorizationStatus() async -> UNAuthorizationStatus {
        await center.notificationSettings().authorizationStatus
    }

    static func sync(habit: Habit) async {
        await cancel(habitID: habit.id)

        guard habit.reminderEnabled,
              habit.status == .active,
              !habit.isArchived else { return }

        let granted = await requestAuthorizationIfNeeded()
        guard granted else { return }

        let today = CalendarDay.startOfDay()
        var scheduledDays = 0
        var cursor = today
        while scheduledDays < 14 {
            if HabitScheduling.isScheduled(on: cursor, habit: habit) {
                if CalendarDay.isSameDay(cursor, today), HabitScheduling.isCompleted(on: today, habit: habit) {
                    cursor = CalendarDay.date(byAddingDays: 1, to: cursor)
                    continue
                }
                if HabitScheduling.isSkipped(on: cursor, habit: habit) {
                    cursor = CalendarDay.date(byAddingDays: 1, to: cursor)
                    continue
                }
                for time in habit.reminderTimes {
                    await scheduleOne(habit: habit, on: cursor, time: time)
                }
                scheduledDays += 1
            }
            cursor = CalendarDay.date(byAddingDays: 1, to: cursor)
            if let end = habit.endDate, cursor > CalendarDay.startOfDay(end) { break }
        }
    }

    static func cancel(habitID: UUID) async {
        let prefix = notificationIDPrefix(habitID)
        let pending = await center.pendingNotificationRequests()
        let ids = pending.map(\.identifier).filter { $0.hasPrefix(prefix) }
        center.removePendingNotificationRequests(withIdentifiers: ids)
        center.removeDeliveredNotifications(withIdentifiers: ids)
    }

    static func cancelToday(habit: Habit, on date: Date = Date()) async {
        let ids = habit.reminderTimes.map { notificationID(habitID: habit.id, on: date, time: $0) }
        center.removePendingNotificationRequests(withIdentifiers: ids)
        center.removeDeliveredNotifications(withIdentifiers: ids)
    }

    static func snooze(habit: Habit, minutes: Int? = nil) async {
        let mins = minutes ?? max(1, habit.snoozeMinutes)
        guard let fire = CalendarDay.calendar.date(byAdding: .minute, value: mins, to: Date()) else { return }

        let content = UNMutableNotificationContent()
        content.title = "Habit Tracker"
        content.body = "Snoozed: \(habit.title)"
        content.sound = .default

        let comps = CalendarDay.calendar.dateComponents([.year, .month, .day, .hour, .minute], from: fire)
        let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: false)
        let request = UNNotificationRequest(
            identifier: "habit.\(habit.id.uuidString).snooze",
            content: content,
            trigger: trigger
        )
        try? await center.add(request)
    }

    private static func scheduleOne(habit: Habit, on day: Date, time: ReminderTime) async {
        var components = CalendarDay.calendar.dateComponents([.year, .month, .day], from: day)
        components.hour = time.hour
        components.minute = time.minute

        if let fire = CalendarDay.calendar.date(from: components), fire < Date() {
            return
        }

        let content = UNMutableNotificationContent()
        content.title = "Habit Tracker"
        content.body = habit.title
        content.sound = .default

        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let request = UNNotificationRequest(
            identifier: notificationID(habitID: habit.id, on: day, time: time),
            content: content,
            trigger: trigger
        )
        try? await center.add(request)
    }

    private static func notificationIDPrefix(_ habitID: UUID) -> String {
        "habit.\(habitID.uuidString)."
    }

    private static func notificationID(habitID: UUID, on day: Date, time: ReminderTime) -> String {
        let f = DateFormatter()
        f.calendar = CalendarDay.calendar
        f.locale = Locale(identifier: "en_US_POSIX")
        f.timeZone = .current
        f.dateFormat = "yyyy-MM-dd"
        return "\(notificationIDPrefix(habitID))\(f.string(from: CalendarDay.startOfDay(day))).\(time.hour)-\(time.minute)"
    }
}
