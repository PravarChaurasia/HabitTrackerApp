import Foundation
import SwiftData

@Model
final class Completion {
    var id: UUID
    var date: Date
    var done: Bool
    /// Skip / vacation — does not break streak and does not count as done.
    var skipped: Bool
    var note: String
    /// Progress toward quantified target (count or minutes).
    var value: Double
    var habit: Habit?

    init(
        date: Date = CalendarDay.startOfDay(),
        done: Bool = true,
        skipped: Bool = false,
        note: String = "",
        value: Double = 1,
        habit: Habit? = nil
    ) {
        self.id = UUID()
        self.date = CalendarDay.startOfDay(date)
        self.done = done
        self.skipped = skipped
        self.note = note
        self.value = value
        self.habit = habit
    }
}
