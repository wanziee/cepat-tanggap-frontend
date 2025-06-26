import SwiftUI
import PhotosUI
import CoreLocation
import Combine

struct NewLaporanView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var laporanViewModel: LaporanViewModel
    
    @State private var selectedKategori: KategoriLaporan = .fasilitasUmum
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
    @State private var deskripsiTooShort = false
    
    @State private var selectedRW = 1
    @State private var selectedRT = 1
    private let rwRange = 1...5
    private let rtRange = 1...10
    
    var jumlahHuruf: Int {
        deskripsi.count
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 18) {
                    
                    informasiSection()
                    
                    deskripsiSection()
                    
                    imagePickerSection()
                    
                    Button(action: {
                        if jumlahHuruf < 40 {
                            deskripsiTooShort = true
                        } else {
                            saveLaporan()
                        }
                    }) {
                        Text("Buat Laporan")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.accentColor)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .disabled(deskripsi.isEmpty || laporanViewModel.isLoading)
                    
                    Spacer()
                }
                .padding()
                .navigationTitle("Buat Laporan Baru")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Batal") {
                            presentationMode.wrappedValue.dismiss()
                        }
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
                .alert("Deskripsi Terlalu Pendek", isPresented: $deskripsiTooShort) {
                    Button("OK", role: .cancel) {}
                } message: {
                    Text("Deskripsi laporan harus minimal 40 huruf.")
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(UIColor.secondarySystemBackground))
        }
    }
    
    // MARK: - Informasi Section
    @ViewBuilder
    func informasiSection() -> some View {
        VStack(spacing: 0) {
            HStack {
                Text("Kategori").foregroundColor(.black)
                Spacer()
                Picker("", selection: $selectedKategori) {
                    ForEach(KategoriLaporan.allCases) { kat in
                        Text(kat.rawValue).tag(kat)
                    }
                }
                .pickerStyle(MenuPickerStyle())
            }
            .padding(.vertical, 8)
            
            Divider()
            
            HStack {
                Text("RW").foregroundColor(.black).frame(width: 80, alignment: .leading)
                Spacer()
                Picker("", selection: $selectedRW) {
                    ForEach(rwRange, id: \.self) { rw in
                        Text("RW \(rw)").tag(rw)
                    }
                }
                .pickerStyle(MenuPickerStyle())
            }
            .padding(.vertical, 8)
            
            Divider()
            
            HStack {
                Text("RT").foregroundColor(.black).frame(width: 80, alignment: .leading)
                Spacer()
                Picker("", selection: $selectedRT) {
                    ForEach(rtRange, id: \.self) { rt in
                        Text("RT \(rt)").tag(rt)
                    }
                }
                .pickerStyle(MenuPickerStyle())
            }
            .padding(.vertical, 8)
            
            Divider()
            
            HStack {
                Button(action: {
                    selectedCoordinate = nil
                    showMapPicker = true
                }) {
                    HStack {
                        if isGeocoding {
                            ProgressView().scaleEffect(0.7)
                            Text("Mengambil alamat...")
                        } else {
                            Text(lokasi.isEmpty ? "Tag Lokasi Sekarang" : lokasi)
                                .foregroundColor(.black)
                                .lineLimit(2)
                                .multilineTextAlignment(.leading)
                        }
                        Spacer()
                        Image(systemName: "mappin.and.ellipse").foregroundColor(.blue)
                    }
                    .padding(.bottom, 8)
                }
                .frame(maxWidth: .infinity)
            }
            .padding(.trailing)
            .padding(.vertical, 8)
            .padding(.top, 5)
            .sheet(isPresented: $showMapPicker, onDismiss: fetchAlamat) {
                MapPickerView(selectedCoordinate: $selectedCoordinate)
            }
        }
        .padding(.leading)
        .background(Color.white)
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }

    // MARK: - Deskripsi Section
    @ViewBuilder
    func deskripsiSection() -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Deskripsi")
                    .foregroundColor(.black)
                Spacer()
                Text("\(jumlahHuruf)/40")
                    .font(.subheadline)
                    .foregroundColor(Color.gray)
            }
            .padding(.bottom, 5)
            
            ZStack(alignment: .topLeading) {
                if deskripsi.isEmpty {
                    Text("Deskripsi laporan Anda")
                        .foregroundColor(.gray)
                        .padding(.top, 13)
                        .padding(.leading, 8)
                }
                
                TextEditor(text: $deskripsi)
                    .frame(minHeight: 90, maxHeight: 150)
                    .padding(4)
                    .background(Color.clear)
                    .scrollContentBackground(.hidden)
            }
            .background(Color("secondWhiteForm"))
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color("borderForm"), lineWidth: 0.5)
            )
        }
        .padding()
        .background(Color.white)
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }

    // MARK: - Image Picker Section
    @ViewBuilder
    func imagePickerSection() -> some View {
        VStack {
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
                ZStack {
                    Rectangle()
                        .fill(Color("secondWhiteForm"))
                        .frame(height: 200)
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(style: StrokeStyle(lineWidth: 1, dash: [8]))
                                .foregroundColor(Color("borderForm"))
                        )
                    VStack(spacing: 8) {
                        Image(systemName: "camera")
                            .font(.system(size: 40))
                            .foregroundColor(.gray)
                        Text("Tambah Foto")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }
            }
            
            HStack {
                Button(action: { isImagePickerPresented = true }) {
                    HStack {
                        Image(systemName: "photo")
                        Text("Pilih dari Galeri")
                    }
                }
                .frame(maxWidth: .infinity)
                
                Divider()
                
                Button(action: { isShowingCamera = true }) {
                    HStack {
                        Image(systemName: "camera")
                        Text("Ambil Foto")
                    }
                }
                .frame(maxWidth: .infinity)
            }
            .padding(.top)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(15)
    }

    // MARK: - Helper
    private func fetchAlamat() {
        guard let coordinate = selectedCoordinate else { return }
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

    private func saveLaporan() {
        let fullLokasi = "RW \(selectedRW), RT \(selectedRT)"
        let finalLokasi = lokasi.isEmpty ? fullLokasi : "\(fullLokasi), \(lokasi)"
        laporanViewModel.createLaporan(
            kategori: selectedKategori.rawValue,
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


// MARK: - Image Picker
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

// MARK: - Preview
#Preview {
    NewLaporanView()
        .environmentObject(LaporanViewModel())
}
