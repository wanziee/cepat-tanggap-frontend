import SwiftUI

struct LaporanDetailView: View {
    let laporan: Laporan
    @StateObject private var viewModel = LaporanViewModel()
    @State private var selectedStatus: StatusLaporan
    @State private var showingStatusUpdateAlert = false
    
    init(laporan: Laporan) {
        self.laporan = laporan
        _selectedStatus = State(initialValue: laporan.status)
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Header with status
                StatusHeaderView(
                    status: laporan.status,
                    canUpdate: viewModel.currentUserCanUpdateStatus(),
                    onSelect: { status in
                        selectedStatus = status
                        showingStatusUpdateAlert = true
                    }
                )
                
                // Title and description
                VStack(alignment: .leading, spacing: 8) {
                    Text(laporan.kategori.rawValue)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Oleh: \(laporan.user.nama) • \(formatDate(laporan.createdAt))")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    if let lokasi = laporan.lokasi, !lokasi.isEmpty {
                        HStack {
                            Image(systemName: "mappin.and.ellipse")
                            Text(lokasi)
                        }
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .padding(.top, 4)
                    }
                }
                .padding(.bottom, 8)
                
                Divider()
                
                // Description
                Text(laporan.deskripsi)
                    .font(.body)
                    .padding(.bottom, 8)
                
                // Photo if available
                if let url = laporan.fullFotoURL{
                    AsyncImage(url: url) { image in
                        image.resizable()
                            .aspectRatio(contentMode: .fit)
                            .cornerRadius(8)
                    } placeholder: {
                        ProgressView()
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                }
                
                Divider()
                
                // Status History
                Text("Riwayat Status")
                    .font(.headline)
                
                // Compute sorted logs with proper unwrapping
                let sortedLogs = laporan.logStatus?.sorted { $0.waktu > $1.waktu } ?? []
                
                VStack(alignment: .leading, spacing: 12) {
                    ForEach(sortedLogs, id: \.id) { log in
                        LogStatusRow(log: log, isLast: log.id == sortedLogs.last?.id)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .padding(.leading, 8)
            }
            .padding()
        }
        .navigationTitle("Detail Laporan")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Konfirmasi", isPresented: $showingStatusUpdateAlert) {
            Button("Batal", role: .cancel) {}
            Button("Update") {
                viewModel.updateStatus(laporanId: laporan.id, status: selectedStatus) { _ in
                    // Handle completion if needed
                }
            }
        } message: {
            Text("Anda yakin ingin mengubah status laporan menjadi \(selectedStatus.displayName)?")
        }
        .onAppear {
            viewModel.laporanId = laporan.id
        }
    }
    
    private func formatDate(_ dateString: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        if let date = formatter.date(from: dateString) {
            formatter.dateStyle = .medium
            formatter.timeStyle = .short
            return formatter.string(from: date)
        }
        return dateString
    }
}

struct LaporanDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let user = User(id: 1, nik: "1234567890", nama: "John Doe", role: "warga", alamat: "Jl. Contoh No. 123")
        let logStatus = [
            LogStatus(
                id: 1,
                laporanId: 1,
                status: .pending,
                userId: 1,
                waktu: "2023-06-13T10:30:00.000Z",
                user: user
            )
        ]
        let laporan = Laporan(
            id: 1,
            userId: 1,
            kategori: .jalanTransportasi,
            deskripsi: "Jalan di depan rumah rusak parah, mohon diperbaiki.",
            foto: "/uploads/example.jpg",
            lokasi: "Jl. Contoh No. 123",
            status: .pending,
            createdAt: "2023-06-13T10:30:00.000Z",
            updatedAt: "2023-06-13T10:30:00.000Z",
            user: user,
            logStatus: logStatus
        )
        
        NavigationView {
            LaporanDetailView(laporan: laporan)
        }
    }
}


