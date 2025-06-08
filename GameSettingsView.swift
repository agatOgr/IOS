import SwiftUI
import CoreData

struct GameSettingsView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        entity: Settings.entity(),
        sortDescriptors: []
    ) private var settingsResults: FetchedResults<Settings>

    @State private var numberOfRounds: Int = 5
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Liczba rund")) {
                    Picker("Liczba rund", selection: $numberOfRounds) {
                        ForEach(2...5, id: \.self) { number in
                            Text("\(number) \(number == 1 ? "runda" : "rundy")")
                                .tag(number)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                Section {
                    Button(action: {
                        saveSettings()
                    }) {
                        HStack {
                            Spacer()
                            Text("Zapisz ustawienia")
                                .bold()
                                .foregroundColor(.white)
                            Spacer()
                        }
                    }
                    .padding(10)
                    .background(Color.blue)
                    .cornerRadius(10)
                }
                .listRowBackground(Color.clear)
            }
            .navigationTitle("Ustawienia Gry")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                loadSettings()
            }
        }
    }

    private func loadSettings() {
        if let existing = settingsResults.first {
            numberOfRounds = Int(existing.numberOfRounds)
        }
    }

    private func saveSettings() {
        let settings = settingsResults.first ?? Settings(context: viewContext)
        settings.id = settings.id ?? UUID()
        settings.numberOfRounds = Int16(numberOfRounds)

        do {
            try viewContext.save()
            dismiss()
        } catch {
            print("Błąd zapisu ustawień: \(error.localizedDescription)")
        }
    }
}
