import SwiftUI
import SwiftData

struct NoteDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let note: Note?
    @State private var createdNote: Note?

    @State private var title: String = ""
    @State private var blocks: [ContentBlock] = []
    @State private var showingDeleteConfirmation = false

    private let accentColor = Color(red: 0.9, green: 0.72, blue: 0.25)
    private let frLocale = Locale(identifier: "fr_FR")

    private var isNewNote: Bool { note == nil }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                TextField("Titre", text: $title)
                    .font(.largeTitle)
                    .fontWeight(.bold)

                if let note = note {
                    Text("Modifiée \(dateLabel(note.updatedAt))")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                BlockEditorView(blocks: $blocks)

                if !isNewNote {
                    Button(role: .destructive) {
                        showingDeleteConfirmation = true
                    } label: {
                        HStack {
                            Spacer()
                            Text("Supprimer la note")
                                .fontWeight(.medium)
                            Spacer()
                        }
                        .padding(.vertical, 12)
                        .background(Color(.systemGroupedBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 300)
        }
        .scrollDismissesKeyboard(.interactively)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            if let note = note {
                title = note.title
                blocks = note.blocks
            }
        }
        .onDisappear {
            save()
        }
        .alert("Supprimer cette note ?", isPresented: $showingDeleteConfirmation) {
            Button("Annuler", role: .cancel) {}
            Button("Supprimer", role: .destructive) {
                if let note = note {
                    modelContext.delete(note)
                }
                dismiss()
            }
        }
    }

    private func save() {
        let nonEmptyBlocks = blocks.filter { !$0.text.isEmpty }
        if title.isEmpty && nonEmptyBlocks.isEmpty {
            return
        }

        if let note = note {
            note.title = title
            note.blocks = blocks
            note.updatedAt = Date()
        } else if createdNote == nil {
            let newNote = Note(title: title)
            newNote.blocks = blocks
            modelContext.insert(newNote)
            createdNote = newNote
        } else if let created = createdNote {
            created.title = title
            created.blocks = blocks
            created.updatedAt = Date()
        }
    }

    private func dateLabel(_ date: Date) -> String {
        let calendar = Calendar.current
        if calendar.isDateInToday(date) {
            return "Aujourd'hui"
        }
        if calendar.isDateInYesterday(date) {
            return "Hier"
        }
        return date.formatted(.dateTime.day().month(.abbreviated).locale(frLocale))
    }
}
