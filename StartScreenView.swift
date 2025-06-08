import SwiftUI
import CoreData

struct StartScreenView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(entity: Settings.entity(), sortDescriptors: []) private var settingsResults: FetchedResults<Settings>

    @State private var settings: Settings?
    @State private var path: [Screen] = []

    enum Screen: Hashable {
        case game(GameSession, Settings)
        case summary(GameSession)
    }

    var body: some View {
        NavigationStack(path: $path) {
            VStack(spacing: 32) {
                Spacer().frame(height: 20)

                // Logo z efektem
                Image("game_logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 240)
                    .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
                    .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 4)
                    .padding(.top, -10)

                

                Spacer()

                // Przycisk startu gry
                Button(action: prepareNewGame) {
                    Label("Zagraj", systemImage: "globe.europe.africa.fill")
                        .font(.title2)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(16)
                        .shadow(radius: 5)
                }
                .padding(.horizontal, 32)

                Spacer().frame(height: 40)
            }
            .navigationDestination(for: Screen.self) { screen in
                switch screen {
                case .game(let gameSession, let settings):
                    GameView(path: $path, gameSession: gameSession, settings: settings)
                case .summary(let gameSession):
                    SummaryView(gameSession: gameSession, path: $path)
                }
            }
            .onAppear(perform: loadSettings)
        }
    }

    private func loadSettings() {
        if let existingSettings = settingsResults.first {
            settings = existingSettings
        } else {
            let newSettings = Settings(context: viewContext)
            newSettings.id = UUID()
            newSettings.numberOfRounds = 5
            try? viewContext.save()
            settings = newSettings
        }
    }

    private func prepareNewGame() {
        guard let settings = settings else { return }
        let session = GameSession(context: viewContext)
        session.id = UUID()
        session.date = Date()
        try? viewContext.save()

        path.append(.game(session, settings))
    }
}
