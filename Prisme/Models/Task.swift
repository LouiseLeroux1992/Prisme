import Foundation
import SwiftData

@Model
final class PrismeTask {
    var title: String
    var taskDescription: String
    var descriptionBlocksData: Data?
    var deadline: Date
    var isCompleted: Bool
    var createdAt: Date
    @Relationship(deleteRule: .cascade, inverse: \ChecklistItem.task)
    var checklistItems: [ChecklistItem] = []

    init(title: String = "", taskDescription: String = "", deadline: Date = Date(), isCompleted: Bool = false) {
        self.title = title
        self.taskDescription = taskDescription
        self.deadline = deadline
        self.isCompleted = isCompleted
        self.createdAt = Date()
    }

    var descriptionBlocks: [ContentBlock] {
        get {
            guard let data = descriptionBlocksData else {
                if taskDescription.isEmpty {
                    return []
                }
                return [ContentBlock(text: taskDescription, isChecklist: false)]
            }
            return (try? JSONDecoder().decode([ContentBlock].self, from: data)) ?? []
        }
        set {
            descriptionBlocksData = try? JSONEncoder().encode(newValue)
            taskDescription = newValue.map { $0.text }.joined(separator: "\n")
        }
    }
}
