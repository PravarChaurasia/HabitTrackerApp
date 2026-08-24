import SwiftUI
import SwiftData

struct OnboardingView: View {
    @Environment(\.modelContext) private var modelContext
    var isEmbedded: Bool = false
    var onFinish: () -> Void

    @State private var selected: Set<String> = []
    @Query(sort: \Tag.name) private var existingTags: [Tag]

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Text("Pick a few starters. Everything stays on this device — no account, no internet.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .listRowBackground(Color.clear)
                }

                Section("Templates") {
                    ForEach(HabitTemplates.all) { template in
                        Button {
                            toggle(template.id)
                        } label: {
                            HStack(spacing: 12) {
                                Image(systemName: selected.contains(template.id) ? "checkmark.circle.fill" : "circle")
                                    .foregroundStyle(selected.contains(template.id) ? HabitCatalog.color(from: template.colorHex) : .secondary)
                                ZStack {
                                    Circle()
                                        .fill(HabitCatalog.color(from: template.colorHex).opacity(0.2))
                                        .frame(width: 32, height: 32)
                                    Image(systemName: template.iconName)
                                        .foregroundStyle(HabitCatalog.color(from: template.colorHex))
                                }
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(template.title).foregroundStyle(.primary)
                                    if let tag = template.tagName {
                                        Text(tag).font(.caption).foregroundStyle(.secondary)
                                    }
                                }
                                Spacer()
                            }
                        }
                    }
                }
            }
            .navigationTitle(isEmbedded ? "Templates" : "Welcome")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(isEmbedded ? "Close" : "Skip") {
                        onFinish()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(isEmbedded ? "Add" : "Continue") {
                        applyTemplates()
                        onFinish()
                    }
                    .disabled(selected.isEmpty && !isEmbedded)
                }
            }
        }
    }

    private func toggle(_ id: String) {
        if selected.contains(id) {
            selected.remove(id)
        } else {
            selected.insert(id)
        }
    }

    private func applyTemplates() {
        let chosen = HabitTemplates.all.filter { selected.contains($0.id) }
        for (index, template) in chosen.enumerated() {
            let habit = Habit(
                title: template.title,
                notes: template.notes,
                colorHex: template.colorHex,
                iconName: template.iconName,
                sortOrder: index
            )
            if let tagName = template.tagName {
                let tag = findOrCreateTag(named: tagName, colorHex: template.colorHex)
                habit.tags = [tag]
            }
            modelContext.insert(habit)
        }
        try? modelContext.save()
    }

    private func findOrCreateTag(named name: String, colorHex: String) -> Tag {
        if let existing = existingTags.first(where: { $0.name.localizedCaseInsensitiveCompare(name) == .orderedSame }) {
            return existing
        }
        let tag = Tag(name: name, colorHex: colorHex)
        modelContext.insert(tag)
        return tag
    }
}
