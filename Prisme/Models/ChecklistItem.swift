import Foundation
import SwiftData

@Model
final class ChecklistItem {
    var text: String
    var isChecked: Bool
    var order: Int
    var note: Note?
    var task: PrismeTask?
    var exercise: Exercise?

    init(text: String = "", isChecked: Bool = false, order: Int = 0) {
        self.text = text
        self.isChecked = isChecked
        self.order = order
    }
}
