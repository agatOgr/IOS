//
//  GeoGuesserApp.swift
//  GeoGuesser
//
//  Created by Agata Ogrodnik on 22/04/2025.
//

import SwiftUI
import CoreData

@main
struct GeoGuesserApp: App {
    let persistenceController = PersistenceController.shared

    init() {
        let context = persistenceController.container.viewContext
        preloadPlacesIfNeeded(context: context)
    }

    var body: some Scene {
        WindowGroup {
            MainView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }

    private func preloadPlacesIfNeeded(context: NSManagedObjectContext) {
        let fetchRequest: NSFetchRequest<Place> = Place.fetchRequest()

        do {
            let count = try context.count(for: fetchRequest)
            if count == 0 {
                let placesData = [
                    ("Eiffel Tower", 48.8584, 2.2945, "eiffel"),
                    ("Statue of Liberty", 40.6892, -74.0445, "liberty"),
                    ("Colosseum", 41.8902, 12.4922, "colosseum"),
                    ("Big Ben", 51.5007, -0.1246, "bigben"),
                    ("Great Wall of China", 40.4319, 116.5704, "greatwall"),
                    ("Sydney Opera House", -33.8568, 151.2153, "sydneyopera"),
                    ("Taj Mahal", 27.1751, 78.0421, "tajmahal"),
                    ("Christ the Redeemer", -22.9519, -43.2105, "christredeemer"),
                    ("Machu Picchu", -13.1631, -72.5450, "machupicchu"),
                    ("Mount Fuji", 35.3606, 138.7274, "mountfuji")
                ]

                for (name, lat, lon, imageName) in placesData {
                    let place = Place(context: context)
                    place.id = UUID()
                    place.name = name
                    place.latitude = lat
                    place.longitude = lon
                    place.source = "Wikipedia"
                    place.imageName = imageName
                    place.imageData = UIImage(named: imageName)?.jpegData(compressionQuality: 1.0)
                }

                try context.save()
                print("📍 Wstępne dane zostały zapisane.")
            } else {
                print("✅ Encja Place już zawiera dane. Preload pominięty.")
            }
        } catch {
            print("❌ Błąd podczas preloadowania Places: \(error.localizedDescription)")
        }
    }
}
