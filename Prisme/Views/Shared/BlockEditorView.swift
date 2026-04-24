import SwiftUI

struct BlockEditorView: View {
    @Binding var blocks: [ContentBlock]
    @FocusState private var focusedBlockId: UUID?
    @State private var checklistModeActive = false

    private let checkColor = Color(red: 0.95, green: 0.6, blue: 0.35)

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            contentArea
            editorToolbar
        }
    }

    // MARK: - Content Area

    private var contentArea: some View {
        VStack(alignment: .leading, spacing: 6) {
            if blocks.isEmpty {
                Button {
                    addTextBlock()
                } label: {
                    Text("Écrire ici...")
                        .foregroundStyle(.tertiary)
                        .font(.body)
                        .frame(maxWidth: .infinity, minHeight: 44, alignment: .leading)
                }
                .buttonStyle(.plain)
                .padding(12)
                .background(Color(.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }

            ForEach(Array(blocks.enumerated()), id: \.element.id) { index, block in
                if block.isTable {
                    TableBlockView(
                        tableData: tableBinding(index: index),
                        onDelete: { removeBlock(at: index) }
                    )
                } else if block.isLink {
                    linkRow(index: index, block: block)
                        .padding(12)
                        .background(Color(.systemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                } else if block.isChecklist {
                    checklistRow(index: index, block: block)
                        .padding(.horizontal, 12)
                        .background(Color(.systemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                } else {
                    textRow(index: index, block: block)
                        .padding(12)
                        .background(Color(.systemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
        }
    }

    // MARK: - Text Row

    private func textRow(index: Int, block: ContentBlock) -> some View {
        HStack {
            TextField("", text: blockTextBinding(index: index), axis: .vertical)
                .font(.body)
                .focused($focusedBlockId, equals: block.id)
                .onSubmit {
                    handleReturn(at: index)
                }

            if blocks.count > 1 && block.text.isEmpty {
                deleteBlockButton(index: index)
            }
        }
    }

    // MARK: - Checklist Row

    private func checklistRow(index: Int, block: ContentBlock) -> some View {
        HStack(alignment: .center, spacing: 10) {
            Button {
                blocks[index].isChecked.toggle()
            } label: {
                Image(systemName: block.isChecked ? "checkmark.circle.fill" : "circle")
                    .font(.body)
                    .foregroundStyle(block.isChecked ? checkColor : Color.gray.opacity(0.4))
            }
            .buttonStyle(.plain)

            TextField("", text: blockTextBinding(index: index))
                .font(.body)
                .strikethrough(block.isChecked)
                .foregroundStyle(block.isChecked ? .secondary : .primary)
                .focused($focusedBlockId, equals: block.id)
                .onSubmit {
                    handleReturn(at: index)
                }
                .padding(.vertical, 8)

            if block.text.isEmpty {
                deleteBlockButton(index: index)
                    .padding(.top, 8)
            }
        }
    }

    // MARK: - Link Row

    private func linkRow(index: Int, block: ContentBlock) -> some View {
        HStack(spacing: 10) {
            Image(systemName: "link")
                .font(.body)
                .foregroundStyle(checkColor)

            TextField("https://...", text: blockTextBinding(index: index))
                .font(.body)
                .keyboardType(.URL)
                .autocapitalization(.none)
                .textContentType(.URL)
                .focused($focusedBlockId, equals: block.id)

            if !block.text.isEmpty, let url = URL(string: block.text), url.scheme != nil {
                Button {
                    UIApplication.shared.open(url)
                } label: {
                    Image(systemName: "arrow.up.right.square")
                        .font(.body)
                        .foregroundStyle(checkColor)
                }
            }

            deleteBlockButton(index: index)
        }
    }

    // MARK: - Delete Button

    private func deleteBlockButton(index: Int) -> some View {
        Button {
            withAnimation {
                removeBlock(at: index)
            }
        } label: {
            Image(systemName: "xmark.circle.fill")
                .font(.caption)
                .foregroundStyle(Color(.systemGray3))
        }
        .buttonStyle(.plain)
    }

    // MARK: - Toolbar

    private var editorToolbar: some View {
        HStack(spacing: 20) {
            Button {
                toggleChecklistMode()
            } label: {
                Image(systemName: checklistModeActive ? "checklist.checked" : "checklist")
                    .font(.body)
                    .foregroundStyle(checklistModeActive ? checkColor : .secondary)
            }

            Button {
                insertTable()
            } label: {
                Image(systemName: "tablecells")
                    .font(.body)
                    .foregroundStyle(.secondary)
            }

            Button {
                insertLink()
            } label: {
                Image(systemName: "link")
                    .font(.body)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(.top, 4)
    }

    // MARK: - Actions

    private func toggleChecklistMode() {
        checklistModeActive.toggle()

        if let focusedId = focusedBlockId,
           let index = blocks.firstIndex(where: { $0.id == focusedId }),
           !blocks[index].isTable && !blocks[index].isLink {
            blocks[index].isChecklist = checklistModeActive
            if !checklistModeActive {
                blocks[index].isChecked = false
            }
        } else if checklistModeActive {
            let newBlock = ContentBlock(text: "", isChecklist: true)
            blocks.append(newBlock)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                focusedBlockId = newBlock.id
            }
        }
    }

    private func insertTable() {
        var block = ContentBlock()
        block.isTable = true
        block.tableData = TableData(columns: 2)
        blocks.append(block)
    }

    private func insertLink() {
        let block = ContentBlock(isLink: true)
        blocks.append(block)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            focusedBlockId = block.id
        }
    }

    private func handleReturn(at index: Int) {
        let currentBlock = blocks[index]

        if currentBlock.isChecklist && currentBlock.text.isEmpty {
            blocks[index].isChecklist = false
            checklistModeActive = false
            return
        }

        let newBlock = ContentBlock(
            text: "",
            isChecklist: currentBlock.isChecklist,
            isChecked: false
        )

        let insertIndex = index + 1
        if insertIndex <= blocks.count {
            blocks.insert(newBlock, at: insertIndex)
        } else {
            blocks.append(newBlock)
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            focusedBlockId = newBlock.id
        }
    }

    private func addTextBlock() {
        let newBlock = ContentBlock(text: "")
        blocks.append(newBlock)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            focusedBlockId = newBlock.id
        }
    }

    private func removeBlock(at index: Int) {
        blocks.remove(at: index)
        if blocks.isEmpty {
            return
        }
        let focusIndex = max(0, index - 1)
        if focusIndex < blocks.count && !blocks[focusIndex].isTable {
            focusedBlockId = blocks[focusIndex].id
        }
    }

    private func blockTextBinding(index: Int) -> Binding<String> {
        Binding(
            get: { blocks[index].text },
            set: { blocks[index].text = $0 }
        )
    }

    private func tableBinding(index: Int) -> Binding<TableData> {
        Binding(
            get: { blocks[index].tableData ?? TableData(columns: 2) },
            set: { blocks[index].tableData = $0 }
        )
    }
}

// MARK: - Table Block View

struct TableBlockView: View {
    @Binding var tableData: TableData
    let onDelete: () -> Void

    private let borderColor = Color(.systemGray4)
    private let headerBg = Color(.systemGray6)

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            tableContent
            tableActions
        }
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(borderColor, lineWidth: 0.5)
        )
    }

    private var tableContent: some View {
        VStack(spacing: 0) {
            headerRow
            ForEach(tableData.rows.indices, id: \.self) { rowIndex in
                Divider()
                dataRow(rowIndex: rowIndex)
            }
        }
    }

    private var headerRow: some View {
        HStack(spacing: 0) {
            ForEach(tableData.headers.indices, id: \.self) { colIndex in
                if colIndex > 0 {
                    Divider()
                        .frame(height: 40)
                }
                TextField("En-tête", text: headerBinding(colIndex))
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 8)
                    .frame(maxWidth: .infinity)
            }
        }
        .background(headerBg)
    }

    private func dataRow(rowIndex: Int) -> some View {
        HStack(spacing: 0) {
            ForEach(0..<tableData.columnCount, id: \.self) { colIndex in
                if colIndex > 0 {
                    Divider()
                        .frame(height: 40)
                }
                TextField("", text: cellBinding(row: rowIndex, col: colIndex))
                    .font(.body)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 8)
                    .frame(maxWidth: .infinity)
            }
        }
    }

    private var tableActions: some View {
        HStack(spacing: 16) {
            Button {
                tableData.addRow()
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: "plus")
                        .font(.caption)
                    Text("Ligne")
                        .font(.caption)
                }
                .foregroundStyle(.secondary)
            }

            Button {
                tableData.addColumn()
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: "plus")
                        .font(.caption)
                    Text("Colonne")
                        .font(.caption)
                }
                .foregroundStyle(.secondary)
            }

            Spacer()

            Button(role: .destructive) {
                onDelete()
            } label: {
                Image(systemName: "trash")
                    .font(.caption)
                    .foregroundStyle(.red.opacity(0.6))
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
    }

    private func headerBinding(_ colIndex: Int) -> Binding<String> {
        Binding(
            get: { tableData.headers[colIndex] },
            set: { tableData.headers[colIndex] = $0 }
        )
    }

    private func cellBinding(row: Int, col: Int) -> Binding<String> {
        Binding(
            get: { tableData.rows[row][col] },
            set: { tableData.rows[row][col] = $0 }
        )
    }
}
