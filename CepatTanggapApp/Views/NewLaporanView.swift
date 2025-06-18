import SwiftUI
import PhotosUI
import CoreLocation
import Combine

struct NewLaporanView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var laporanViewModel: LaporanViewModel
    
    @State private var judul = ""
    @State private var deskripsi = ""
    @State private var lokasi: String = ""
    @State private var showMapPicker = false
    @State private var selectedCoordinate: CLLocationCoordinate2D? = nil
    @State private var isGeocoding: Bool = false
    @State private var selectedImage: UIImage?
    @State private var isImagePickerPresented = false
    @State private var isShowingCamera = false
    @State private var showSuccessAlert = false
    @State private var showErrorAlert = false
    
    // RT/RW Selection
    @State private var selectedRW = 1
    @State private var selectedRT = 1
    private let rwRange = 1...12
    private let rtRange = 1...10
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Informasi Laporan")) {
                    TextField("Judul", text: $judul)
                    
                    // RW Picker
                    Picker("RW", selection: $selectedRW) {
                        ForEach(rwRange, id: \.self) { rw in
                            Text("RW \(rw)").tag(rw)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    
                    // RT Picker
                    Picker("RT", selection: $selectedRT) {
                        ForEach(rtRange, id: \.self) { rt in
                            Text("RT \(rt)").tag(rt)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    
                    Button(action: {
                        selectedCoordinate = nil // reset agar MapPickerView selalu ke lokasi user
                        showMapPicker = true
                    }) {
                        HStack {
                            Image(systemName: "mappin.circle")
                            if isGeocoding {
                                ProgressView().scaleEffect(0.7)
                                Text("Mengambil alamat...")
                            } else {
                                Text(lokasi.isEmpty ? "Tag Lokasi Sekarang" : lokasi)
                            }
                        }
                    }
                    .sheet(isPresented: $showMapPicker, onDismiss: {
                        if let coordinate = selectedCoordinate {
                            isGeocoding = true
                            let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
                            CLGeocoder().reverseGeocodeLocation(location) { placemarks, error in
                                DispatchQueue.main.async {
                                    isGeocoding = false
                                    if let placemark = placemarks?.first {
                                        let alamat = [placemark.name, placemark.subLocality, placemark.locality, placemark.administrativeArea]
                                            .compactMap { $0 }
                                            .joined(separator: ", ")
                                        lokasi = alamat.isEmpty ? "(\(coordinate.latitude), \(coordinate.longitude))" : alamat
                                    } else {
                                        lokasi = "(\(coordinate.latitude), \(coordinate.longitude))"
                                    }
                                }
                            }
                        }
                    }) {
                        MapPickerView(selectedCoordinate: $selectedCoordinate)
                    }
                    
                    ZStack(alignment: .topLeading) {
                        if deskripsi.isEmpty {
                            Text("Deskripsi laporan Anda")
                                .foregroundColor(Color(UIColor.placeholderText))
                                .padding(.top, 8)
                                .padding(.leading, 4)
                        }
                        TextEditor(text: $deskripsi)
                            .frame(minHeight: 100)
                    }
                }
                
                Section(header: Text("Foto (opsional)")) {
                    if let image = selectedImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(height: 200)
                            .cornerRadius(8)
                            .overlay(
                                Button(action: { selectedImage = nil }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.red)
                                        .background(Color.white)
                                        .clipShape(Circle())
                                }
                                    .padding(4),
                                alignment: .topTrailing
                            )
                    } else {
                        HStack {
                            Button(action: { isImagePickerPresented = true }) {
                                HStack {
                                    Image(systemName: "photo")
                                    Text("Pilih dari Galeri")
                                }
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                
                            }
                            
                            
                            Button(action: { isShowingCamera = true }) {
                                HStack {
                                    Image(systemName: "camera")
                                    Text("Ambil Foto")
                                }
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                            }
                            
                        }
                    }
                }
            }
            .navigationTitle("Buat Laporan Baru")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Batal") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Simpan") {
                        saveLaporan()
                    }
                    .disabled(judul.isEmpty || deskripsi.isEmpty || laporanViewModel.isLoading)
                }
            }
            .sheet(isPresented: $isImagePickerPresented) {
                ImagePicker(image: $selectedImage, sourceType: .photoLibrary)
            }
            .sheet(isPresented: $isShowingCamera) {
                ImagePicker(image: $selectedImage, sourceType: .camera)
            }
            .alert("Sukses", isPresented: $showSuccessAlert) {
                Button("OK") {
                    presentationMode.wrappedValue.dismiss()
                }
            } message: {
                Text("Laporan berhasil dibuat")
            }
            .alert("Error", isPresented: $showErrorAlert) {
                Button("OK") {
                    laporanViewModel.errorMessage = nil
                }
            } message: {
                Text(laporanViewModel.errorMessage ?? "Terjadi kesalahan")
            }
        }
    }
    
    private func saveLaporan() {
        // Add RT/RW to lokasi
        let fullLokasi = "RW \(selectedRW), RT \(selectedRT)"
        let finalLokasi = lokasi.isEmpty ? fullLokasi : "\(fullLokasi), \(lokasi)"
        
        laporanViewModel.createLaporan(
            judul: judul,
            deskripsi: deskripsi,
            lokasi: finalLokasi,
            image: selectedImage
        ) { success in
            if success {
                showSuccessAlert = true
            } else {
                showErrorAlert = true
            }
        }
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    let sourceType: UIImagePickerController.SourceType
    @Environment(\.presentationMode) private var presentationMode
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.image = image
            }
            parent.presentationMode.wrappedValue.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}



#Preview {
    NewLaporanView()
        .environmentObject(LaporanViewModel())
}

