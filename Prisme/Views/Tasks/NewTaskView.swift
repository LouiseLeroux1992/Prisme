import SwiftUI
import SwiftData

struct NewTaskView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var title = ""
    @State private var blocks: [ContentBlock] = []
    @State private var deadline = Date()

    private let accentColor = Color(red: 0.2, green: 0.6, blue: 1.0)

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("TITRE")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .fontWeight(.semibold)

                        TextField("Nom de la tâche", text: $title)
                            .font(.body)
                            .padding(12)
                            .background(Color(.systemBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("DEADLINE")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .fontWeight(.semibold)

                        DatePicker("Date", selection: $deadline, displayedComponents: .date)
                            .environment(\.locale, Locale(identifier: "fr_FR"))
                            .padding(12)
                            .background(Color(.systemBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("DESCRIPTION (OPTIONNELLE)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .fontWeight(.semibold)

                        BlockEditorView(blocks: $blocks)
                    }
                }
                .padding(.horizontal)
                .padding(.top, 16)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Nouvelle tâche")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annuler") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("OK") {
                        save()
                    }
                    .fontWeight(.bold)
                    .disabled(title.isEmpty)
                }
            }
        }
    }

    private func save() {
        let task = PrismeTask(title: title, deadline: deadline)
        task.descriptionBlocks = blocks
        modelContext.insert(task)
        dismiss()
    }
}
