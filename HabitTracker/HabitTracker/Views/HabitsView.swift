import SwiftUI
import SwiftData

struct HabitsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Habit.sortOrder) private var habits: [Habit]
    @Query(sort: \Tag.name) private var tags: [Tag]
    @State private var selectedTagIDs: Set<UUID> = []
    @State private var showingEditor = false
    @State private var showArchived = false

    private var filtered: [Habit] {
        habits.filter { habit in
            if showArchived {
                guard habit.isArchived || habit.status == .archived else { return false }
            } else {
                guard habit.isVisibleInLists else { return false }
            }
            if selectedTagIDs.isEmpty { return true }
            return habit.tags.contains { selectedTagIDs.contains($0.id) }
        }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if !tags.isEmpty {
                    TagFilterBar(tags: tags, selectedTagIDs: $selectedTagIDs)
                }

                if filtered.isEmpty {
                    ContentUnavailableView(
                        showArchived ? "No archived habits" : "No habits",
                        systemImage: "list.bullet",
                        description: Text(showArchived ? "Archive habits from the editor." : "Tap + to create your first habit.")
                    )
                } else {
                    List {
                        ForEach(filtered, id: \.id) { habit in
                            NavigationLink {
                                HabitEditorView(habit: habit)
                            } label: {
                                HabitRowView(habit: habit)
                            }
                        }
                        .onMove(perform: showArchived ? nil : move)
                    }
                    .listStyle(.plain)
                    .toolbar {
                        EditButton()
                    }
                }
            }
            .navigationTitle("Habits")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(showArchived ? "Active" : "Archived") {
                        showArchived.toggle()
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button { showingEditor = true } label: { Image(systemName: "plus") }
                }
            }
            .sheet(isPresented: $showingEditor) {
                NavigationStack { HabitEditorView(habit: nil) }
            }
        }
    }

    private func move(from source: IndexSet, to destination: Int) {
        var ordered = filtered
        ordered.move(fromOffsets: source, toOffset: destination)
        for (index, habit) in ordered.enumerated() {
            habit.sortOrder = index
        }
        try? modelContext.save()
    }
}
