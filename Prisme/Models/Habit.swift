import Foundation
import SwiftData

@Model
final class Habit {
    var name: String
    var category: HabitCategory?
    var createdAt: Date
    @Relationship(deleteRule: .cascade, inverse: \HabitEntry.habit)
    var entries: [HabitEntry] = []

    init(name: String, category: HabitCategory? = nil) {
        self.name = name
        self.category = category
        self.createdAt = Date()
    }

    func entry(for date: Date) -> HabitEntry? {
        let calendar = Calendar.current
        return entries.first { calendar.isDate($0.date, inSameDayAs: date) }
    }

    func isDone(on date: Date) -> Bool {
        return entry(for: date)?.isDone ?? false
    }
}
