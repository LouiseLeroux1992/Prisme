import SwiftUI
import SwiftData

struct NewTaskView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var title = ""
    @State private var taskDescription = ""
    @State private var deadline = Date()

    private let accentColor = Color(red: 0.2, green: 0.6, blue: 1.0)

    var body: some View {
        NavigationStack {
            Form {
                Section("Titre") {
                    TextField("Nom de la tâche", text: $title)
                }

                Section("Deadline") {
                    DatePicker("Date", selection: $deadline, displayedComponents: .date)
                        .environment(\.locale, Locale(identifier: "fr_FR"))
                }

                Section("Description (optionnelle)") {
                    TextEditor(text: $taskDescription)
                        .frame(minHeight: 80)
                }
            }
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
        let task = PrismeTask(title: title, taskDescription: taskDescription, deadline: deadline)
        modelContext.insert(task)
        dismiss()
    }
}
