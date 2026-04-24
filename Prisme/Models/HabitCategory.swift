import Foundation
import SwiftData

@Model
final class HabitCategory {
    var name: String
    var icon: String
    var order: Int
    @Relationship(deleteRule: .cascade, inverse: \Habit.category)
    var habits: [Habit] = []

    init(name: String, icon: String, order: Int = 0) {
        self.name = name
        self.icon = icon
        self.order = order
    }
}
