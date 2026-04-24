import SwiftUI
import SwiftData

struct ExercicesListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Exercise.createdAt, order: .reverse) private var exercises: [Exercise]

    private let accentColor = Color(red: 0.35, green: 0.7, blue: 0.45)
    private let frLocale = Locale(identifier: "fr_FR")

    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()

                if exercises.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "brain.head.profile")
                            .font(.largeTitle)
                            .foregroundStyle(accentColor.opacity(0.5))
                        Text("Aucun exercice")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                } else {
                    ScrollView {
                        VStack(spacing: 0) {
                            ForEach(Array(exercises.enumerated()), id: \.element.id) { index, exercise in
                                NavigationLink(destination: ExerciceDetailView(exercise: exercise)) {
                                    exerciseRow(exercise)
                                }
                                .buttonStyle(.plain)

                                if index < exercises.count - 1 {
                                    Divider()
                                        .padding(.leading, 52)
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
            .navigationTitle("Exercices")
            .overlay(alignment: .bottomTrailing) {
                addButton
            }
        }
    }

    private func exerciseRow(_ exercise: Exercise) -> some View {
        HStack(spacing: 12) {
            Image(systemName: "leaf.fill")
                .font(.body)
                .foregroundStyle(accentColor)
                .frame(width: 28)

            VStack(alignment: .leading, spacing: 4) {
                Text(exercise.title.isEmpty ? "Sans titre" : exercise.title)
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundStyle(.primary)
                    .lineLimit(1)

                Text("Ajouté \(dateLabel(exercise.createdAt))")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(Color(.systemGray3))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }

    private var addButton: some View {
        NavigationLink(destination: ExerciceDetailView(exercise: nil)) {
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
            return "aujourd'hui"
        }
        if calendar.isDateInYesterday(date) {
            return "hier"
        }
        return date.formatted(.dateTime.day().month(.abbreviated).locale(frLocale))
    }
}
