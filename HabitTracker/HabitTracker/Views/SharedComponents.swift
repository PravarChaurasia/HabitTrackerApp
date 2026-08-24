import SwiftUI
import SwiftData

struct TagFilterBar: View {
    let tags: [Tag]
    @Binding var selectedTagIDs: Set<UUID>

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                filterChip(title: "All", selected: selectedTagIDs.isEmpty) {
                    selectedTagIDs.removeAll()
                }
                ForEach(tags, id: \.id) { tag in
                    filterChip(
                        title: tag.name,
                        selected: selectedTagIDs.contains(tag.id),
                        color: HabitCatalog.color(from: tag.colorHex)
                    ) {
                        if selectedTagIDs.contains(tag.id) {
                            selectedTagIDs.remove(tag.id)
                        } else {
                            selectedTagIDs.insert(tag.id)
                        }
                    }
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 4)
        }
    }

    private func filterChip(title: String, selected: Bool, color: Color = .accentColor, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline.weight(.medium))
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(selected ? color.opacity(0.2) : Color(.secondarySystemBackground))
                .foregroundStyle(selected ? color : .primary)
                .clipShape(Capsule())
                .overlay(
                    Capsule()
                        .strokeBorder(selected ? color : Color.clear, lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
    }
}

struct HabitRowView: View {
    let habit: Habit
    var showCheckbox: Bool = false
    var isDone: Bool = false
    var subtitleExtra: String? = nil
    var onToggle: (() -> Void)? = nil

    var body: some View {
        HStack(spacing: 12) {
            if showCheckbox {
                Button {
                    onToggle?()
                } label: {
                    Image(systemName: isDone ? "checkmark.circle.fill" : "circle")
                        .font(.title2)
                        .foregroundStyle(isDone ? HabitCatalog.color(from: habit.colorHex) : .secondary)
                }
                .buttonStyle(.plain)
            }

            ZStack {
                Circle()
                    .fill(HabitCatalog.color(from: habit.colorHex).opacity(0.2))
                    .frame(width: 36, height: 36)
                Image(systemName: habit.iconName)
                    .foregroundStyle(HabitCatalog.color(from: habit.colorHex))
            }

            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 6) {
                    Text(habit.title)
                        .font(.body.weight(.medium))
                        .strikethrough(isDone && showCheckbox)
                        .foregroundStyle(isDone && showCheckbox ? .secondary : .primary)
                    if habit.kind == .avoid {
                        Text("Avoid")
                            .font(.caption2)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.orange.opacity(0.15))
                            .clipShape(Capsule())
                    }
                }
                HStack(spacing: 6) {
                    if habit.status != .active {
                        Text(habit.status.title)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Text("Streak \(StreakCalculator.currentStreak(for: habit))")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    if let subtitleExtra, !subtitleExtra.isEmpty {
                        Text(subtitleExtra)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    ForEach(habit.tags.prefix(2), id: \.id) { tag in
                        Text(tag.name)
                            .font(.caption2)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(HabitCatalog.color(from: tag.colorHex).opacity(0.15))
                            .clipShape(Capsule())
                    }
                }
            }
            Spacer(minLength: 0)
        }
        .contentShape(Rectangle())
    }
}

struct HeatmapGrid: View {
    let cells: [(date: Date, state: Int)]
    let color: Color

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 3), count: 7)

    var body: some View {
        LazyVGrid(columns: columns, spacing: 3) {
            ForEach(Array(cells.enumerated()), id: \.offset) { _, cell in
                RoundedRectangle(cornerRadius: 3)
                    .fill(fill(for: cell.state))
                    .aspectRatio(1, contentMode: .fit)
            }
        }
    }

    private func fill(for state: Int) -> Color {
        switch state {
        case 1: return color.opacity(0.85)
        case 2: return Color.orange.opacity(0.5)
        case 3: return Color(.tertiarySystemFill)
        default: return Color(.quaternarySystemFill)
        }
    }
}
