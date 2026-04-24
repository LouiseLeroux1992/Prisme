import Foundation
import SwiftData

@Model
final class HabitEntry {
    var date: Date
    var isDone: Bool
    var habit: Habit?

    init(date: Date, isDone: Bool = false, habit: Habit? = nil) {
        self.date = date
        self.isDone = isDone
        self.habit = habit
    }
}
