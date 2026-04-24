import Foundation
import SwiftData

@Model
final class Note {
    var title: String
    var content: String
    var blocksData: Data?
    var createdAt: Date
    var updatedAt: Date
    @Relationship(deleteRule: .cascade, inverse: \ChecklistItem.note)
    var checklistItems: [ChecklistItem] = []

    init(title: String = "", content: String = "") {
        self.title = title
        self.content = content
        self.createdAt = Date()
        self.updatedAt = Date()
    }

    var blocks: [ContentBlock] {
        get {
            guard let data = blocksData else {
                if content.isEmpty {
                    return []
                }
                return [ContentBlock(text: content, isChecklist: false)]
            }
            return (try? JSONDecoder().decode([ContentBlock].self, from: data)) ?? []
        }
        set {
            blocksData = try? JSONEncoder().encode(newValue)
            content = newValue.map { $0.text }.joined(separator: "\n")
        }
    }
}
