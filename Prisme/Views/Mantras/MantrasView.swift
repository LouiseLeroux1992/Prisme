import SwiftUI
import SwiftData

struct MantrasView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Mantra.order) private var mantras: [Mantra]
    @State private var currentIndex = 0
    @State private var showingEditor = false

    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: colorScheme == .dark
                        ? [Color(red: 0.25, green: 0.15, blue: 0.35), Color(red: 0.3, green: 0.15, blue: 0.25)]
                        : [Color(red: 0.92, green: 0.82, blue: 0.95), Color(red: 0.96, green: 0.84, blue: 0.90)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                if mantras.isEmpty {
                    VStack {
                        Spacer()
                        Text("Aucun mantra")
                            .font(.title2)
                            .italic()
                            .foregroundStyle(colorScheme == .dark ? Color.white.opacity(0.3) : Color(red: 0.35, green: 0.2, blue: 0.55).opacity(0.5))
                        Spacer()
                    }
                } else {
                    TabView(selection: $currentIndex) {
                        ForEach(Array(mantras.enumerated()), id: \.element.id) { index, mantra in
                            Text(mantra.text)
                                .font(.system(size: 28, weight: .regular, design: .serif))
                                .italic()
                                .multilineTextAlignment(.center)
                                .foregroundStyle(colorScheme == .dark ? Color(red: 0.78, green: 0.68, blue: 0.92) : Color(red: 0.35, green: 0.2, blue: 0.55))
                                .padding(.horizontal, 40)
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .tag(index)
                        }
                    }
                    .tabViewStyle(.page(indexDisplayMode: .always))
                }
            }
            .navigationTitle("Mantras")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.hidden, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button {
                            showingEditor = true
                        } label: {
                            Label("Éditer les mantras", systemImage: "pencil")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .foregroundStyle(colorScheme == .dark ? Color(red: 0.78, green: 0.68, blue: 0.92) : Color(red: 0.35, green: 0.2, blue: 0.55))
                    }
                }
            }
        }
        .sheet(isPresented: $showingEditor) {
            MantraEditorView()
        }
        .onAppear {
            seedDefaultMantrasIfNeeded()
            setupPageControlAppearance()
        }
    }

    private func seedDefaultMantrasIfNeeded() {
        guard mantras.isEmpty else { return }

        let defaults = [
            "Pas les cheveux",
            "Nommer, puis agir",
            "10 min avant de répondre",
            "Non est permis",
            "Demander est légitime",
        ]

        for (index, text) in defaults.enumerated() {
            let mantra = Mantra(text: text, order: index)
            modelContext.insert(mantra)
        }
    }

    private func setupPageControlAppearance() {
        UIPageControl.appearance().currentPageIndicatorTintColor = UIColor(red: 0.35, green: 0.2, blue: 0.55, alpha: 1.0)
        UIPageControl.appearance().pageIndicatorTintColor = UIColor(red: 0.35, green: 0.2, blue: 0.55, alpha: 0.3)
    }
}

#Preview {
    MantrasView()
        .modelContainer(for: Mantra.self, inMemory: true)
}
