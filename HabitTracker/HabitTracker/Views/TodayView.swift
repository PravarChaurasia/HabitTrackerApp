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
    @State private var rescheduleHabit: Habit?
    @State private var rescheduleTime = Date()

    private var todayHabits: [Habit] {
        habits.filter { habit in
            guard habit.isVisibleInLists else { return false }
            guard HabitScheduling.isScheduled(on: Date(), habit: habit) else { return false }
            if selectedTagIDs.isEmpty { return true }
            return habit.tags.contains { selectedTagIDs.contains($0.id) }
        }.sorted {
            let lhs = HabitScheduling.effectiveStartDate(on: Date(), habit: $0)
            let rhs = HabitScheduling.effectiveStartDate(on: Date(), habit: $1)
            if lhs == rhs { return $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending }
            return lhs < rhs
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
                        ForEach(todayHabits, id: \.id) { habit in
                            todayRow(habit)
                        }
                    }
                    .listStyle(.plain)
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
            .sheet(item: $rescheduleHabit) { habit in
                rescheduleSheet(habit)
            }
            .onReceive(NotificationCenter.default.publisher(for: .habitChangeTimeRequested)) { note in
                guard let id = note.object as? UUID else { return }
                openChangeTime(for: id)
            }
            .onAppear {
                guard let raw = UserDefaults.standard.string(forKey: "pendingChangeTimeHabitID"),
                      let id = UUID(uuidString: raw) else { return }
                openChangeTime(for: id)
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
                    subtitleExtra: skipped ? "Skipped" : rowSubtitle(habit)
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
                Button("+15m") {
                    ReminderScheduler.delayToday(habit: habit, minutes: 15, context: modelContext)
                }
                .tint(.purple)
                Button("+1h") {
                    ReminderScheduler.delayToday(habit: habit, minutes: 60, context: modelContext)
                }
                .tint(.indigo)
                Button("Time") {
                    presentChangeTime(for: habit)
                }
                .tint(.blue)
            }
        }
    }

    @ViewBuilder
    private func rescheduleSheet(_ habit: Habit) -> some View {
        NavigationStack {
            Form {
                Section {
                    LabeledContent("Usual start", value: timeLabel(habit.startTime))
                    DatePicker(
                        "Today",
                        selection: $rescheduleTime,
                        displayedComponents: .hourAndMinute
                    )
                    if let duration = habit.durationMinutes, habit.durationReminderEnabled {
                        LabeledContent(
                            "End today",
                            value: rescheduleTime
                                .addingTimeInterval(TimeInterval(duration * 60))
                                .formatted(date: .omitted, time: .shortened)
                        )
                    }
                } footer: {
                    Text("This change applies only today. Tomorrow returns to \(timeLabel(habit.startTime)).")
                }

                Section("Quick changes") {
                    Button("Delay 15 minutes") {
                        ReminderScheduler.delayToday(habit: habit, minutes: 15, context: modelContext)
                        rescheduleHabit = nil
                    }
                    Button("Delay 1 hour") {
                        ReminderScheduler.delayToday(habit: habit, minutes: 60, context: modelContext)
                        rescheduleHabit = nil
                    }
                    if HabitScheduling.dayOverride(on: Date(), habit: habit) != nil {
                        Button("Restore usual time") {
                            ReminderScheduler.restoreUsualTime(habit: habit, context: modelContext)
                            rescheduleHabit = nil
                        }
                    }
                }
            }
            .navigationTitle("Change Time Today")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { rescheduleHabit = nil }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        ReminderScheduler.setOverride(
                            habit: habit,
                            startDate: rescheduleTime,
                            context: modelContext
                        )
                        rescheduleHabit = nil
                    }
                }
            }
        }
        .presentationDetents([.medium])
    }

    private func presentChangeTime(for habit: Habit) {
        rescheduleTime = HabitScheduling.effectiveStartDate(on: Date(), habit: habit)
        rescheduleHabit = habit
    }

    private func openChangeTime(for id: UUID) {
        guard let habit = habits.first(where: { $0.id == id }) else { return }
        UserDefaults.standard.removeObject(forKey: "pendingChangeTimeHabitID")
        presentChangeTime(for: habit)
    }

    private func rowSubtitle(_ habit: Habit) -> String {
        var parts = [effectiveTimeLabel(habit)]
        if let quantified = quantifiedLabel(habit) {
            parts.append(quantified)
        }
        return parts.joined(separator: " · ")
    }

    private func effectiveTimeLabel(_ habit: Habit) -> String {
        let start = HabitScheduling.effectiveStartDate(on: Date(), habit: habit)
        var label = start.formatted(date: .omitted, time: .shortened)
        if let end = HabitScheduling.effectiveEndDate(on: Date(), habit: habit) {
            label += "–\(end.formatted(date: .omitted, time: .shortened))"
        }
        if HabitScheduling.dayOverride(on: Date(), habit: habit) != nil {
            label += " · Today changed"
        }
        return label
    }

    private func timeLabel(_ time: ReminderTime) -> String {
        let date = Calendar.current.date(
            bySettingHour: time.hour,
            minute: time.minute,
            second: 0,
            of: Date()
        ) ?? Date()
        return date.formatted(date: .omitted, time: .shortened)
    }

    private func quantifiedLabel(_ habit: Habit) -> String? {
        guard habit.trackingMode != .binary else { return nil }
        let v = HabitScheduling.progressValue(on: Date(), habit: habit)
        let unit = habit.trackingMode == .duration ? "min" : ""
        return "\(Int(v))/\(Int(habit.targetValue)) \(unit)".trimmingCharacters(in: .whitespaces)
    }
}

extension Habit: Identifiable {}
