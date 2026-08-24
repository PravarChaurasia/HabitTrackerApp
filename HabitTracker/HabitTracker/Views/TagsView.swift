import SwiftUI
import SwiftData

struct TagsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Tag.name) private var tags: [Tag]
    @State private var newName = ""
    @State private var newColor = HabitCatalog.colors[0].hex
    @State private var tagToDelete: Tag?

    var body: some View {
        NavigationStack {
            List {
                Section("Add tag") {
                    TextField("Name", text: $newName)
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(HabitCatalog.colors, id: \.hex) { item in
                                Circle()
                                    .fill(HabitCatalog.color(from: item.hex))
                                    .frame(width: 24, height: 24)
                                    .overlay {
                                        if newColor == item.hex {
                                            Image(systemName: "checkmark")
                                                .font(.caption2.bold())
                                                .foregroundStyle(.white)
                                        }
                                    }
                                    .onTapGesture { newColor = item.hex }
                            }
                        }
                    }
                    Button("Create Tag") {
                        createTag()
                    }
                    .disabled(newName.trimmingCharacters(in: .whitespaces).isEmpty)
                }

                Section("Tags") {
                    if tags.isEmpty {
                        Text("No tags yet")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(tags, id: \.id) { tag in
                            HStack {
                                Circle()
                                    .fill(HabitCatalog.color(from: tag.colorHex))
                                    .frame(width: 12, height: 12)
                                Text(tag.name)
                                Spacer()
                                Text("\(tag.habits.count)")
                                    .foregroundStyle(.secondary)
                                    .font(.caption)
                            }
                            .swipeActions {
                                Button("Delete", role: .destructive) {
                                    tagToDelete = tag
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Tags")
            .confirmationDialog(
                "Delete tag? Habits stay; the tag is only unassigned.",
                isPresented: Binding(
                    get: { tagToDelete != nil },
                    set: { if !$0 { tagToDelete = nil } }
                ),
                titleVisibility: .visible
            ) {
                Button("Delete", role: .destructive) {
                    if let tag = tagToDelete {
                        modelContext.delete(tag)
                        try? modelContext.save()
                    }
                    tagToDelete = nil
                }
                Button("Cancel", role: .cancel) { tagToDelete = nil }
            }
        }
    }

    private func createTag() {
        let name = newName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !name.isEmpty else { return }
        guard !tags.contains(where: { $0.name.localizedCaseInsensitiveCompare(name) == .orderedSame }) else {
            newName = ""
            return
        }
        modelContext.insert(Tag(name: name, colorHex: newColor))
        try? modelContext.save()
        newName = ""
    }
}
