import Foundation

enum StreakCalculator {
    /// Current streak ending at `asOf`. Skipped days do not break the streak.
    static func currentStreak(for habit: Habit, asOf date: Date = Date()) -> Int {
        let doneDays = completedDaySet(for: habit)
        let skipDays = skippedDaySet(for: habit)
        guard !doneDays.isEmpty else { return 0 }

        var cursor = CalendarDay.startOfDay(date)
        if HabitScheduling.isScheduled(on: cursor, habit: habit),
           !doneDays.contains(cursor),
           !skipDays.contains(cursor) {
            cursor = CalendarDay.date(byAddingDays: -1, to: cursor)
        }

        var streak = 0
        for _ in 0..<800 {
            if cursor < CalendarDay.startOfDay(habit.startDate) { break }
            if HabitScheduling.isScheduled(on: cursor, habit: habit) {
                if skipDays.contains(cursor) {
                    // forgiven — continue without increment
                } else if doneDays.contains(cursor) {
                    streak += 1
                } else {
                    break
                }
            }
            cursor = CalendarDay.date(byAddingDays: -1, to: cursor)
        }
        return streak
    }

    static func longestStreak(for habit: Habit, asOf date: Date = Date()) -> Int {
        let doneDays = completedDaySet(for: habit)
        let skipDays = skippedDaySet(for: habit)
        guard !doneDays.isEmpty else { return 0 }

        let start = CalendarDay.startOfDay(habit.startDate)
        let end = CalendarDay.startOfDay(date)
        var best = 0
        var current = 0
        var cursor = start

        while cursor <= end {
            if HabitScheduling.isScheduled(on: cursor, habit: habit) {
                if skipDays.contains(cursor) {
                    // ignore
                } else if doneDays.contains(cursor) {
                    current += 1
                    best = max(best, current)
                } else {
                    current = 0
                }
            }
            cursor = CalendarDay.date(byAddingDays: 1, to: cursor)
        }
        return best
    }

    static func doneThisWeek(for habit: Habit, asOf date: Date = Date()) -> Int {
        let cal = CalendarDay.calendar
        guard let weekStart = cal.date(from: cal.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)) else {
            return 0
        }
        let start = CalendarDay.startOfDay(weekStart)
        let end = CalendarDay.startOfDay(date)
        return habit.completions.filter { c in
            guard c.done, !c.skipped else { return false }
            let d = CalendarDay.startOfDay(c.date)
            return d >= start && d <= end
        }.count
    }

    static func completionRate(for habit: Habit, asOf date: Date = Date(), lookbackDays: Int = 30) -> Double {
        let end = CalendarDay.startOfDay(date)
        let start = CalendarDay.date(byAddingDays: -(lookbackDays - 1), to: end)
        var scheduled = 0
        var completed = 0
        var cursor = max(start, CalendarDay.startOfDay(habit.startDate))
        while cursor <= end {
            if HabitScheduling.isScheduled(on: cursor, habit: habit) {
                if HabitScheduling.isSkipped(on: cursor, habit: habit) {
                    // excluded from rate
                } else {
                    scheduled += 1
                    if HabitScheduling.isCompleted(on: cursor, habit: habit) {
                        completed += 1
                    }
                }
            }
            cursor = CalendarDay.date(byAddingDays: 1, to: cursor)
        }
        guard scheduled > 0 else { return 0 }
        return Double(completed) / Double(scheduled)
    }

    /// Last N days heatmap: 0 empty, 1 done, 2 skipped, 3 missed (scheduled).
    static func heatmap(for habit: Habit, days: Int = 84, asOf date: Date = Date()) -> [(date: Date, state: Int)] {
        let end = CalendarDay.startOfDay(date)
        let start = CalendarDay.date(byAddingDays: -(days - 1), to: end)
        var result: [(Date, Int)] = []
        var cursor = start
        while cursor <= end {
            if !HabitScheduling.isScheduled(on: cursor, habit: habit) {
                result.append((cursor, 0))
            } else if HabitScheduling.isSkipped(on: cursor, habit: habit) {
                result.append((cursor, 2))
            } else if HabitScheduling.isCompleted(on: cursor, habit: habit) {
                result.append((cursor, 1))
            } else {
                result.append((cursor, 3))
            }
            cursor = CalendarDay.date(byAddingDays: 1, to: cursor)
        }
        return result
    }

    private static func completedDaySet(for habit: Habit) -> Set<Date> {
        Set(
            habit.completions
                .filter { $0.done && !$0.skipped }
                .map { CalendarDay.startOfDay($0.date) }
        )
    }

    private static func skippedDaySet(for habit: Habit) -> Set<Date> {
        Set(
            habit.completions
                .filter(\.skipped)
                .map { CalendarDay.startOfDay($0.date) }
        )
    }
}
