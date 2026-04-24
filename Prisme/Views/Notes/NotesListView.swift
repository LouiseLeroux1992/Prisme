import SwiftUI
import SwiftData

struct NotesListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Note.updatedAt, order: .reverse) private var notes: [Note]

    private let accentColor = Color(red: 0.9, green: 0.72, blue: 0.25)
    private let frLocale = Locale(identifier: "fr_FR")

    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()

                if notes.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "note.text")
                            .font(.largeTitle)
                            .foregroundStyle(accentColor.opacity(0.5))
                        Text("Aucune note")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                } else {
                    ScrollView {
                        VStack(spacing: 0) {
                            ForEach(Array(notes.enumerated()), id: \.element.id) { index, note in
                                NavigationLink(destination: NoteDetailView(note: note)) {
                                    noteRow(note)
                                }
                                .buttonStyle(.plain)

                                if index < notes.count - 1 {
                                    Divider()
                                        .padding(.leading, 16)
                                }
                            }
                        }
                        .background(Color(.systemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .padding(.horizontal)
                        .padding(.bottom, 80)
                    }
                }
            }
            .navigationTitle("Notes")
            .overlay(alignment: .bottomTrailing) {
                addButton
            }
        }
    }

    private func noteRow(_ note: Note) -> some View {
        HStack(spacing: 0) {
            Rectangle()
                .fill(accentColor)
                .frame(width: 4)

            VStack(alignment: .leading, spacing: 4) {
                Text(note.title.isEmpty ? "Sans titre" : note.title)
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundStyle(.primary)
                    .lineLimit(1)

                HStack(spacing: 6) {
                    Text(dateLabel(note.updatedAt))
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    if !note.content.isEmpty {
                        Text("·")
                            .foregroundStyle(.secondary)
                        Text(note.content)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 12)

            Spacer()
        }
    }

    private var addButton: some View {
        NavigationLink(destination: NoteDetailView(note: nil)) {
            Image(systemName: "plus")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundStyle(.white)
                .frame(width: 56, height: 56)
                .background(accentColor)
                .clipShape(Circle())
                .shadow(color: accentColor.opacity(0.3), radius: 8, y: 4)
        }
        .padding(.trailing, 20)
        .padding(.bottom, 20)
    }

    private func dateLabel(_ date: Date) -> String {
        let calendar = Calendar.current
        if calendar.isDateInToday(date) {
            return "Aujourd'hui"
        }
        if calendar.isDateInYesterday(date) {
            return "Hier"
        }
        return date.formatted(.dateTime.weekday(.abbreviated).locale(frLocale))
    }
}
