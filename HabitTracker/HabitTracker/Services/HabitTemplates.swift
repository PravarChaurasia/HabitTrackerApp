import Foundation

struct HabitTemplate: Identifiable, Hashable {
    let id: String
    let title: String
    let iconName: String
    let colorHex: String
    let notes: String
    let tagName: String?
}

enum HabitTemplates {
    static let all: [HabitTemplate] = [
        HabitTemplate(
            id: "water",
            title: "Drink water",
            iconName: "drop.fill",
            colorHex: "#4F9DDE",
            notes: "Stay hydrated",
            tagName: "Health"
        ),
        HabitTemplate(
            id: "walk",
            title: "Morning walk",
            iconName: "figure.walk",
            colorHex: "#A3BE8C",
            notes: "Get moving",
            tagName: "Health"
        ),
        HabitTemplate(
            id: "read",
            title: "Read 20 min",
            iconName: "book.fill",
            colorHex: "#B48EAD",
            notes: "Daily reading",
            tagName: "Personal"
        ),
        HabitTemplate(
            id: "meditate",
            title: "Meditate",
            iconName: "brain.head.profile",
            colorHex: "#88C0D0",
            notes: "Calm focus",
            tagName: "Health"
        ),
        HabitTemplate(
            id: "stretch",
            title: "Stretch",
            iconName: "leaf.fill",
            colorHex: "#EBCB8B",
            notes: "Mobility",
            tagName: "Health"
        ),
        HabitTemplate(
            id: "journal",
            title: "Journal",
            iconName: "pencil",
            colorHex: "#D08770",
            notes: "Write a few lines",
            tagName: "Personal"
        ),
    ]
}
