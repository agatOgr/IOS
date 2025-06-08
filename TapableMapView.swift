import SwiftUI
import MapKit

struct TapableMapView: UIViewRepresentable {
    @Binding var region: MKCoordinateRegion
    @Binding var userCoordinate: CLLocationCoordinate2D?
    @Binding var actualCoordinate: CLLocationCoordinate2D?
    var isInteractionEnabled: Bool

    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: TapableMapView
        var lastRegion: MKCoordinateRegion?

        init(_ parent: TapableMapView) {
            self.parent = parent
        }

        @objc func handleTap(_ gestureRecognizer: UITapGestureRecognizer) {
            guard parent.isInteractionEnabled else { return }
            guard let mapView = gestureRecognizer.view as? MKMapView else { return }
            let point = gestureRecognizer.location(in: mapView)
            let coordinate = mapView.convert(point, toCoordinateFrom: mapView)
            parent.userCoordinate = coordinate
        }

        func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
            parent.region = mapView.region
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator

        mapView.setRegion(region, animated: false)

        mapView.isScrollEnabled = true
        mapView.isRotateEnabled = true
        mapView.isPitchEnabled = true
        mapView.isZoomEnabled = true

        let tapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTap(_:)))
        mapView.addGestureRecognizer(tapGesture)

        return mapView
    }

    func updateUIView(_ uiView: MKMapView, context: Context) {
        // Aktualizuj region tylko jeśli się zmienił
        if context.coordinator.lastRegion?.center.latitude != region.center.latitude ||
           context.coordinator.lastRegion?.center.longitude != region.center.longitude ||
           context.coordinator.lastRegion?.span.latitudeDelta != region.span.latitudeDelta ||
           context.coordinator.lastRegion?.span.longitudeDelta != region.span.longitudeDelta {
            uiView.setRegion(region, animated: true)
            context.coordinator.lastRegion = region
        }

        uiView.isUserInteractionEnabled = isInteractionEnabled

        // Usuń stare pinezki
        uiView.removeAnnotations(uiView.annotations)

        // Dodaj pinezkę użytkownika
        if let userCoord = userCoordinate {
            let userAnnotation = MKPointAnnotation()
            userAnnotation.coordinate = userCoord
            userAnnotation.title = "Twój wybór"
            uiView.addAnnotation(userAnnotation)
        }

        // Dodaj pinezkę faktycznej lokalizacji
        if let actualCoord = actualCoordinate {
            let actualAnnotation = MKPointAnnotation()
            actualAnnotation.coordinate = actualCoord
            actualAnnotation.title = "Prawdziwa lokalizacja"
            uiView.addAnnotation(actualAnnotation)
        }
    }
}
