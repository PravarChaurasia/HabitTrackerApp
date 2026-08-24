import SwiftUI

struct HabitAppearance {
    let name: String
    let colorHex: String
    let systemImage: String
}

enum HabitCatalog {
    static let colors: [(name: String, hex: String)] = [
        ("Blue", "#4F9DDE"),
        ("Green", "#A3BE8C"),
        ("Coral", "#D08770"),
        ("Purple", "#B48EAD"),
        ("Teal", "#88C0D0"),
        ("Amber", "#EBCB8B"),
        ("Rose", "#BF616A"),
        ("Slate", "#7B88A1"),
    ]

    static let icons: [String] = [
        "drop.fill",
        "figure.walk",
        "book.fill",
        "brain.head.profile",
        "flame.fill",
        "heart.fill",
        "leaf.fill",
        "moon.fill",
        "fork.knife",
        "pencil",
        "checkmark.circle.fill",
        "star.fill",
    ]

    static func color(from hex: String) -> Color {
        var cleaned = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        if cleaned.hasPrefix("#") { cleaned.removeFirst() }
        guard cleaned.count == 6, let value = UInt64(cleaned, radix: 16) else {
            return .accentColor
        }
        let r = Double((value >> 16) & 0xFF) / 255
        let g = Double((value >> 8) & 0xFF) / 255
        let b = Double(value & 0xFF) / 255
        return Color(red: r, green: g, blue: b)
    }
}
