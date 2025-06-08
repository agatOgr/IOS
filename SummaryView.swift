import SwiftUI

struct SummaryView: View {
    var gameSession: GameSession
    @Binding var path: [StartScreenView.Screen]

    var body: some View {
        VStack(spacing: 30) {
            Text("🎉 Podsumowanie gry 🎉")
                .font(.largeTitle)
                .bold()
                .multilineTextAlignment(.center)

            let guesses = gameSession.guess as? Set<Guess> ?? []
            let totalDistance = guesses.reduce(0.0) { $0 + $1.distance }
            let averageDistance = guesses.isEmpty ? 0 : totalDistance / Double(guesses.count)

            VStack(spacing: 16) {
                Label("Liczba rund: \(guesses.count)", systemImage: "flag.checkered")
                    .font(.title3)

                VStack(spacing: 8) {
                    Text("Średnia odległość:")
                        .font(.headline)
                        .foregroundColor(.secondary)

                    Text(String(format: "%.2f km", averageDistance))
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(.blue)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(.systemGray6))
                        .shadow(radius: 2)
                )
            }
            .padding(.horizontal)

            Spacer()

            Button(action: {
                path = []
            }) {
                HStack {
                    Image(systemName: "arrow.uturn.backward.circle.fill")
                    Text("Powrót do menu")
                }
                .font(.headline)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(16)
            }
            .padding(.horizontal)
        }
        .padding()
        .navigationBarBackButtonHidden(true)
    }
}
