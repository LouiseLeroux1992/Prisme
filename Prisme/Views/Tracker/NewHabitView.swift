import SwiftUI
import SwiftData

struct NewHabitView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \HabitCategory.order) private var categories: [HabitCategory]

    @State private var name = ""
    @State private var selectedCategory: HabitCategory?
    @State private var showingNewCategory = false
    @State private var newCategoryName = ""

    private let accentColor = Color(red: 0.95, green: 0.6, blue: 0.35)

    var body: some View {
        NavigationStack {
            Form {
                Section("Nom") {
                    TextField("ex. Méditation 10 min", text: $name)
                }

                Section("Catégorie") {
                    ForEach(categories) { category in
                        Button {
                            selectedCategory = category
                        } label: {
                            HStack {
                                Text(category.icon)
                                Text(category.name)
                                    .foregroundStyle(.primary)
                                Spacer()
                                if selectedCategory?.id == category.id {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundStyle(accentColor)
                                } else {
                                    Image(systemName: "circle")
                                        .foregroundStyle(Color(.systemGray3))
                                }
                            }
                        }
                    }

                    if showingNewCategory {
                        HStack {
                            TextField("Nom de la catégorie", text: $newCategoryName)
                            Button("OK") {
                                addCategory()
                            }
                            .disabled(newCategoryName.isEmpty)
                        }
                    } else {
                        Button("+ Nouvelle catégorie") {
                            showingNewCategory = true
                        }
                        .foregroundStyle(accentColor)
                    }
                }
            }
            .navigationTitle("Nouvelle habitude")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annuler") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("OK") {
                        save()
                    }
                    .fontWeight(.bold)
                    .disabled(name.isEmpty || selectedCategory == nil)
                }
            }
            .onAppear {
                selectedCategory = categories.first
            }
        }
    }

    private func save() {
        let habit = Habit(name: name, category: selectedCategory)
        modelContext.insert(habit)
        dismiss()
    }

    private func addCategory() {
        let category = HabitCategory(name: newCategoryName, icon: "📌", order: categories.count)
        modelContext.insert(category)
        selectedCategory = category
        newCategoryName = ""
        showingNewCategory = false
    }
}
