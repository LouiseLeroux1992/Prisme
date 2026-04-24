import SwiftUI
import SwiftData

struct ChecklistSectionView: View {
    @Environment(\.modelContext) private var modelContext
    let items: [ChecklistItem]
    let addItem: (ChecklistItem) -> Void

    @State private var newItemText = ""
    @FocusState private var isNewItemFocused: Bool

    private let checkColor = Color(red: 0.95, green: 0.6, blue: 0.35)

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            let sorted = items.sorted { $0.order < $1.order }

            ForEach(sorted) { item in
                checklistRow(item)

                if item.id != sorted.last?.id {
                    Divider()
                        .padding(.leading, 44)
                }
            }

            newItemRow
        }
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private func checklistRow(_ item: ChecklistItem) -> some View {
        HStack(spacing: 10) {
            Button {
                withAnimation {
                    item.isChecked.toggle()
                }
            } label: {
                Image(systemName: item.isChecked ? "checkmark.square.fill" : "square")
                    .font(.title3)
                    .foregroundStyle(item.isChecked ? checkColor : Color.gray.opacity(0.4))
            }
            .buttonStyle(.plain)

            Text(item.text)
                .font(.body)
                .strikethrough(item.isChecked)
                .foregroundStyle(item.isChecked ? .secondary : .primary)

            Spacer()

            Button(role: .destructive) {
                withAnimation {
                    modelContext.delete(item)
                }
            } label: {
                Image(systemName: "xmark")
                    .font(.caption)
                    .foregroundStyle(Color(.systemGray3))
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
    }

    private var newItemRow: some View {
        HStack(spacing: 10) {
            Image(systemName: "square")
                .font(.title3)
                .foregroundStyle(Color.gray.opacity(0.2))

            TextField("Ajouter un élément", text: $newItemText)
                .font(.body)
                .focused($isNewItemFocused)
                .onSubmit {
                    addNewItem()
                }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
    }

    private func addNewItem() {
        guard !newItemText.isEmpty else { return }
        let item = ChecklistItem(text: newItemText, order: items.count)
        addItem(item)
        newItemText = ""
        isNewItemFocused = true
    }
}
