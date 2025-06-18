import SwiftUI
import MapKit

@MainActor
struct MapView: UIViewRepresentable {
    @Binding var region: MKCoordinateRegion
    @Binding var selectedCoordinate: CLLocationCoordinate2D?
    var locationManager: LocationManager
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.showsUserLocation = true
        mapView.setRegion(region, animated: true)
        
        // Tambahkan gesture recognizer untuk menangani tap
        let tapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTap(_:)))
        mapView.addGestureRecognizer(tapGesture)
        
        return mapView
    }
    
    func updateUIView(_ mapView: MKMapView, context: Context) {
        // Pastikan update UI di thread utama
        DispatchQueue.main.async {
            // Update region jika berubah
            let spanChanged = abs(mapView.region.span.latitudeDelta - self.region.span.latitudeDelta) > 0.0001 ||
                              abs(mapView.region.span.longitudeDelta - self.region.span.longitudeDelta) > 0.0001
            let latChanged = abs(mapView.region.center.latitude - self.region.center.latitude) > 0.000001
            let lonChanged = abs(mapView.region.center.longitude - self.region.center.longitude) > 0.000001
            if spanChanged || latChanged || lonChanged {
                mapView.setRegion(self.region, animated: true)
            }
            
            // Update annotations
            self.updateAnnotations(on: mapView)
        }
    }
    
    private func updateAnnotations(on mapView: MKMapView) {
        // Hapus semua annotations yang ada
        mapView.removeAnnotations(mapView.annotations)
        
        // Tambahkan pin untuk lokasi yang dipilih
        if let coordinate = selectedCoordinate {
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            mapView.addAnnotation(annotation)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    @MainActor
    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MapView
        
        init(_ parent: MapView) {
            self.parent = parent
        }
        
        @objc func handleTap(_ gesture: UITapGestureRecognizer) {
            guard let mapView = gesture.view as? MKMapView else { return }
            let location = gesture.location(in: mapView)
            let coordinate = mapView.convert(location, toCoordinateFrom: mapView)
            
            // Update selected coordinate
            parent.selectedCoordinate = coordinate
            
            // Update region di thread utama
            DispatchQueue.main.async {
                self.parent.region = MKCoordinateRegion(
                    center: coordinate,
                    span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                )
            }
        }
        
        func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
            // Update region ke lokasi pengguna saat pertama kali terdeteksi
            if let location = userLocation.location {
                let center = CLLocationCoordinate2D(
                    latitude: location.coordinate.latitude,
                    longitude: location.coordinate.longitude
                )
                let region = MKCoordinateRegion(
                    center: center,
                    span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                )
                
                // Update region parent
                DispatchQueue.main.async {
                    self.parent.region = region
                }
            }
        }
    }
}
