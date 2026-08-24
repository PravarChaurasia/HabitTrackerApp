import Foundation
import SwiftData

@MainActor
enum HabitActions {
    static func markDone(
        habit: Habit,
        on date: Date = Date(),
        value: Double? = nil,
        note: String? = nil,
        context: ModelContext
    ) {
        let day = CalendarDay.startOfDay(date)
        let completion = HabitScheduling.completion(on: day, habit: habit) ?? {
            let c = Completion(date: day, done: true, skipped: false, habit: habit)
            context.insert(c)
            return c
        }()
        completion.skipped = false
        completion.done = true
        if let value {
            completion.value = value
        } else if habit.trackingMode == .binary {
            completion.value = 1
        } else if completion.value < habit.targetValue {
            completion.value = habit.targetValue
        }
        if let note { completion.note = note }
        try? context.save()
        Haptics.success()
        Task {
            await ReminderScheduler.cancelToday(habit: habit, on: day)
            refreshWidget(context: context)
        }
    }

    static func toggleBinary(habit: Habit, on date: Date = Date(), context: ModelContext) {
        let day = CalendarDay.startOfDay(date)
        if HabitScheduling.isCompleted(on: day, habit: habit) {
            if let existing = HabitScheduling.completion(on: day, habit: habit) {
                context.delete(existing)
                try? context.save()
                Haptics.light()
                Task {
                    await ReminderScheduler.sync(habit: habit)
                    refreshWidget(context: context)
                }
            }
        } else {
            markDone(habit: habit, on: day, context: context)
        }
    }

    static func skip(habit: Habit, on date: Date = Date(), context: ModelContext) {
        let day = CalendarDay.startOfDay(date)
        let completion = HabitScheduling.completion(on: day, habit: habit) ?? {
            let c = Completion(date: day, done: false, skipped: true, habit: habit)
            context.insert(c)
            return c
        }()
        completion.skipped = true
        completion.done = false
        try? context.save()
        Haptics.light()
        Task {
            await ReminderScheduler.cancelToday(habit: habit, on: day)
            refreshWidget(context: context)
        }
    }

    static func addProgress(habit: Habit, amount: Double = 1, on date: Date = Date(), context: ModelContext) {
        let day = CalendarDay.startOfDay(date)
        let completion = HabitScheduling.completion(on: day, habit: habit) ?? {
            let c = Completion(date: day, done: false, skipped: false, value: 0, habit: habit)
            context.insert(c)
            return c
        }()
        completion.skipped = false
        completion.value += amount
        completion.done = completion.value >= habit.targetValue
        try? context.save()
        if completion.done {
            Haptics.success()
            Task { await ReminderScheduler.cancelToday(habit: habit, on: day) }
        } else {
            Haptics.light()
        }
        refreshWidget(context: context)
    }

    static func setNote(habit: Habit, note: String, on date: Date = Date(), context: ModelContext) {
        let day = CalendarDay.startOfDay(date)
        let completion = HabitScheduling.completion(on: day, habit: habit) ?? {
            let c = Completion(date: day, done: false, skipped: false, note: note, value: 0, habit: habit)
            context.insert(c)
            return c
        }()
        completion.note = note
        try? context.save()
        refreshWidget(context: context)
    }

    private static func refreshWidget(context: ModelContext) {
        let habits = (try? context.fetch(FetchDescriptor<Habit>())) ?? []
        WidgetSnapshot.save(from: habits)
        WidgetBridge.reload()
    }
}
