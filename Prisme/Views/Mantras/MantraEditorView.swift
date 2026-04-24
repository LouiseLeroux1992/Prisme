import SwiftUI
import SwiftData

struct MantraEditorView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \Mantra.order) private var mantras: [Mantra]

    @State private var newMantraText = ""

    private let purple = Color(red: 0.35, green: 0.2, blue: 0.55)

    var body: some View {
        NavigationStack {
            List {
                Section {
                    ForEach(mantras) { mantra in
                        HStack {
                            Button(role: .destructive) {
                                deleteMantra(mantra)
                            } label: {
                                Image(systemName: "minus.circle.fill")
                                    .foregroundStyle(.red)
                            }
                            .buttonStyle(.plain)

                            Text(mantra.text)
                        }
                    }
                    .onMove(perform: moveMantra)
                }

                Section {
                    if showNewField {
                        TextField("Nouveau mantra", text: $newMantraText)
                            .onSubmit {
                                addMantra()
                            }
                    }

                    Button {
                        addMantra()
                    } label: {
                        Text("+ Ajouter un mantra")
                            .foregroundStyle(purple.opacity(0.6))
                    }
                }
            }
            .environment(\.editMode, .constant(.active))
            .navigationTitle("Éditer")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annuler") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("OK") {
                        dismiss()
                    }
                    .fontWeight(.bold)
                }
            }
        }
    }

    @State private var showNewField = false

    private func addMantra() {
        if showNewField && !newMantraText.isEmpty {
            let mantra = Mantra(text: newMantraText, order: mantras.count)
            modelContext.insert(mantra)
            newMantraText = ""
            showNewField = false
        } else {
            showNewField = true
        }
    }

    private func deleteMantra(_ mantra: Mantra) {
        modelContext.delete(mantra)
        reorderMantras()
    }

    private func moveMantra(from source: IndexSet, to destination: Int) {
        var ordered = mantras.sorted { $0.order < $1.order }
        ordered.move(fromOffsets: source, toOffset: destination)
        for (index, mantra) in ordered.enumerated() {
            mantra.order = index
        }
    }

    private func reorderMantras() {
        let ordered = mantras.sorted { $0.order < $1.order }
        for (index, mantra) in ordered.enumerated() {
            mantra.order = index
        }
    }
}
