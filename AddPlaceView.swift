import SwiftUI
import CoreData

struct AddPlaceView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) private var presentationMode

    @State private var name: String = ""
    @State private var latitudeText: String = ""
    @State private var longitudeText: String = ""
    @State private var selectedImage: UIImage?
    @State private var showImagePicker = false

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Informacje o miejscu")) {
                    TextField("Nazwa miejsca", text: $name)
                    
                    TextField("Szerokość geograficzna", text: $latitudeText)
                        .keyboardType(.decimalPad)
                    
                    TextField("Długość geograficzna", text: $longitudeText)
                        .keyboardType(.decimalPad)
                }

                Section(header: Text("Zdjęcie")) {
                    VStack(alignment: .center, spacing: 10) {
                        if let image = selectedImage {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFit()
                                .frame(height: 200)
                                .cornerRadius(12)
                                .shadow(radius: 5)

                            Button("Zmień zdjęcie") {
                                showImagePicker = true
                            }
                        } else {
                            Button(action: {
                                showImagePicker = true
                            }) {
                                VStack {
                                    Image(systemName: "photo.on.rectangle.angled")
                                        .resizable()
                                        .frame(width: 60, height: 60)
                                        .foregroundColor(.blue)
                                    Text("Wybierz zdjęcie")
                                        .font(.subheadline)
                                }
                                .frame(maxWidth: .infinity)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical)
                }

                Section {
                    Button(action: savePlace) {
                        Text("Zapisz miejsce")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(canSave ? Color.blue : Color.gray)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .disabled(!canSave)
                }
            }
            .navigationTitle("Dodaj miejsce")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showImagePicker) {
                ImagePicker(image: $selectedImage)
            }
        }
    }

    var canSave: Bool {
        !name.isEmpty &&
        Double(latitudeText) != nil &&
        Double(longitudeText) != nil &&
        selectedImage != nil
    }

    private func savePlace() {
        guard let latitude = Double(latitudeText),
              let longitude = Double(longitudeText) else { return }

        let newPlace = Place(context: viewContext)
        newPlace.id = UUID()
        newPlace.name = name
        newPlace.latitude = latitude
        newPlace.longitude = longitude
        newPlace.imageData = selectedImage?.jpegData(compressionQuality: 0.8)
        newPlace.source = "user"

        do {
            try viewContext.save()
            presentationMode.wrappedValue.dismiss()
        } catch {
            print("Błąd zapisu: \(error)")
        }
    }
}
