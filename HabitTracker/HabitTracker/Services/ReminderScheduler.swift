import Foundation
import SwiftData
import UserNotifications

/// Schedules local notifications only — no network.
@MainActor
enum ReminderScheduler {
    private static let center = UNUserNotificationCenter.current()
    static let startCategoryIdentifier = "HABIT_START"
    static let completeActionIdentifier = "HABIT_COMPLETE"
    static let delay15ActionIdentifier = "HABIT_DELAY_15"
    static let delay60ActionIdentifier = "HABIT_DELAY_60"
    static let changeTimeActionIdentifier = "HABIT_CHANGE_TIME"

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
                if HabitScheduling.isSkipped(on: cursor, habit: habit) {
                    cursor = CalendarDay.date(byAddingDays: 1, to: cursor)
                    continue
                }
                let completed = HabitScheduling.isCompleted(on: cursor, habit: habit)
                if !completed {
                    await scheduleStart(habit: habit, on: cursor)
                }
                if habit.durationReminderEnabled {
                    await scheduleEnd(habit: habit, on: cursor)
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

    static func cancelStartToday(habit: Habit, on date: Date = Date()) async {
        let id = notificationID(habitID: habit.id, on: date, kind: "start")
        center.removePendingNotificationRequests(withIdentifiers: [id])
        center.removeDeliveredNotifications(withIdentifiers: [id])
    }

    static func delayToday(
        habit: Habit,
        minutes: Int,
        on date: Date = Date(),
        context: ModelContext
    ) {
        let scheduled = HabitScheduling.effectiveStartDate(on: date, habit: habit)
        let baseline = CalendarDay.isSameDay(date, Date()) ? max(scheduled, Date()) : scheduled
        guard let shifted = CalendarDay.calendar.date(byAdding: .minute, value: minutes, to: baseline) else {
            return
        }
        setOverride(habit: habit, on: date, startDate: shifted, context: context)
    }

    static func setOverride(
        habit: Habit,
        on date: Date = Date(),
        startDate: Date,
        context: ModelContext
    ) {
        let components = CalendarDay.calendar.dateComponents([.hour, .minute], from: startDate)
        let time = ReminderTime(hour: components.hour ?? habit.reminderHour, minute: components.minute ?? habit.reminderMinute)
        if let existing = HabitScheduling.dayOverride(on: date, habit: habit) {
            existing.overrideTime = time
        } else {
            let override = HabitDayOverride(date: date, overrideTime: time, habit: habit)
            context.insert(override)
        }
        try? context.save()
        Task { await sync(habit: habit) }
    }

    static func restoreUsualTime(
        habit: Habit,
        on date: Date = Date(),
        context: ModelContext
    ) {
        guard let existing = HabitScheduling.dayOverride(on: date, habit: habit) else { return }
        context.delete(existing)
        try? context.save()
        Task { await sync(habit: habit) }
    }

    private static func scheduleStart(habit: Habit, on day: Date) async {
        let fire = HabitScheduling.effectiveStartDate(on: day, habit: habit)
        guard fire >= Date() else { return }

        let content = notificationContent(habit: habit, on: day)
        content.body = habit.title
        content.categoryIdentifier = startCategoryIdentifier

        await addRequest(
            identifier: notificationID(habitID: habit.id, on: day, kind: "start"),
            content: content,
            fire: fire
        )
    }

    private static func scheduleEnd(habit: Habit, on day: Date) async {
        guard let fire = HabitScheduling.effectiveEndDate(on: day, habit: habit),
              fire >= Date() else { return }

        let content = notificationContent(habit: habit, on: day)
        content.title = "Habit Tracker"
        content.body = "\(habit.title) duration ended"

        await addRequest(
            identifier: notificationID(habitID: habit.id, on: day, kind: "end"),
            content: content,
            fire: fire
        )
    }

    private static func addRequest(identifier: String, content: UNNotificationContent, fire: Date) async {
        let components = CalendarDay.calendar.dateComponents(
            [.year, .month, .day, .hour, .minute],
            from: fire
        )
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        try? await center.add(request)
    }

    private static func notificationContent(habit: Habit, on day: Date) -> UNMutableNotificationContent {
        let content = UNMutableNotificationContent()
        content.title = "Habit Tracker"
        content.sound = .default
        content.userInfo = [
            "habitID": habit.id.uuidString,
            "day": CalendarDay.startOfDay(day).timeIntervalSince1970,
        ]
        return content
    }

    private static func notificationIDPrefix(_ habitID: UUID) -> String {
        "habit.\(habitID.uuidString)."
    }

    private static func notificationID(habitID: UUID, on day: Date, kind: String) -> String {
        let f = DateFormatter()
        f.calendar = CalendarDay.calendar
        f.locale = Locale(identifier: "en_US_POSIX")
        f.timeZone = .current
        f.dateFormat = "yyyy-MM-dd"
        return "\(notificationIDPrefix(habitID))\(f.string(from: CalendarDay.startOfDay(day))).\(kind)"
    }
}

extension Notification.Name {
    static let habitChangeTimeRequested = Notification.Name("habitChangeTimeRequested")
}

final class ReminderNotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    static let shared = ReminderNotificationDelegate()

    private override init() {
        super.init()
    }

    @MainActor
    static func configure() {
        let center = UNUserNotificationCenter.current()
        center.delegate = shared
        center.setNotificationCategories([
            UNNotificationCategory(
                identifier: ReminderScheduler.startCategoryIdentifier,
                actions: [
                    UNNotificationAction(
                        identifier: ReminderScheduler.completeActionIdentifier,
                        title: "Complete"
                    ),
                    UNNotificationAction(
                        identifier: ReminderScheduler.delay15ActionIdentifier,
                        title: "Delay 15 min"
                    ),
                    UNNotificationAction(
                        identifier: ReminderScheduler.delay60ActionIdentifier,
                        title: "Delay 1 hour"
                    ),
                    UNNotificationAction(
                        identifier: ReminderScheduler.changeTimeActionIdentifier,
                        title: "Change Time",
                        options: [.foreground]
                    ),
                ],
                intentIdentifiers: []
            ),
        ])
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification
    ) async -> UNNotificationPresentationOptions {
        [.banner, .sound]
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse
    ) async {
        let info = response.notification.request.content.userInfo
        guard let rawID = info["habitID"] as? String,
              let habitID = UUID(uuidString: rawID) else { return }
        let day = (info["day"] as? TimeInterval).map(Date.init(timeIntervalSince1970:)) ?? Date()

        await MainActor.run {
            do {
                let container = try SharedStore.makeContainer()
                let context = ModelContext(container)
                let descriptor = FetchDescriptor<Habit>(
                    predicate: #Predicate { $0.id == habitID }
                )
                guard let habit = try context.fetch(descriptor).first else { return }

                switch response.actionIdentifier {
                case ReminderScheduler.completeActionIdentifier:
                    HabitActions.markDone(habit: habit, on: day, context: context)
                case ReminderScheduler.delay15ActionIdentifier:
                    ReminderScheduler.delayToday(habit: habit, minutes: 15, on: day, context: context)
                case ReminderScheduler.delay60ActionIdentifier:
                    ReminderScheduler.delayToday(habit: habit, minutes: 60, on: day, context: context)
                case ReminderScheduler.changeTimeActionIdentifier:
                    UserDefaults.standard.set(habitID.uuidString, forKey: "pendingChangeTimeHabitID")
                    NotificationCenter.default.post(
                        name: .habitChangeTimeRequested,
                        object: habitID
                    )
                default:
                    break
                }
            } catch {
                return
            }
        }
    }
}
