import SwiftUI
import SwiftData

struct TaskDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Bindable var task: PrismeTask

    @State private var blocks: [ContentBlock] = []
    @State private var showingDeleteConfirmation = false
    @State private var hasLoadedBlocks = false

    private let accentColor = Color(red: 0.2, green: 0.6, blue: 1.0)
    private let frLocale = Locale(identifier: "fr_FR")

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(task.title)
                    .font(.largeTitle)
                    .fontWeight(.bold)

                infoCard

                VStack(alignment: .leading, spacing: 8) {
                    Text("DESCRIPTION")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .fontWeight(.semibold)

                    BlockEditorView(blocks: $blocks)
                }

                toggleButton

                Button(role: .destructive) {
                    showingDeleteConfirmation = true
                } label: {
                    HStack {
                        Spacer()
                        Text("Supprimer la tâche")
                            .fontWeight(.medium)
                        Spacer()
                    }
                    .padding(.vertical, 12)
                    .background(Color(.systemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .padding(.top, 8)
            }
            .padding(.horizontal)
        }
        .background(Color(.systemGroupedBackground))
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            if !hasLoadedBlocks {
                blocks = task.descriptionBlocks
                hasLoadedBlocks = true
            }
        }
        .onDisappear {
            task.descriptionBlocks = blocks
        }
        .alert("Supprimer cette tâche ?", isPresented: $showingDeleteConfirmation) {
            Button("Annuler", role: .cancel) {}
            Button("Supprimer", role: .destructive) {
                modelContext.delete(task)
                dismiss()
            }
        }
    }

    private var infoCard: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Deadline")
                    .foregroundStyle(.primary)
                Spacer()
                Text(deadlineLabel(task.deadline))
                    .foregroundStyle(.primary)
                    .fontWeight(.medium)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)

            Divider()

            HStack {
                Text("Statut")
                    .foregroundStyle(.primary)
                Spacer()
                Text(task.isCompleted ? "Complétée" : "À faire")
                    .foregroundStyle(task.isCompleted ? accentColor : .primary)
                    .fontWeight(.medium)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var toggleButton: some View {
        Button {
            withAnimation {
                task.isCompleted.toggle()
            }
        } label: {
            HStack {
                Spacer()
                Text(task.isCompleted ? "Marquer comme à faire" : "Marquer comme complétée")
                    .fontWeight(.semibold)
                Spacer()
            }
            .padding(.vertical, 14)
            .background(task.isCompleted ? Color(.systemBackground) : accentColor)
            .foregroundStyle(task.isCompleted ? Color.primary : Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(task.isCompleted ? Color(.systemGray4) : Color.clear, lineWidth: 1)
            )
        }
    }

    private func deadlineLabel(_ date: Date) -> String {
        let calendar = Calendar.current
        if calendar.isDateInToday(date) {
            return "Aujourd'hui"
        }
        if calendar.isDateInYesterday(date) {
            return "Hier"
        }
        if calendar.isDateInTomorrow(date) {
            return "Demain"
        }
        return date.formatted(.dateTime.day().month(.abbreviated).locale(frLocale))
    }
}
