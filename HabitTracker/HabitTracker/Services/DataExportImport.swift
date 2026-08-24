import Foundation
import SwiftData
import UniformTypeIdentifiers

enum DataExportImport {
    static let utType = UTType.json

    struct Snapshot: Codable {
        var exportedAt: Date
        var habits: [HabitDTO]
        var tags: [TagDTO]
        var completions: [CompletionDTO]
    }

    struct HabitDTO: Codable {
        var id: UUID
        var title: String
        var notes: String
        var colorHex: String
        var iconName: String
        var startDate: Date
        var endDate: Date?
        var frequencyRaw: String
        var weekdaysRaw: String
        var intervalDays: Int
        var timesPerWeek: Int
        var dayOfMonth: Int
        var reminderEnabled: Bool
        var reminderHour: Int
        var reminderMinute: Int
        var extraReminderTimesRaw: String
        var snoozeMinutes: Int
        var statusRaw: String
        var kindRaw: String
        var trackingModeRaw: String
        var targetValue: Double
        var timeOfDayRaw: String
        var isArchived: Bool
        var sortOrder: Int
        var tagIDs: [UUID]
    }

    struct TagDTO: Codable {
        var id: UUID
        var name: String
        var colorHex: String
    }

    struct CompletionDTO: Codable {
        var id: UUID
        var habitID: UUID
        var date: Date
        var done: Bool
        var skipped: Bool
        var note: String
        var value: Double
    }

    static func exportJSON(habits: [Habit], tags: [Tag]) throws -> Data {
        let snapshot = Snapshot(
            exportedAt: Date(),
            habits: habits.map { h in
                HabitDTO(
                    id: h.id,
                    title: h.title,
                    notes: h.notes,
                    colorHex: h.colorHex,
                    iconName: h.iconName,
                    startDate: h.startDate,
                    endDate: h.endDate,
                    frequencyRaw: h.frequencyRaw,
                    weekdaysRaw: h.weekdaysRaw,
                    intervalDays: h.intervalDays,
                    timesPerWeek: h.timesPerWeek,
                    dayOfMonth: h.dayOfMonth,
                    reminderEnabled: h.reminderEnabled,
                    reminderHour: h.reminderHour,
                    reminderMinute: h.reminderMinute,
                    extraReminderTimesRaw: h.extraReminderTimesRaw,
                    snoozeMinutes: h.snoozeMinutes,
                    statusRaw: h.statusRaw,
                    kindRaw: h.kindRaw,
                    trackingModeRaw: h.trackingModeRaw,
                    targetValue: h.targetValue,
                    timeOfDayRaw: h.timeOfDayRaw,
                    isArchived: h.isArchived,
                    sortOrder: h.sortOrder,
                    tagIDs: h.tags.map(\.id)
                )
            },
            tags: tags.map { TagDTO(id: $0.id, name: $0.name, colorHex: $0.colorHex) },
            completions: habits.flatMap { h in
                h.completions.map { c in
                    CompletionDTO(
                        id: c.id,
                        habitID: h.id,
                        date: c.date,
                        done: c.done,
                        skipped: c.skipped,
                        note: c.note,
                        value: c.value
                    )
                }
            }
        )
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        return try encoder.encode(snapshot)
    }

    @MainActor
    static func importJSON(_ data: Data, into context: ModelContext, replace: Bool) throws {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let snapshot = try decoder.decode(Snapshot.self, from: data)

        if replace {
            for item in try context.fetch(FetchDescriptor<Completion>()) { context.delete(item) }
            for item in try context.fetch(FetchDescriptor<Habit>()) { context.delete(item) }
            for item in try context.fetch(FetchDescriptor<Tag>()) { context.delete(item) }
        }

        var tagMap: [UUID: Tag] = [:]
        for dto in snapshot.tags {
            let tag = Tag(name: dto.name, colorHex: dto.colorHex)
            tag.id = dto.id
            context.insert(tag)
            tagMap[dto.id] = tag
        }

        var habitMap: [UUID: Habit] = [:]
        for dto in snapshot.habits {
            let habit = Habit(
                title: dto.title,
                notes: dto.notes,
                colorHex: dto.colorHex,
                iconName: dto.iconName,
                startDate: dto.startDate,
                endDate: dto.endDate,
                frequency: FrequencyType(rawValue: dto.frequencyRaw) ?? .daily,
                weekdays: dto.weekdaysRaw.split(separator: ",").compactMap { Int($0) },
                intervalDays: dto.intervalDays,
                timesPerWeek: dto.timesPerWeek,
                dayOfMonth: dto.dayOfMonth,
                reminderEnabled: dto.reminderEnabled,
                reminderHour: dto.reminderHour,
                reminderMinute: dto.reminderMinute,
                snoozeMinutes: dto.snoozeMinutes,
                status: HabitStatus(rawValue: dto.statusRaw) ?? .active,
                kind: HabitKind(rawValue: dto.kindRaw) ?? .build,
                trackingMode: TrackingMode(rawValue: dto.trackingModeRaw) ?? .binary,
                targetValue: dto.targetValue,
                timeOfDay: TimeOfDaySlot(rawValue: dto.timeOfDayRaw) ?? .anytime,
                isArchived: dto.isArchived,
                sortOrder: dto.sortOrder
            )
            habit.id = dto.id
            habit.extraReminderTimesRaw = dto.extraReminderTimesRaw
            habit.tags = dto.tagIDs.compactMap { tagMap[$0] }
            context.insert(habit)
            habitMap[dto.id] = habit
        }

        for dto in snapshot.completions {
            guard let habit = habitMap[dto.habitID] else { continue }
            let c = Completion(
                date: dto.date,
                done: dto.done,
                skipped: dto.skipped,
                note: dto.note,
                value: dto.value,
                habit: habit
            )
            c.id = dto.id
            context.insert(c)
        }

        try context.save()
    }
}
