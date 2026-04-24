import Foundation
import SwiftData

@Model
final class Mantra {
    var text: String
    var order: Int

    init(text: String, order: Int) {
        self.text = text
        self.order = order
    }
}
