import SwiftUI
import SwiftData

struct HabitEditorView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \Tag.name) private var allTags: [Tag]

    let habit: Habit?

    @State private var title = ""
    @State private var notes = ""
    @State private var colorHex = HabitCatalog.colors[0].hex
    @State private var iconName = HabitCatalog.icons[0]
    @State private var startDate = CalendarDay.startOfDay()
    @State private var hasEndDate = false
    @State private var endDate = CalendarDay.startOfDay()
    @State private var frequency: FrequencyType = .daily
    @State private var selectedWeekdays: Set<Int> = [2, 4, 6]
    @State private var intervalDays = 2
    @State private var timesPerWeek = 3
    @State private var dayOfMonth = 1
    @State private var reminderEnabled = false
    @State private var reminderTime = ReminderTime(hour: 8, minute: 0)
    @State private var durationEnabled = false
    @State private var durationMinutes = 30
    @State private var status: HabitStatus = .active
    @State private var kind: HabitKind = .build
    @State private var trackingMode: TrackingMode = .binary
    @State private var targetValue: Double = 1
    @State private var isArchived = false
    @State private var selectedTagIDs: Set<UUID> = []
    @State private var newTagName = ""
    @State private var showDeleteConfirm = false
    @State private var todayNote = ""

    private var isNew: Bool { habit == nil }

    var body: some View {
        Form {
            Section("Basics") {
                TextField("Title", text: $title)
                TextField("Notes", text: $notes, axis: .vertical).lineLimit(2...4)
                Picker("Type", selection: $kind) {
                    ForEach(HabitKind.allCases) { Text($0.title).tag($0) }
                }
                Picker("Tracking", selection: $trackingMode) {
                    ForEach(TrackingMode.allCases) { Text($0.title).tag($0) }
                }
                if trackingMode != .binary {
                    Stepper(value: $targetValue, in: 1...100, step: 1) {
                        Text(trackingMode == .duration ? "Target minutes: \(Int(targetValue))" : "Target count: \(Int(targetValue))")
                    }
                }
            }

            Section("Look") {
                colorPicker
                iconPicker
            }

            Section("Schedule") {
                DatePicker("Start", selection: $startDate, displayedComponents: .date)
                Toggle("End date", isOn: $hasEndDate)
                if hasEndDate {
                    DatePicker("Ends", selection: $endDate, displayedComponents: .date)
                }
                Picker("Frequency", selection: $frequency) {
                    ForEach(FrequencyType.allCases) { Text($0.title).tag($0) }
                }
                frequencyExtras
            }

            Section("Reminder") {
                Toggle("Remind me", isOn: $reminderEnabled)
                if reminderEnabled {
                    DatePicker(
                        "Start time",
                        selection: reminderTimeBinding,
                        displayedComponents: .hourAndMinute
                    )
                    Toggle("Duration and end reminder", isOn: $durationEnabled)
                    if durationEnabled {
                        Stepper(
                            "Duration: \(durationLabel)",
                            value: $durationMinutes,
                            in: 5...720,
                            step: 5
                        )
                        LabeledContent("End reminder", value: endReminderLabel)
                        Text("The end reminder always fires, even after you complete the habit.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }

            Section("Tags") {
                ForEach(allTags, id: \.id) { tag in
                    Button { toggleTag(tag.id) } label: {
                        HStack {
                            Circle().fill(HabitCatalog.color(from: tag.colorHex)).frame(width: 10, height: 10)
                            Text(tag.name).foregroundStyle(.primary)
                            Spacer()
                            if selectedTagIDs.contains(tag.id) { Image(systemName: "checkmark") }
                        }
                    }
                }
                HStack {
                    TextField("New tag", text: $newTagName)
                    Button("Add") { addTag() }
                        .disabled(newTagName.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }

            if let habit {
                Section("Today note") {
                    TextField("Journal note", text: $todayNote, axis: .vertical)
                        .lineLimit(2...4)
                    Button("Save note") {
                        HabitActions.setNote(habit: habit, note: todayNote, context: modelContext)
                    }
                }

                Section("Progress") {
                    LabeledContent("Current streak", value: "\(StreakCalculator.currentStreak(for: habit))")
                    LabeledContent("Longest streak", value: "\(StreakCalculator.longestStreak(for: habit))")
                    LabeledContent("Done this week", value: "\(StreakCalculator.doneThisWeek(for: habit))")
                    LabeledContent("30-day rate", value: "\(Int(StreakCalculator.completionRate(for: habit) * 100))%")
                }

                Section("Heatmap (12 weeks)") {
                    HeatmapGrid(
                        cells: StreakCalculator.heatmap(for: habit),
                        color: HabitCatalog.color(from: habit.colorHex)
                    )
                    .padding(.vertical, 4)
                    Text("Green = done · Orange = skipped · Gray = missed")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }

                Section {
                    Picker("Status", selection: $status) {
                        Text("Active").tag(HabitStatus.active)
                        Text("Paused").tag(HabitStatus.paused)
                    }
                    Toggle("Archived", isOn: $isArchived)
                }

                Section {
                    Button("Delete Habit", role: .destructive) { showDeleteConfirm = true }
                }
            }
        }
        .navigationTitle(isNew ? "New Habit" : "Edit Habit")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                if isNew { Button("Cancel") { dismiss() } }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") { save() }
                    .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty)
            }
        }
        .onAppear(perform: load)
        .confirmationDialog("Delete this habit?", isPresented: $showDeleteConfirm, titleVisibility: .visible) {
            Button("Delete", role: .destructive, action: deleteHabit)
            Button("Cancel", role: .cancel) {}
        }
    }

    @ViewBuilder
    private var frequencyExtras: some View {
        switch frequency {
        case .weekdays:
            weekdayPicker
        case .everyNDays:
            Stepper("Every \(intervalDays) day(s)", value: $intervalDays, in: 1...30)
        case .nTimesPerWeek:
            Stepper("\(timesPerWeek)× per week", value: $timesPerWeek, in: 1...7)
        case .monthly:
            Stepper("Day of month: \(dayOfMonth)", value: $dayOfMonth, in: 1...31)
        case .daily:
            EmptyView()
        }
    }

    private var colorPicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(HabitCatalog.colors, id: \.hex) { item in
                    Circle()
                        .fill(HabitCatalog.color(from: item.hex))
                        .frame(width: 28, height: 28)
                        .overlay {
                            if colorHex == item.hex {
                                Image(systemName: "checkmark").font(.caption.bold()).foregroundStyle(.white)
                            }
                        }
                        .onTapGesture { colorHex = item.hex }
                }
            }
        }
    }

    private var iconPicker: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6), spacing: 12) {
            ForEach(HabitCatalog.icons, id: \.self) { icon in
                Image(systemName: icon)
                    .frame(width: 36, height: 36)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(iconName == icon ? HabitCatalog.color(from: colorHex).opacity(0.2) : Color(.secondarySystemBackground))
                    )
                    .onTapGesture { iconName = icon }
            }
        }
    }

    private var weekdayPicker: some View {
        HStack {
            ForEach(Weekday.allCases) { day in
                Button {
                    if selectedWeekdays.contains(day.rawValue) {
                        selectedWeekdays.remove(day.rawValue)
                    } else {
                        selectedWeekdays.insert(day.rawValue)
                    }
                } label: {
                    Text(day.shortTitle)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(
                            selectedWeekdays.contains(day.rawValue)
                            ? HabitCatalog.color(from: colorHex).opacity(0.25)
                            : Color(.secondarySystemBackground)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var reminderTimeBinding: Binding<Date> {
        Binding(
            get: {
                Calendar.current.date(
                    bySettingHour: reminderTime.hour,
                    minute: reminderTime.minute,
                    second: 0,
                    of: Date()
                ) ?? Date()
            },
            set: { date in
                let c = Calendar.current.dateComponents([.hour, .minute], from: date)
                reminderTime = ReminderTime(hour: c.hour ?? 8, minute: c.minute ?? 0)
            }
        )
    }

    private var durationLabel: String {
        let hours = durationMinutes / 60
        let minutes = durationMinutes % 60
        if hours == 0 { return "\(minutes) min" }
        if minutes == 0 { return "\(hours) hr" }
        return "\(hours) hr \(minutes) min"
    }

    private var endReminderLabel: String {
        let start = Calendar.current.date(
            bySettingHour: reminderTime.hour,
            minute: reminderTime.minute,
            second: 0,
            of: Date()
        ) ?? Date()
        let end = Calendar.current.date(byAdding: .minute, value: durationMinutes, to: start) ?? start
        return end.formatted(date: .omitted, time: .shortened)
    }

    private func load() {
        guard let habit else { return }
        title = habit.title
        notes = habit.notes
        colorHex = habit.colorHex
        iconName = habit.iconName
        startDate = habit.startDate
        if let end = habit.endDate {
            hasEndDate = true
            endDate = end
        }
        frequency = habit.frequency
        selectedWeekdays = Set(habit.weekdays)
        intervalDays = habit.intervalDays
        timesPerWeek = habit.timesPerWeek
        dayOfMonth = habit.dayOfMonth
        reminderEnabled = habit.reminderEnabled
        reminderTime = habit.startTime
        durationEnabled = habit.durationReminderEnabled && habit.durationMinutes != nil
        durationMinutes = habit.durationMinutes ?? 30
        status = habit.status == .archived ? .paused : habit.status
        kind = habit.kind
        trackingMode = habit.trackingMode
        targetValue = habit.targetValue
        isArchived = habit.isArchived || habit.status == .archived
        selectedTagIDs = Set(habit.tags.map(\.id))
        todayNote = HabitScheduling.completion(on: Date(), habit: habit)?.note ?? ""
    }

    private func toggleTag(_ id: UUID) {
        if selectedTagIDs.contains(id) { selectedTagIDs.remove(id) } else { selectedTagIDs.insert(id) }
    }

    private func addTag() {
        let name = newTagName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !name.isEmpty else { return }
        if let existing = allTags.first(where: { $0.name.localizedCaseInsensitiveCompare(name) == .orderedSame }) {
            selectedTagIDs.insert(existing.id)
        } else {
            let tag = Tag(name: name, colorHex: colorHex)
            modelContext.insert(tag)
            selectedTagIDs.insert(tag.id)
        }
        newTagName = ""
        try? modelContext.save()
    }

    private func save() {
        let weekdays = frequency == .weekdays ? Array(selectedWeekdays).sorted() : []
        let target: Habit
        if let habit {
            target = habit
        } else {
            let created = Habit(title: title)
            modelContext.insert(created)
            target = created
        }

        target.title = title.trimmingCharacters(in: .whitespacesAndNewlines)
        target.notes = notes
        target.colorHex = colorHex
        target.iconName = iconName
        target.startDate = CalendarDay.startOfDay(startDate)
        target.endDate = hasEndDate ? CalendarDay.startOfDay(endDate) : nil
        target.frequency = frequency
        target.weekdays = weekdays
        target.intervalDays = intervalDays
        target.timesPerWeek = timesPerWeek
        target.dayOfMonth = dayOfMonth
        target.reminderEnabled = reminderEnabled
        target.startTime = reminderTime
        target.durationMinutes = durationEnabled ? durationMinutes : nil
        target.durationReminderEnabled = durationEnabled
        target.extraReminderTimesRaw = ""
        target.status = isArchived ? .archived : status
        target.isArchived = isArchived
        target.kind = kind
        target.trackingMode = trackingMode
        target.targetValue = targetValue
        target.tags = allTags.filter { selectedTagIDs.contains($0.id) }

        try? modelContext.save()
        Task {
            await ReminderScheduler.sync(habit: target)
            WidgetBridge.reload()
        }
        dismiss()
    }

    private func deleteHabit() {
        guard let habit else { return }
        let id = habit.id
        Task { await ReminderScheduler.cancel(habitID: id) }
        modelContext.delete(habit)
        try? modelContext.save()
        WidgetBridge.reload()
        dismiss()
    }
}
