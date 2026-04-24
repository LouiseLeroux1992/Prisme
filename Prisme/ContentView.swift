import SwiftUI
import SwiftData

struct ContentView: View {
    var body: some View {
        TabView {
            Tab("Tâches", systemImage: "checkmark.circle") {
                TasksView()
            }

            Tab("Mantras", systemImage: "sparkles") {
                MantrasView()
            }

            Tab("Exercices", systemImage: "brain.head.profile") {
                ExercicesListView()
            }

            Tab("Notes", systemImage: "note.text") {
                NotesListView()
            }

            Tab("Tracker", systemImage: "chart.bar.fill") {
                TrackerView()
            }
        }
        .tint(Color(red: 0.95, green: 0.6, blue: 0.35))
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [HabitCategory.self, Habit.self, HabitEntry.self, Mantra.self, Note.self, Exercise.self, PrismeTask.self], inMemory: true)
}
