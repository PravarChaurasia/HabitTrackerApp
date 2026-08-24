import SwiftUI
import SwiftData

struct InsightsView: View {
    @Query(sort: \Habit.sortOrder) private var habits: [Habit]

    private var active: [Habit] {
        habits.filter(\.isVisibleInLists)
    }

    var body: some View {
        NavigationStack {
            List {
                Section("Overview") {
                    LabeledContent("Active habits", value: "\(active.count)")
                    LabeledContent(
                        "Avg 30-day rate",
                        value: "\(Int((averageRate) * 100))%"
                    )
                }

                Section("By habit") {
                    if active.isEmpty {
                        Text("No active habits yet").foregroundStyle(.secondary)
                    } else {
                        ForEach(active, id: \.id) { habit in
                            NavigationLink {
                                HabitEditorView(habit: habit)
                            } label: {
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack {
                                        Image(systemName: habit.iconName)
                                            .foregroundStyle(HabitCatalog.color(from: habit.colorHex))
                                        Text(habit.title).font(.headline)
                                        Spacer()
                                        Text("\(Int(StreakCalculator.completionRate(for: habit) * 100))%")
                                            .foregroundStyle(.secondary)
                                    }
                                    HeatmapGrid(
                                        cells: StreakCalculator.heatmap(for: habit, days: 28),
                                        color: HabitCatalog.color(from: habit.colorHex)
                                    )
                                    .frame(height: 56)
                                    HStack {
                                        Text("Streak \(StreakCalculator.currentStreak(for: habit))")
                                        Spacer()
                                        Text("Best \(StreakCalculator.longestStreak(for: habit))")
                                        Spacer()
                                        Text("Week \(StreakCalculator.doneThisWeek(for: habit))")
                                    }
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                }
                                .padding(.vertical, 4)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Insights")
        }
    }

    private var averageRate: Double {
        guard !active.isEmpty else { return 0 }
        let sum = active.reduce(0.0) { $0 + StreakCalculator.completionRate(for: $1) }
        return sum / Double(active.count)
    }
}
