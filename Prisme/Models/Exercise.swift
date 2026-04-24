import Foundation
import SwiftData

@Model
final class Exercise {
    var title: String
    var notes: String
    var notesBlocksData: Data?
    var link: String
    var createdAt: Date
    @Relationship(deleteRule: .cascade, inverse: \ChecklistItem.exercise)
    var checklistItems: [ChecklistItem] = []

    init(title: String = "", notes: String = "", link: String = "") {
        self.title = title
        self.notes = notes
        self.link = link
        self.createdAt = Date()
    }

    var notesBlocks: [ContentBlock] {
        get {
            guard let data = notesBlocksData else {
                if notes.isEmpty {
                    return []
                }
                return [ContentBlock(text: notes, isChecklist: false)]
            }
            return (try? JSONDecoder().decode([ContentBlock].self, from: data)) ?? []
        }
        set {
            notesBlocksData = try? JSONEncoder().encode(newValue)
            notes = newValue.map { $0.text }.joined(separator: "\n")
        }
    }
}
