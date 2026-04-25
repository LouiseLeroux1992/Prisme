import SwiftUI
import SwiftData

struct ExerciceDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let exercise: Exercise?
    @State private var createdExercise: Exercise?

    @State private var title: String = ""
    @State private var notes: String = ""
    @State private var link: String = ""
    @State private var showingDeleteConfirmation = false
    @State private var showingLinkField = false

    private let accentColor = Color(red: 0.35, green: 0.7, blue: 0.45)
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

                TextEditor(text: $notes)
                    .font(.body)
                    .frame(minHeight: 150)
                    .scrollContentBackground(.hidden)
                    .padding(12)
                    .background(Color(.systemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                linkSection

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
            .padding(.bottom, 300)
        }
        .scrollDismissesKeyboard(.interactively)
        .background(Color(.systemGroupedBackground))
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            if let exercise = exercise {
                title = exercise.title
                notes = exercise.notes
                link = exercise.link
                showingLinkField = !exercise.link.isEmpty
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

    @ViewBuilder
    private var linkSection: some View {
        if showingLinkField || !link.isEmpty {
            HStack(spacing: 10) {
                Image(systemName: "link")
                    .foregroundStyle(accentColor)

                TextField("https://...", text: $link)
                    .keyboardType(.URL)
                    .autocapitalization(.none)
                    .textContentType(.URL)
            }
            .padding(12)
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        } else {
            Button {
                showingLinkField = true
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: "link")
                        .foregroundStyle(accentColor)
                    Text("Ajouter un lien")
                        .foregroundStyle(.secondary)
                }
                .padding(12)
                .background(Color(.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
    }

    private func save() {
        if title.isEmpty && notes.isEmpty && link.isEmpty {
            return
        }

        if let exercise = exercise {
            exercise.title = title
            exercise.notes = notes
            exercise.link = link
        } else if createdExercise == nil {
            let newExercise = Exercise(title: title, notes: notes, link: link)
            modelContext.insert(newExercise)
            createdExercise = newExercise
        } else if let created = createdExercise {
            created.title = title
            created.notes = notes
            created.link = link
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
