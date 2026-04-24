import SwiftUI
import SwiftData

struct TrackerView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \HabitCategory.order) private var categories: [HabitCategory]
    @State private var showingNewHabit = false

    private let today = Date()
    private let accentColor = Color(red: 0.95, green: 0.6, blue: 0.35)
    private let frLocale = Locale(identifier: "fr_FR")

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    headerSection

                    ForEach(categories) { category in
                        categorySectionView(category)
                    }

                    weekSummarySection
                }
                .padding(.horizontal)
                .padding(.bottom, 80)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Tracker")
            .overlay(alignment: .bottomTrailing) {
                addButton
            }
            .sheet(isPresented: $showingNewHabit) {
                NewHabitView()
            }
            .onAppear {
                seedDefaultDataIfNeeded()
            }
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(today.formatted(.dateTime.weekday(.wide).locale(frLocale)).uppercased())
                .font(.caption)
                .fontWeight(.bold)
                .foregroundStyle(accentColor)

            Text("\(doneCountToday) / \(totalHabitsCount) habitudes aujourd'hui")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }

    // MARK: - Category Section

    private func categorySectionView(_ category: HabitCategory) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(category.name.uppercased())
                .font(.caption)
                .foregroundStyle(.secondary)
                .fontWeight(.semibold)
                .padding(.bottom, 8)

            VStack(spacing: 0) {
                let sortedHabits = category.habits.sorted { $0.createdAt < $1.createdAt }
                ForEach(Array(sortedHabits.enumerated()), id: \.element.id) { index, habit in
                    HabitRowView(habit: habit, accentColor: accentColor)

                    if index < sortedHabits.count - 1 {
                        Divider()
                            .padding(.leading, 52)
                    }
                }
            }
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }

    // MARK: - Week Summary

    private var weekSummarySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("7 DERNIERS JOURS")
                .font(.caption)
                .foregroundStyle(.secondary)
                .fontWeight(.semibold)

            HStack(spacing: 12) {
                ForEach(last7Days, id: \.self) { date in
                    let count = doneCount(for: date)
                    VStack(spacing: 6) {
                        Text(frenchWeekdayAbbrev(for: date))
                            .font(.caption2)
                            .foregroundStyle(.secondary)

                        ZStack {
                            Circle()
                                .fill(count > 0 ? accentColor.opacity(0.2 + Double(count) * 0.15) : Color(.systemGray5))
                                .frame(width: 36, height: 36)

                            if count > 0 {
                                Text("\(count)")
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .foregroundStyle(accentColor)
                            }
                        }

                        Text(date.formatted(.dateTime.day()))
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }

    // MARK: - Add Button

    private var addButton: some View {
        Button {
            showingNewHabit = true
        } label: {
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

    // MARK: - Helpers

    private var allHabits: [Habit] {
        categories.flatMap { $0.habits }
    }

    private var totalHabitsCount: Int {
        allHabits.count
    }

    private var doneCountToday: Int {
        allHabits.filter { $0.isDone(on: today) }.count
    }

    private func doneCount(for date: Date) -> Int {
        allHabits.filter { $0.isDone(on: date) }.count
    }

    private var last7Days: [Date] {
        let calendar = Calendar.current
        let todayStart = calendar.startOfDay(for: today)
        let weekday = calendar.component(.weekday, from: todayStart)
        let daysFromMonday = (weekday + 5) % 7
        let monday = calendar.date(byAdding: .day, value: -daysFromMonday, to: todayStart)!
        return (0..<7).map { offset in
            calendar.date(byAdding: .day, value: offset, to: monday)!
        }
    }

    private func frenchWeekdayAbbrev(for date: Date) -> String {
        let weekday = Calendar.current.component(.weekday, from: date)
        let abbrevs = ["D", "L", "M", "M", "J", "V", "S"]
        return abbrevs[weekday - 1]
    }

    // MARK: - Seed Data

    private func seedDefaultDataIfNeeded() {
        guard categories.isEmpty else { return }

        let bienEtre = HabitCategory(name: "Bien-être", icon: "🌿", order: 0)
        let maison = HabitCategory(name: "Maison", icon: "🏠", order: 1)

        modelContext.insert(bienEtre)
        modelContext.insert(maison)

        let habits: [(String, HabitCategory)] = [
            ("Lavage de cheveux", bienEtre),
            ("Masque de cheveux", bienEtre),
            ("Séance de sport", bienEtre),
            ("Arrosage des plantes", maison),
            ("Ménage salle de bain", maison),
        ]

        for (name, category) in habits {
            let habit = Habit(name: name, category: category)
            modelContext.insert(habit)
        }
    }
}

#Preview {
    TrackerView()
        .modelContainer(for: [HabitCategory.self, Habit.self, HabitEntry.self], inMemory: true)
}
