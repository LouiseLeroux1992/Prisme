import SwiftUI
import SwiftData

enum TaskFilter: String, CaseIterable {
    case today = "Aujourd'hui"
    case upcoming = "Bientôt"
    case all = "Toutes"
    case done = "Complétées"
}

struct TasksView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \PrismeTask.deadline) private var tasks: [PrismeTask]
    @State private var selectedFilter: TaskFilter = .today
    @State private var showingNewTask = false

    private let accentColor = Color(red: 0.2, green: 0.6, blue: 1.0)
    private let frLocale = Locale(identifier: "fr_FR")

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                filterPicker

                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        switch selectedFilter {
                        case .today:
                            todayView
                        case .upcoming:
                            upcomingView
                        case .all:
                            allView
                        case .done:
                            doneView
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                    .padding(.bottom, 80)
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Tâches")
            .overlay(alignment: .bottomTrailing) {
                addButton
            }
            .sheet(isPresented: $showingNewTask) {
                NewTaskView()
            }
        }
    }

    // MARK: - Filter Picker

    private var filterPicker: some View {
        Picker("Filtre", selection: $selectedFilter) {
            ForEach(TaskFilter.allCases, id: \.self) { filter in
                Text(filter.rawValue).tag(filter)
            }
        }
        .pickerStyle(.segmented)
        .padding(.horizontal)
        .padding(.vertical, 8)
    }

    // MARK: - Today View

    private var todayView: some View {
        VStack(alignment: .leading, spacing: 16) {
            let todayTodo = tasksForToday.filter { !$0.isCompleted }
            let todayDone = tasksForToday.filter { $0.isCompleted }
            let overdue = overdueTasks

            if todayTodo.isEmpty && todayDone.isEmpty && overdue.isEmpty {
                emptyState("Rien pour aujourd'hui")
            }

            if !todayTodo.isEmpty || !todayDone.isEmpty {
                taskCountLabel("\(todayTodo.count) à faire · \(todayDone.count) fait")
                taskListCard(todayTodo + todayDone)
            }

            if !overdue.isEmpty {
                sectionHeader("EN RETARD · \(overdue.count)", color: .red)
                taskListCard(overdue)
            }
        }
    }

    // MARK: - Upcoming View

    private var upcomingView: some View {
        VStack(alignment: .leading, spacing: 16) {
            let upcoming = upcomingTasks

            if upcoming.isEmpty {
                emptyState("Rien de prévu")
            } else {
                taskListCard(upcoming)
            }
        }
    }

    // MARK: - All View

    private var allView: some View {
        VStack(alignment: .leading, spacing: 16) {
            let overdue = overdueTasks
            let todayItems = tasksForToday.filter { !$0.isCompleted }
            let upcoming = upcomingTasks
            let later = laterTasks

            if tasks.filter({ !$0.isCompleted }).isEmpty {
                emptyState("Aucune tâche en cours")
            }

            if !overdue.isEmpty {
                sectionHeader("EN RETARD · \(overdue.count)", color: .red)
                taskListCard(overdue)
            }

            if !todayItems.isEmpty {
                sectionHeader("AUJOURD'HUI · \(todayItems.count)", color: .primary)
                taskListCard(todayItems)
            }

            if !upcoming.isEmpty {
                sectionHeader("BIENTÔT · \(upcoming.count)", color: .primary)
                taskListCard(upcoming)
            }

            if !later.isEmpty {
                sectionHeader("PLUS TARD · \(later.count)", color: .primary)
                taskListCard(later)
            }
        }
    }

    // MARK: - Done View

    private var doneView: some View {
        VStack(alignment: .leading, spacing: 16) {
            let completedTasks = tasks.filter { $0.isCompleted }.sorted { $0.deadline > $1.deadline }

            if completedTasks.isEmpty {
                emptyState("Aucune tâche complétée")
            } else {
                taskCountLabel("\(completedTasks.count) tâche\(completedTasks.count > 1 ? "s" : "") complétée\(completedTasks.count > 1 ? "s" : "")")
                taskListCard(completedTasks)
            }
        }
    }

    // MARK: - Shared Components

    private func sectionHeader(_ text: String, color: Color) -> some View {
        Text(text)
            .font(.caption)
            .fontWeight(.bold)
            .foregroundStyle(color)
    }

    private func taskCountLabel(_ text: String) -> some View {
        Text(text)
            .font(.subheadline)
            .foregroundStyle(.secondary)
    }

    private func emptyState(_ text: String) -> some View {
        HStack {
            Spacer()
            VStack(spacing: 8) {
                Image(systemName: "checkmark.circle")
                    .font(.largeTitle)
                    .foregroundStyle(accentColor.opacity(0.4))
                Text(text)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .padding(.top, 60)
            Spacer()
        }
    }

    private func taskListCard(_ taskList: [PrismeTask]) -> some View {
        VStack(spacing: 0) {
            ForEach(Array(taskList.enumerated()), id: \.element.id) { index, task in
                taskRow(task)

                if index < taskList.count - 1 {
                    Divider()
                        .padding(.leading, 52)
                }
            }
        }
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private func taskRow(_ task: PrismeTask) -> some View {
        HStack(spacing: 12) {
            Button {
                withAnimation {
                    task.isCompleted.toggle()
                }
            } label: {
                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundStyle(task.isCompleted ? accentColor : Color.gray.opacity(0.3))
            }

            NavigationLink(destination: TaskDetailView(task: task)) {
                HStack(spacing: 0) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(task.title)
                            .font(.body)
                            .foregroundStyle(task.isCompleted ? .secondary : .primary)
                            .strikethrough(task.isCompleted)

                        Text(deadlineLabel(task.deadline))
                            .font(.caption)
                            .foregroundStyle(isOverdue(task) ? .red : .secondary)
                    }

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundStyle(Color(.systemGray3))
                }
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }

    // MARK: - Add Button

    private var addButton: some View {
        Button {
            showingNewTask = true
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

    // MARK: - Task Filtering

    private var calendar: Calendar { Calendar.current }

    private var overdueTasks: [PrismeTask] {
        let startOfToday = calendar.startOfDay(for: Date())
        return tasks.filter { !$0.isCompleted && $0.deadline < startOfToday }
    }

    private var tasksForToday: [PrismeTask] {
        tasks.filter { calendar.isDateInToday($0.deadline) }
    }

    private var upcomingTasks: [PrismeTask] {
        let startOfTomorrow = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: Date()))!
        let endOfWeek = calendar.date(byAdding: .day, value: 7, to: calendar.startOfDay(for: Date()))!
        return tasks.filter { !$0.isCompleted && $0.deadline >= startOfTomorrow && $0.deadline < endOfWeek }
    }

    private var laterTasks: [PrismeTask] {
        let endOfWeek = calendar.date(byAdding: .day, value: 7, to: calendar.startOfDay(for: Date()))!
        return tasks.filter { !$0.isCompleted && $0.deadline >= endOfWeek }
    }

    private func isOverdue(_ task: PrismeTask) -> Bool {
        !task.isCompleted && task.deadline < calendar.startOfDay(for: Date())
    }

    private func deadlineLabel(_ date: Date) -> String {
        let today = calendar.startOfDay(for: Date())

        if calendar.isDateInToday(date) {
            return "Aujourd'hui"
        }
        if calendar.isDateInYesterday(date) {
            return "Hier"
        }
        if calendar.isDateInTomorrow(date) {
            return "Demain"
        }

        let days = calendar.dateComponents([.day], from: today, to: calendar.startOfDay(for: date)).day ?? 0
        if days < 0 {
            return "Il y a \(abs(days)) j"
        }
        if days <= 7 {
            return "Dans \(days) j"
        }

        return date.formatted(.dateTime.day().month(.abbreviated).locale(frLocale))
    }
}
