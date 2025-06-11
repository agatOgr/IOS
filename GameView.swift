import SwiftUI
import MapKit
import CoreData

struct GameView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Binding var path: [StartScreenView.Screen]

    let defaultCenter = CLLocationCoordinate2D(latitude: 20.0, longitude: 0.0)
    let defaultSpan = MKCoordinateSpan(latitudeDelta: 40, longitudeDelta: 40)

    @State private var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 20.0, longitude: 0.0), span: MKCoordinateSpan(latitudeDelta: 40, longitudeDelta: 40))
    @State private var userCoordinate: CLLocationCoordinate2D? = nil
    @State private var actualCoordinate: CLLocationCoordinate2D? = nil

    @State private var currentPlace: Place? = nil
    @State private var allPlaces: [Place] = []
    @State private var currentRound = 1
    @State private var guessMade = false
    @State private var distanceInKm: Double? = nil
    @State private var showFullImage = false


    var gameSession: GameSession
    var settings: Settings

    var body: some View {
        VStack(spacing: 20) {
            // Tytuł i licznik rund
            HStack {
                Text("Runda \(currentRound) z \(settings.numberOfRounds)")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)
                Spacer()
            }
            .padding(.horizontal)

            // Obrazek lokalizacji
            if let imageData = currentPlace?.imageData,
               let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 280)
                    .frame(maxWidth: .infinity)
                    .clipped()
                    .cornerRadius(16)
                    .shadow(radius: 5)
                    .padding(.horizontal)
                    .onLongPressGesture {
                        showFullImage = true
                    }
            }


            // Mapa z interakcją
            TapableMapView(region: $region, userCoordinate: $userCoordinate, actualCoordinate: $actualCoordinate, isInteractionEnabled: !guessMade)
                .frame(height: 300)
                .cornerRadius(16)
                .shadow(radius: 4)
                .padding(.horizontal)

            // Wynik lub przyciski
            VStack(spacing: 12) {
                if guessMade {
                    if let distance = distanceInKm {
                        Label {
                            Text(String(format: "%.2f km od celu", distance))
                                .font(.headline)
                        } icon: {
                            Image(systemName: "location.viewfinder")
                                .foregroundColor(.blue)
                        }
                        .padding(.top)
                    }

                    Button(action: nextRound) {
                        Label("Następna lokalizacja", systemImage: "arrow.right.circle")
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.green)
                } else {
                    Button(action: makeGuess) {
                        Label("Zgadnij!", systemImage: "checkmark.circle")
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.blue)
                    .disabled(userCoordinate == nil || currentPlace == nil)
                }
            }
            .padding(.bottom)
        }
        .navigationBarBackButtonHidden(true)
        .onAppear(perform: loadPlaces)
        
        .sheet(isPresented: $showFullImage) {
            if let imageData = currentPlace?.imageData,
               let uiImage = UIImage(data: imageData) {
                ZStack {
                    Color.black.ignoresSafeArea()
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .padding()
                        .background(Color.black)
                        .onTapGesture {
                            showFullImage = false
                        }
                }
            }
        }
    }
       

    

    // MARK: - Game Logic
    private func loadPlaces() {
        let request: NSFetchRequest<Place> = Place.fetchRequest()
        do {
            allPlaces = try viewContext.fetch(request)
            allPlaces.shuffle()
            currentRound = 1
            currentPlace = allPlaces.first
            resetMapToDefault()
        } catch {
            print("Błąd ładowania miejsc: \(error.localizedDescription)")
        }
    }

    private func resetMapToDefault() {
        region = MKCoordinateRegion(center: defaultCenter, span: defaultSpan)
        userCoordinate = nil
        actualCoordinate = nil
        guessMade = false
        distanceInKm = nil
    }

    private func makeGuess() {
        guard let guessCoord = userCoordinate,
              let place = currentPlace else { return }

        actualCoordinate = CLLocationCoordinate2D(latitude: place.latitude, longitude: place.longitude)

        let guessLocation = CLLocation(latitude: guessCoord.latitude, longitude: guessCoord.longitude)
        let actualLocation = CLLocation(latitude: place.latitude, longitude: place.longitude)

        let distanceMeters = guessLocation.distance(from: actualLocation)
        distanceInKm = distanceMeters / 1000

        let newGuess = Guess(context: viewContext)
        newGuess.id = UUID()
        newGuess.userLatitude = guessCoord.latitude
        newGuess.userLongitude = guessCoord.longitude
        newGuess.distance = distanceInKm ?? 0
        newGuess.gameSession = gameSession
        newGuess.settings = settings
        newGuess.addToPlace(place)
        gameSession.addToGuess(newGuess)

        do {
            try viewContext.save()
        } catch {
            print("Błąd zapisu guess: \(error.localizedDescription)")
        }

        guessMade = true
        centerMapBetween(guessCoord, actualCoordinate!)
    }

    private func centerMapBetween(_ first: CLLocationCoordinate2D, _ second: CLLocationCoordinate2D) {
        let midLat = (first.latitude + second.latitude) / 2
        let midLon = (first.longitude + second.longitude) / 2

        var latDelta = abs(first.latitude - second.latitude) * 2.5
        var lonDelta = abs(first.longitude - second.longitude) * 2.5

        latDelta = min(latDelta, 90)
        lonDelta = min(lonDelta, 180)

        let span = MKCoordinateSpan(latitudeDelta: max(latDelta, 0.1), longitudeDelta: max(lonDelta, 0.1))
        let newRegion = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: midLat, longitude: midLon), span: span)

        withAnimation(.easeInOut(duration: 1.0)) {
            region = newRegion
        }
    }

    private func nextRound() {
        currentRound += 1
        if currentRound > settings.numberOfRounds || currentRound > allPlaces.count {
            let averageScore = calculateAverageScore()
            gameSession.score = averageScore
            try? viewContext.save()
            path.append(.summary(gameSession))
        } else {
            currentPlace = allPlaces[currentRound - 1]
            resetMapToDefault()
        }
    }

    private func calculateAverageScore() -> Double {
        let guesses = gameSession.guess as? Set<Guess> ?? []
        guard !guesses.isEmpty else { return 0 }
        let total = guesses.reduce(0) { $0 + $1.distance }
        return total / Double(guesses.count)
    }
}
