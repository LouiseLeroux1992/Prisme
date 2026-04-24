import Foundation

struct TableData: Codable, Hashable {
    var headers: [String]
    var rows: [[String]]

    init(columns: Int = 2) {
        self.headers = Array(repeating: "", count: columns)
        self.rows = [Array(repeating: "", count: columns)]
    }

    var columnCount: Int { headers.count }

    mutating func addRow() {
        rows.append(Array(repeating: "", count: columnCount))
    }

    mutating func removeRow(at index: Int) {
        guard rows.count > 1 else { return }
        rows.remove(at: index)
    }

    mutating func addColumn() {
        headers.append("")
        for i in rows.indices {
            rows[i].append("")
        }
    }

    mutating func removeColumn(at index: Int) {
        guard columnCount > 2 else { return }
        headers.remove(at: index)
        for i in rows.indices {
            rows[i].remove(at: index)
        }
    }
}

struct ContentBlock: Codable, Identifiable, Hashable {
    var id: UUID = UUID()
    var text: String = ""
    var isChecklist: Bool = false
    var isChecked: Bool = false
    var isTable: Bool = false
    var isLink: Bool = false
    var tableData: TableData?

    init(id: UUID = UUID(), text: String = "", isChecklist: Bool = false, isChecked: Bool = false, isTable: Bool = false, isLink: Bool = false, tableData: TableData? = nil) {
        self.id = id
        self.text = text
        self.isChecklist = isChecklist
        self.isChecked = isChecked
        self.isTable = isTable
        self.isLink = isLink
        self.tableData = tableData
    }
}
