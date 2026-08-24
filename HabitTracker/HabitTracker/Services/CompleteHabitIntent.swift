import AppIntents
import SwiftData

struct HabitEntity: AppEntity {
    static var typeDisplayRepresentation: TypeDisplayRepresentation = "Habit"
    static var defaultQuery = HabitEntityQuery()

    var id: UUID
    var title: String

    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(title)")
    }
}

struct HabitEntityQuery: EntityStringQuery {
    func entities(for identifiers: [UUID]) async throws -> [HabitEntity] {
        let idSet = Set(identifiers)
        return try await loadEntities().filter { idSet.contains($0.id) }
    }

    func suggestedEntities() async throws -> [HabitEntity] {
        try await loadEntities()
    }

    func entities(matching string: String) async throws -> [HabitEntity] {
        try await loadEntities().filter {
            $0.title.localizedCaseInsensitiveContains(string)
        }
    }

    @MainActor
    private func loadEntities() throws -> [HabitEntity] {
        try fetchActiveHabits().map { HabitEntity(id: $0.id, title: $0.title) }
    }
}

struct CompleteHabitIntent: AppIntent {
    static var title: LocalizedStringResource = "Complete Habit"
    static var description = IntentDescription("Mark a habit complete for today (on-device only).")

    @Parameter(title: "Habit")
    var habit: HabitEntity

    static var parameterSummary: some ParameterSummary {
        Summary("Complete \(\.$habit)")
    }

    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        let container = try SharedStore.makeContainer()
        let context = ModelContext(container)
        let habitID = habit.id
        let descriptor = FetchDescriptor<Habit>(
            predicate: #Predicate { $0.id == habitID && $0.isArchived == false }
        )
        guard let model = try context.fetch(descriptor).first else {
            return .result(dialog: "No habit named \(habit.title) found.")
        }
        HabitActions.markDone(habit: model, context: context)
        return .result(dialog: "Completed \(model.title).")
    }
}

struct HabitShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: CompleteHabitIntent(),
            phrases: [
                "Complete \(\.$habit) in \(.applicationName)",
                "Log \(\.$habit) with \(.applicationName)"
            ],
            shortTitle: "Complete Habit",
            systemImageName: "checkmark.circle"
        )
    }
}

@MainActor
private func fetchActiveHabits() throws -> [Habit] {
    let container = try SharedStore.makeContainer()
    let context = ModelContext(container)
    let descriptor = FetchDescriptor<Habit>(
        predicate: #Predicate { $0.isArchived == false },
        sortBy: [SortDescriptor(\.sortOrder), SortDescriptor(\.title)]
    )
    return try context.fetch(descriptor)
}
