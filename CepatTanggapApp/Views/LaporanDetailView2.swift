//import SwiftUI
//
//struct LaporanDetailView2: View {
//    let laporan: Laporan
//    @StateObject private var viewModel = LaporanViewModel()
//    @State private var selectedStatus: StatusLaporan
//    @State private var showingStatusUpdateAlert = false
//    @Environment(\.dismiss) private var dismiss
//    
//    init(laporan: Laporan) {
//        self.laporan = laporan
//        _selectedStatus = State(initialValue: laporan.status)
//    }
//    
//    var body: some View {
//        ScrollView(.vertical, showsIndicators: false) {
//            VStack(spacing: 0) {
//                GeometryReader { geometry in
//                    let safeTop = geometry.safeAreaInsets.top
//                    
//                    ZStack{
//                        Group {
//                            if let foto = laporan.foto, let url = URL(string: foto), foto.starts(with: "http") {
//                                AsyncImage(url: url) { image in
//                                    image.resizable().aspectRatio(contentMode: .fill)
//                                } placeholder: {
//                                    ZStack {
//                                        Color.gray.opacity(0.2)
//                                        ProgressView()
//                                    }
//                                }
//                            } else {
//                                Image("test")
//                                    .resizable()
//                                    .scaledToFill()
//                                    .foregroundColor(.gray.opacity(0.4))
//                            }
//                        }
//                        .frame(width: geometry.size.width, height: 265 + safeTop)
//                        .clipped()
//                        .offset(y: -safeTop)
//                    }
//                }
//                .frame(height: 270)
//
//                
//             
//                
//                
//                
//                VStack{
//                    
//                }
//                .frame(maxWidth: .infinity)
//                .frame(height: 100)
//                .background(Color.white)
//                .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
//                .offset(y: -35)
//
//
//                VStack(alignment: .leading, spacing: 16) {
//                    StatusHeaderView(
//                        status: laporan.status,
//                        canUpdate: viewModel.currentUserCanUpdateStatus(),
//                        onSelect: { status in
//                            selectedStatus = status
//                            showingStatusUpdateAlert = true
//                        }
//                    )
//                    
//                    
//                    VStack(alignment: .leading, spacing:8){
//                        Text("Permasalahan:")
//                        Text(laporan.deskripsi)
//                            .font(.body)
//                    }
//                    .padding(.top, 10)
//                    
//                    VStack(alignment: .leading, spacing:8){
//                        Text("Kategori:")
//                        Text(laporan.kategori.rawValue)
//                            .font(.body)
//                    }
//                    .padding(.top, 10)
//                    
//                    VStack(alignment: .leading, spacing:8){
//                        Text("Lokasi:")
//                        if let lokasi = laporan.lokasi, !lokasi.isEmpty {
//
//                                Text(lokasi)
//
//                            .font(.body)
//
//                        }
//                    }
//                    .padding(.top, 10)
//
//
//                    
//
//
//                    Text("Oleh: \(laporan.user.nama) • \(formatDate(laporan.createdAt))")
//                        .font(.subheadline)
//                        .foregroundColor(.gray)
//
//
//
//                    Divider()
//
//                    Text("Riwayat Status")
//                        .font(.headline)
//
//                    let sortedLogs = laporan.logStatus?.sorted { $0.waktu > $1.waktu } ?? []
//
//                    VStack(alignment: .leading, spacing: 12) {
//                        ForEach(sortedLogs, id: \.id) { log in
//                            LogStatusRow(log: log, isLast: log.id == sortedLogs.last?.id)
//                                .frame(maxWidth: .infinity, alignment: .leading)
//                        }
//                    }
//                    .padding(.leading, 8)
//                }
//                .padding()
//                .offset(y: -135)
//                
//                
//                
//                
//            }
//        }
//        .background(Color.white)
//
//        .alert("Konfirmasi", isPresented: $showingStatusUpdateAlert) {
//            Button("Batal", role: .cancel) {}
//            Button("Update") {
//                viewModel.updateStatus(laporanId: laporan.id, status: selectedStatus) { _ in }
//            }
//        } message: {
//            Text("Anda yakin ingin mengubah status laporan menjadi \(selectedStatus.displayName)?")
//        }
//        .onAppear {
//            viewModel.laporanId = laporan.id
//        }
//    }
//
//    private func formatDate(_ dateString: String) -> String {
//        let formatter = DateFormatter()
//        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
//        if let date = formatter.date(from: dateString) {
//            formatter.dateStyle = .medium
//            formatter.timeStyle = .short
//            return formatter.string(from: date)
//        }
//        return dateString
//    }
//}
//
//#Preview {
//    let user = User(id: 1, nik: "1234567890", nama: "John Doe", role: "warga", alamat: "Jl. Contoh No. 123")
//    let logStatus = [
//        LogStatus(id: 1, laporanId: 1, status: .pending, userId: 1, waktu: "2023-06-13T10:30:00.000Z", user: user)
//    ]
//    let laporan = Laporan(
//        id: 1,
//        userId: 1,
//        kategori: .jalanTransportasi,
//        deskripsi: "Jalan di depan rumah rusak parah, mohon diperbaiki.",
//        foto: "test",
//        lokasi: "Jl. Contoh No. 123",
//        status: .pending,
//        createdAt: "2023-06-13T10:30:00.000Z",
//        updatedAt: "2023-06-13T10:30:00.000Z",
//        kdLaporan: "LAP89789wer",
//        isAnonymous: false,
//        user: user,
//        logStatus: logStatus
//    )
//
//    return NavigationView {
//        LaporanDetailView2(laporan: laporan)
//            .navigationBarHidden(true)
//            .toolbar(.hidden)
//    }
//}
