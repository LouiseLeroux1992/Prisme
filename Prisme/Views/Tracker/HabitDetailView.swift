import SwiftUI
import SwiftData

struct HabitDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    let habit: Habit

    @State private var showingDeleteConfirmation = false
    @State private var showingRename = false
    @State private var editedName = ""
    @State private var showingChangeCategory = false
    @Query(sort: \HabitCategory.order) private var categories: [HabitCategory]

    private let accentColor = Color(red: 0.95, green: 0.6, blue: 0.35)
    private let frLocale = Locale(identifier: "fr_FR")

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                if let category = habit.category {
                    Text(category.name.uppercased())
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundStyle(accentColor)
                }

                heatmapSection
                journalSection
            }
            .padding(.horizontal)
            .padding(.bottom, 40)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle(habit.name)
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button {
                        editedName = habit.name
                        showingRename = true
                    } label: {
                        Label("Renommer", systemImage: "pencil")
                    }
                    Button {
                        showingChangeCategory = true
                    } label: {
                        Label("Changer de catégorie", systemImage: "folder")
                    }
                    Button(role: .destructive) {
                        showingDeleteConfirmation = true
                    } label: {
                        Label("Supprimer", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .alert("Supprimer cette habitude ?", isPresented: $showingDeleteConfirmation) {
            Button("Annuler", role: .cancel) {}
            Button("Supprimer", role: .destructive) {
                modelContext.delete(habit)
                dismiss()
            }
        } message: {
            Text("L'habitude et tout son historique seront supprimés.")
        }
        .alert("Renommer", isPresented: $showingRename) {
            TextField("Nom", text: $editedName)
            Button("Annuler", role: .cancel) {}
            Button("OK") {
                habit.name = editedName
            }
        }
        .sheet(isPresented: $showingChangeCategory) {
            NavigationStack {
                List(categories) { category in
                    Button {
                        habit.category = category
                        showingChangeCategory = false
                    } label: {
                        HStack {
                            Text(category.icon)
                            Text(category.name)
                                .foregroundStyle(.primary)
                            Spacer()
                            if habit.category?.id == category.id {
                                Image(systemName: "checkmark")
                                    .foregroundStyle(accentColor)
                            }
                        }
                    }
                }
                .navigationTitle("Catégorie")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Fermer") {
                            showingChangeCategory = false
                        }
                    }
                }
            }
            .presentationDetents([.medium])
        }
    }

    // MARK: - Heatmap

    private var heatmapSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("4 derniers mois")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                Spacer()
                Text("\(totalDoneCount) fois au total")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            GeometryReader { geometry in
                let grid = heatmapGrid
                let labelWidth: CGFloat = 16
                let spacing: CGFloat = 3
                let weekCount = max(grid.count, 1)
                let availableWidth = geometry.size.width - labelWidth - spacing
                let cellSize = max((availableWidth - CGFloat(weekCount - 1) * spacing) / CGFloat(weekCount), 4)

                let dayLabels = ["L", "M", "M", "J", "V", "S", "D"]
                VStack(alignment: .leading, spacing: spacing) {
                    ForEach(0..<7, id: \.self) { rowIndex in
                        HStack(spacing: spacing) {
                            Text(dayLabels[rowIndex])
                                .font(.system(size: 9))
                                .foregroundStyle(.secondary)
                                .frame(width: labelWidth, alignment: .trailing)

                            ForEach(0..<grid.count, id: \.self) { weekIndex in
                                if rowIndex < grid[weekIndex].count {
                                    let date = grid[weekIndex][rowIndex]
                                    RoundedRectangle(cornerRadius: 2)
                                        .fill(habit.isDone(on: date) ? accentColor : Color(.systemGray5))
                                        .frame(width: cellSize, height: cellSize)
                                } else {
                                    RoundedRectangle(cornerRadius: 2)
                                        .fill(Color.clear)
                                        .frame(width: cellSize, height: cellSize)
                                }
                            }
                        }
                    }
                }
            }
            .frame(height: 120)
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Journal

    private var journalSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("JOURNAL")
                .font(.caption)
                .foregroundStyle(.secondary)
                .fontWeight(.semibold)

            VStack(spacing: 0) {
                ForEach(Array(last30Days.enumerated()), id: \.element) { index, date in
                    HStack {
                        Button {
                            toggleDate(date)
                        } label: {
                            Image(systemName: habit.isDone(on: date) ? "checkmark.circle.fill" : "circle")
                                .font(.title3)
                                .foregroundStyle(habit.isDone(on: date) ? accentColor : Color.gray.opacity(0.3))
                        }
                        .buttonStyle(.plain)

                        Text(journalLabel(for: date))
                            .font(.body)

                        Spacer()

                        if habit.isDone(on: date) {
                            Text("Fait")
                                .font(.subheadline)
                                .foregroundStyle(accentColor)
                        } else {
                            Text("—")
                                .foregroundStyle(Color(.systemGray4))
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)

                    if index < last30Days.count - 1 {
                        Divider()
                            .padding(.leading, 52)
                    }
                }
            }
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }


    // MARK: - Helpers

    private var totalDoneCount: Int {
        habit.entries.filter { $0.isDone }.count
    }

    private var heatmapGrid: [[Date]] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        guard let startDate = calendar.date(byAdding: .month, value: -4, to: today) else {
            return []
        }

        let mondayStart = previousMonday(from: startDate, calendar: calendar)

        var weeks: [[Date]] = []
        var currentDate = mondayStart

        while currentDate <= today {
            var week: [Date] = []
            for _ in 0..<7 {
                week.append(currentDate)
                currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
            }
            weeks.append(week)
        }

        return weeks
    }

    private func previousMonday(from date: Date, calendar: Calendar) -> Date {
        let weekday = calendar.component(.weekday, from: date)
        let daysToSubtract = (weekday + 5) % 7
        return calendar.date(byAdding: .day, value: -daysToSubtract, to: date)!
    }

    private var last30Days: [Date] {
        let calendar = Calendar.current
        return (0..<30).map { offset in
            calendar.date(byAdding: .day, value: -offset, to: calendar.startOfDay(for: Date()))!
        }
    }

    private func journalLabel(for date: Date) -> String {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        if calendar.isDate(date, inSameDayAs: today) {
            return "Aujourd'hui"
        }

        if let yesterday = calendar.date(byAdding: .day, value: -1, to: today),
           calendar.isDate(date, inSameDayAs: yesterday) {
            return "Hier"
        }

        return date.formatted(.dateTime.weekday(.abbreviated).day().month(.abbreviated).locale(frLocale))
    }

    private func toggleDate(_ date: Date) {
        if let entry = habit.entry(for: date) {
            entry.isDone.toggle()
        } else {
            let entry = HabitEntry(date: date, isDone: true, habit: habit)
            modelContext.insert(entry)
        }
    }
}
