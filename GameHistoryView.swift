import SwiftUI
import CoreData

struct GameHistoryView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State private var sortOption: SortOption = .dateDescending

    enum SortOption: String, CaseIterable, Identifiable {
        case dateDescending = "Najnowsze"
        case scoreAscending = "Najlepsze wyniki"
        var id: String { self.rawValue }
    }

    @FetchRequest private var gameSessions: FetchedResults<GameSession>

    init() {
        _gameSessions = FetchRequest(
            entity: GameSession.entity(),
            sortDescriptors: [NSSortDescriptor(keyPath: \GameSession.date, ascending: false)]
        )
    }

    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()

    var body: some View {
        List {
            Section {
                Picker("Sortuj według", selection: $sortOption) {
                    ForEach(SortOption.allCases) { option in
                        Text(option.rawValue).tag(option)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.vertical, 6)
            }

            Section(header: Text("Sesje gry")) {
                if sortedSessions.isEmpty {
                    Text("Brak zapisanych rozgrywek.")
                        .foregroundColor(.gray)
                        .padding(.vertical)
                        .frame(maxWidth: .infinity, alignment: .center)
                } else {
                    ForEach(sortedSessions) { session in
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Wynik średni: \(String(format: "%.2f", session.score)) km")
                                .font(.headline)
                            if let date = session.date {
                                Text(dateFormatter.string(from: date))
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.vertical, 6)
                    }
                    .onDelete(perform: deleteSessions)
                }
            }
        }
        .listStyle(.insetGrouped)
        .listSectionSpacing(10)
        .navigationTitle("Historia Gry")
        .toolbar {
            EditButton()
        }
    }

    private var sortedSessions: [GameSession] {
        switch sortOption {
        case .dateDescending:
            return gameSessions.sorted { ($0.date ?? .distantPast) > ($1.date ?? .distantPast) }
        case .scoreAscending:
            return gameSessions.sorted { $0.score < $1.score }
        }
    }

    private func deleteSessions(at offsets: IndexSet) {
        for index in offsets {
            let sessionToDelete = sortedSessions[index]
            if let originalIndex = gameSessions.firstIndex(of: sessionToDelete) {
                viewContext.delete(gameSessions[originalIndex])
            }
        }

        do {
            try viewContext.save()
        } catch {
            print("Błąd usuwania sesji: \(error.localizedDescription)")
        }
    }
}
