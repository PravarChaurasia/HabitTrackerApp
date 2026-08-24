import SwiftUI
import SwiftData

struct TodayView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Habit.sortOrder) private var habits: [Habit]
    @Query(sort: \Tag.name) private var tags: [Tag]
    @State private var selectedTagIDs: Set<UUID> = []
    @State private var showingEditor = false
    @State private var showingTemplates = false
    @State private var noteHabit: Habit?
    @State private var noteText = ""

    private var todayHabits: [Habit] {
        habits.filter { habit in
            guard habit.isVisibleInLists else { return false }
            guard HabitScheduling.isScheduled(on: Date(), habit: habit) else { return false }
            if selectedTagIDs.isEmpty { return true }
            return habit.tags.contains { selectedTagIDs.contains($0.id) }
        }
    }

    private var grouped: [(TimeOfDaySlot, [Habit])] {
        TimeOfDaySlot.allCases.compactMap { slot in
            let items = todayHabits.filter { effectiveSlot(for: $0) == slot }
            return items.isEmpty ? nil : (slot, items)
        }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if !tags.isEmpty {
                    TagFilterBar(tags: tags, selectedTagIDs: $selectedTagIDs)
                }

                if todayHabits.isEmpty {
                    ContentUnavailableView {
                        Label("Nothing for today", systemImage: "checkmark.circle")
                    } description: {
                        Text(habits.filter(\.isVisibleInLists).isEmpty
                             ? "Add a habit or start from a template."
                             : "No scheduled habits match this filter today.")
                    } actions: {
                        if habits.filter(\.isVisibleInLists).isEmpty {
                            Button("Browse templates") { showingTemplates = true }
                            Button("Add habit") { showingEditor = true }
                        }
                    }
                    .frame(maxHeight: .infinity)
                } else {
                    List {
                        ForEach(grouped, id: \.0) { slot, items in
                            Section(slot.title) {
                                ForEach(items, id: \.id) { habit in
                                    todayRow(habit)
                                }
                            }
                        }
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle("Today")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { showingEditor = true } label: { Image(systemName: "plus") }
                }
            }
            .sheet(isPresented: $showingEditor) {
                NavigationStack { HabitEditorView(habit: nil) }
            }
            .sheet(isPresented: $showingTemplates) {
                OnboardingView(isEmbedded: true) { showingTemplates = false }
            }
            .sheet(item: $noteHabit) { habit in
                NavigationStack {
                    Form {
                        TextField("Note for today", text: $noteText, axis: .vertical)
                            .lineLimit(3...6)
                    }
                    .navigationTitle(habit.title)
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Cancel") { noteHabit = nil }
                        }
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Save") {
                                HabitActions.setNote(habit: habit, note: noteText, context: modelContext)
                                noteHabit = nil
                            }
                        }
                    }
                    .onAppear {
                        noteText = HabitScheduling.completion(on: Date(), habit: habit)?.note ?? ""
                    }
                }
                .presentationDetents([.medium])
            }
        }
    }

    @ViewBuilder
    private func todayRow(_ habit: Habit) -> some View {
        let done = HabitScheduling.isCompleted(on: Date(), habit: habit)
        let skipped = HabitScheduling.isSkipped(on: Date(), habit: habit)

        NavigationLink {
            HabitEditorView(habit: habit)
        } label: {
            VStack(alignment: .leading, spacing: 8) {
                HabitRowView(
                    habit: habit,
                    showCheckbox: habit.trackingMode == .binary,
                    isDone: done || (habit.kind == .avoid && done),
                    subtitleExtra: skipped ? "Skipped" : quantifiedLabel(habit)
                ) {
                    HabitActions.toggleBinary(habit: habit, context: modelContext)
                }

                if habit.trackingMode != .binary {
                    HStack {
                        ProgressView(value: min(HabitScheduling.progressValue(on: Date(), habit: habit), habit.targetValue), total: max(habit.targetValue, 1))
                        Button("+1") {
                            HabitActions.addProgress(habit: habit, context: modelContext)
                        }
                        .buttonStyle(.bordered)
                    }
                }
            }
        }
        .swipeActions(edge: .trailing) {
            Button("Skip") { HabitActions.skip(habit: habit, context: modelContext) }
                .tint(.orange)
            Button("Note") {
                noteHabit = habit
            }
            .tint(.blue)
        }
        .swipeActions(edge: .leading) {
            if habit.reminderEnabled {
                Button("Snooze") {
                    Task { await ReminderScheduler.snooze(habit: habit) }
                }
                .tint(.purple)
            }
        }
    }

    private func effectiveSlot(for habit: Habit) -> TimeOfDaySlot {
        if habit.timeOfDay != .anytime { return habit.timeOfDay }
        return TimeOfDaySlot.inferred(hour: habit.reminderHour)
    }

    private func quantifiedLabel(_ habit: Habit) -> String? {
        guard habit.trackingMode != .binary else { return nil }
        let v = HabitScheduling.progressValue(on: Date(), habit: habit)
        let unit = habit.trackingMode == .duration ? "min" : ""
        return "\(Int(v))/\(Int(habit.targetValue)) \(unit)".trimmingCharacters(in: .whitespaces)
    }
}

extension Habit: Identifiable {}
