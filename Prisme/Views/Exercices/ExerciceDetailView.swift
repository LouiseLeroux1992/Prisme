import SwiftUI
import SwiftData

struct ExerciceDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let exercise: Exercise?
    @State private var createdExercise: Exercise?

    @State private var title: String = ""
    @State private var blocks: [ContentBlock] = []
    @State private var showingDeleteConfirmation = false

    private let frLocale = Locale(identifier: "fr_FR")

    private var isNewExercise: Bool { exercise == nil }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                TextField("Titre de l'exercice", text: $title)
                    .font(.largeTitle)
                    .fontWeight(.bold)

                if let exercise = exercise {
                    Text("Ajouté \(dateLabel(exercise.createdAt))")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                BlockEditorView(blocks: $blocks)

                if !isNewExercise {
                    Button(role: .destructive) {
                        showingDeleteConfirmation = true
                    } label: {
                        HStack {
                            Spacer()
                            Text("Supprimer l'exercice")
                                .fontWeight(.medium)
                            Spacer()
                        }
                        .padding(.vertical, 12)
                        .background(Color(.systemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
            }
            .padding(.horizontal)
        }
        .background(Color(.systemGroupedBackground))
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            if let exercise = exercise {
                title = exercise.title
                blocks = exercise.notesBlocks
            }
        }
        .onDisappear {
            save()
        }
        .alert("Supprimer cet exercice ?", isPresented: $showingDeleteConfirmation) {
            Button("Annuler", role: .cancel) {}
            Button("Supprimer", role: .destructive) {
                if let exercise = exercise {
                    modelContext.delete(exercise)
                }
                dismiss()
            }
        }
    }

    private func save() {
        let nonEmptyBlocks = blocks.filter { !$0.text.isEmpty || $0.isTable }
        if title.isEmpty && nonEmptyBlocks.isEmpty {
            return
        }

        if let exercise = exercise {
            exercise.title = title
            exercise.notesBlocks = blocks
        } else if createdExercise == nil {
            let newExercise = Exercise(title: title)
            newExercise.notesBlocks = blocks
            modelContext.insert(newExercise)
            createdExercise = newExercise
        } else if let created = createdExercise {
            created.title = title
            created.notesBlocks = blocks
        }
    }

    private func dateLabel(_ date: Date) -> String {
        let calendar = Calendar.current
        if calendar.isDateInToday(date) {
            return "aujourd'hui"
        }
        if calendar.isDateInYesterday(date) {
            return "hier"
        }
        return date.formatted(.dateTime.day().month(.abbreviated).locale(frLocale))
    }
}
