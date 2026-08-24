import Foundation
import SwiftData

@Model
final class Tag {
    var id: UUID
    var name: String
    var colorHex: String
    var createdAt: Date

    @Relationship(deleteRule: .nullify)
    var habits: [Habit] = []

    init(name: String, colorHex: String = HabitCatalog.colors[0].hex) {
        self.id = UUID()
        self.name = name
        self.colorHex = colorHex
        self.createdAt = Date()
    }
}
