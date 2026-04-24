import SwiftUI
import SwiftData

struct HabitRowView: View {
    @Environment(\.modelContext) private var modelContext
    let habit: Habit
    let accentColor: Color

    var body: some View {
        HStack(spacing: 12) {
            Button {
                toggleToday()
            } label: {
                Image(systemName: habit.isDone(on: Date()) ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundStyle(habit.isDone(on: Date()) ? accentColor : Color.gray.opacity(0.3))
            }
            .buttonStyle(.plain)

            Text(habit.name)
                .font(.body)
                .foregroundStyle(.primary)

            Spacer()

            miniWeekBars

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(Color(.systemGray3))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }

    // MARK: - Mini Week Bars

    private var miniWeekBars: some View {
        HStack(spacing: 3) {
            ForEach(last7Days, id: \.self) { date in
                RoundedRectangle(cornerRadius: 2)
                    .fill(habit.isDone(on: date) ? accentColor : accentColor.opacity(0.15))
                    .frame(width: 4, height: 16)
            }
        }
    }

    private var last7Days: [Date] {
        let calendar = Calendar.current
        return (0..<7).reversed().map { offset in
            calendar.date(byAdding: .day, value: -offset, to: calendar.startOfDay(for: Date()))!
        }
    }

    // MARK: - Toggle

    private func toggleToday() {
        let today = Date()
        if let entry = habit.entry(for: today) {
            entry.isDone.toggle()
        } else {
            let entry = HabitEntry(date: today, isDone: true, habit: habit)
            modelContext.insert(entry)
        }
    }
}
