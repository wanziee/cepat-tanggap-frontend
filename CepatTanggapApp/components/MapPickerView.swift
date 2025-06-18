import SwiftUI
import MapKit

// Membuat wrapper untuk koordinat yang bisa di-identifikasi
struct IdentifiableCoordinate: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
}

struct MapPickerView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var locManager = LocationManager()
    @Binding var selectedCoordinate: CLLocationCoordinate2D?
    
    @State private var region: MKCoordinateRegion
    
    init(selectedCoordinate: Binding<CLLocationCoordinate2D?>) {
        self._selectedCoordinate = selectedCoordinate
        let defaultCoordinate = CLLocationCoordinate2D(latitude: -6.2, longitude: 106.8)
        self._region = State(initialValue: MKCoordinateRegion(
            center: selectedCoordinate.wrappedValue ?? defaultCoordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        ))
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Map & overlays
            ZStack(alignment: .top) {
                MapView(region: $region, selectedCoordinate: $selectedCoordinate, locationManager: locManager)
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .ignoresSafeArea()
                
                

                // Overlay judul & koordinat
                VStack() {
                    HStack{
                        Image(systemName: "xmark")
                            .padding(.vertical, 5)
                            .padding(.horizontal, 5)
                            .background(.thinMaterial)
                            .clipShape(.circle)
                            .font(.headline)
                        
                        Text("Pilih Lokasi")
                            .font(.headline)
                            .padding(.vertical, 5)
                            .padding(.horizontal, 16)
                            .background(.thinMaterial)
                            .clipShape(RoundedRectangle(cornerRadius: 50))
                        
                    }
                   
                    
                        HStack(spacing: 12) {
                            Label("Lat: \(String(format: "%.6f", selectedCoordinate?.latitude ?? "0"))", systemImage: "location.north")
                            Label("Lon: \(String(format: "%.6f", selectedCoordinate?.longitude ?? "0"))", systemImage: "location")
                        }
//                        .font(.system(.body, design: .monospaced))
                        .font(.system(size: 15))
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 6)
                        .background(.thinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 50))

                }
                .padding(.top, 18)
            }
            // Tombol floating
            VStack {
                Spacer()
                Button(action: select) {
                    Text("Gunakan Lokasi Ini")
                        .bold()
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(14)
                        .shadow(color: Color.black.opacity(0.15), radius: 8, y: 3)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 28)
            }
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
        
        .onAppear {
            locManager.requestLocation()
            // Hanya set jika belum ada selectedCoordinate
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                if selectedCoordinate == nil, let userLoc = locManager.currentLocation {
                    region.center = userLoc.coordinate
                    selectedCoordinate = userLoc.coordinate
                }
            }
        }
        .onReceive(locManager.$currentLocation) { location in
            // Hanya set jika belum ada selectedCoordinate
            if selectedCoordinate == nil, let location = location {
                region.center = location.coordinate
                selectedCoordinate = location.coordinate
            }
        }
    }
    
    private func select() {
        selectedCoordinate = region.center
        dismiss()
    }
}

#Preview {
    struct PreviewWrapper: View {
        @State private var coordinate: CLLocationCoordinate2D? = nil
        
        var body: some View {
            MapPickerView(selectedCoordinate: $coordinate)
        }
    }

    return PreviewWrapper()
}
