import Foundation

enum HabitScheduling {
    static func dayOverride(on date: Date, habit: Habit) -> HabitDayOverride? {
        habit.dayOverrides.first { CalendarDay.isSameDay($0.date, date) }
    }

    static func effectiveStartTime(on date: Date, habit: Habit) -> ReminderTime {
        dayOverride(on: date, habit: habit)?.overrideTime ?? habit.startTime
    }

    static func effectiveStartDate(on date: Date, habit: Habit) -> Date {
        let time = effectiveStartTime(on: date, habit: habit)
        var components = CalendarDay.calendar.dateComponents([.year, .month, .day], from: date)
        components.hour = time.hour
        components.minute = time.minute
        return CalendarDay.calendar.date(from: components) ?? CalendarDay.startOfDay(date)
    }

    static func effectiveEndDate(on date: Date, habit: Habit) -> Date? {
        guard habit.durationReminderEnabled,
              let duration = habit.durationMinutes,
              duration > 0 else { return nil }
        return CalendarDay.calendar.date(
            byAdding: .minute,
            value: duration,
            to: effectiveStartDate(on: date, habit: habit)
        )
    }

    static func isScheduled(on date: Date, habit: Habit) -> Bool {
        guard habit.status == .active, !habit.isArchived else { return false }

        let day = CalendarDay.startOfDay(date)
        let start = CalendarDay.startOfDay(habit.startDate)
        guard day >= start else { return false }

        if let end = habit.endDate, day > CalendarDay.startOfDay(end) {
            return false
        }

        switch habit.frequency {
        case .daily:
            return true
        case .weekdays:
            return habit.weekdays.contains(CalendarDay.weekday(for: day))
        case .everyNDays:
            let delta = CalendarDay.daysBetween(start, day)
            return delta % max(1, habit.intervalDays) == 0
        case .nTimesPerWeek:
            // Show every day of the week until weekly target is met (or always show if under target).
            let doneCount = completionsThisWeek(habit: habit, containing: day)
            return doneCount < habit.timesPerWeek || isCompleted(on: day, habit: habit) || isSkipped(on: day, habit: habit)
        case .monthly:
            let dom = CalendarDay.calendar.component(.day, from: day)
            let lastDay = CalendarDay.calendar.range(of: .day, in: .month, for: day)?.count ?? 31
            let target = min(habit.dayOfMonth, lastDay)
            return dom == target
        }
    }

    static func isCompleted(on date: Date, habit: Habit) -> Bool {
        let day = CalendarDay.startOfDay(date)
        guard let c = completion(on: day, habit: habit) else { return false }
        if habit.kind == .avoid {
            // Avoid habits: "done" means successfully avoided (checked).
            return c.done && !c.skipped
        }
        if habit.trackingMode == .binary {
            return c.done && !c.skipped
        }
        return !c.skipped && c.done && c.value >= habit.targetValue
    }

    static func isSkipped(on date: Date, habit: Habit) -> Bool {
        completion(on: CalendarDay.startOfDay(date), habit: habit)?.skipped == true
    }

    static func completion(on date: Date, habit: Habit) -> Completion? {
        let day = CalendarDay.startOfDay(date)
        return habit.completions.first { CalendarDay.isSameDay($0.date, day) }
    }

    static func progressValue(on date: Date, habit: Habit) -> Double {
        completion(on: date, habit: habit)?.value ?? 0
    }

    private static func completionsThisWeek(habit: Habit, containing date: Date) -> Int {
        let cal = CalendarDay.calendar
        guard let weekStart = cal.date(from: cal.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)) else {
            return 0
        }
        let start = CalendarDay.startOfDay(weekStart)
        let end = CalendarDay.date(byAddingDays: 6, to: start)
        return habit.completions.filter { c in
            guard c.done, !c.skipped else { return false }
            let d = CalendarDay.startOfDay(c.date)
            return d >= start && d <= end
        }.count
    }
}
