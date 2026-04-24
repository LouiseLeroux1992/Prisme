import SwiftUI
import SwiftData

struct ContentView: View {
    @State private var selectedTab = 0

    private var currentTint: Color {
        switch selectedTab {
        case 0: return Color(red: 0.2, green: 0.6, blue: 1.0)
        case 1: return Color(red: 0.55, green: 0.35, blue: 0.75)
        case 2: return Color(red: 0.35, green: 0.7, blue: 0.45)
        case 3: return Color(red: 0.9, green: 0.72, blue: 0.25)
        case 4: return Color(red: 0.95, green: 0.6, blue: 0.35)
        default: return .accentColor
        }
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            Tab("Tâches", systemImage: "checkmark.circle", value: 0) {
                TasksView()
            }

            Tab("Mantras", systemImage: "sparkles", value: 1) {
                MantrasView()
            }

            Tab("Exercices", systemImage: "brain.head.profile", value: 2) {
                ExercicesListView()
            }

            Tab("Notes", systemImage: "note.text", value: 3) {
                NotesListView()
            }

            Tab("Tracker", systemImage: "chart.bar.fill", value: 4) {
                TrackerView()
            }
        }
        .tint(currentTint)
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [HabitCategory.self, Habit.self, HabitEntry.self, Mantra.self, Note.self, Exercise.self, PrismeTask.self], inMemory: true)
}
