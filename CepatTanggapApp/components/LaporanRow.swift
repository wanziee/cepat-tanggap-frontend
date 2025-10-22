import SwiftUI

struct LaporanRow: View {
    let laporan: Laporan

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {

            headerSection
            deskripsiSection
            if let url = laporan.fullFotoURL {
                imageSection(url: url)
            }
            footerSection
            Divider()
                .padding(.horizontal, -16)
        }
        .padding(.horizontal)
        .padding(.vertical, 12)
        .background(Color.white)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Header
    private var headerSection: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                Text(laporan.kategori.rawValue)
                    .font(.headline)
                    .foregroundColor(.primary)

                if let lokasi = laporan.lokasi, !lokasi.isEmpty {
                    HStack(spacing: 4) {
                        Image(systemName: "mappin.and.ellipse")
                            .font(.caption)
                        Text(lokasi)
                            .font(.caption)
                            .lineLimit(1)
                    }
                    .foregroundColor(.gray)
                }
            }

            Spacer()

            Text(laporan.status.displayName)
                .font(.caption)
                .fontWeight(.semibold)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(laporan.status.uiColor)
                .foregroundColor(.white)
                .cornerRadius(12)
        }
    }

    // MARK: - Deskripsi
    private var deskripsiSection: some View {
        Text(laporan.deskripsi)
            .font(.subheadline)
            .foregroundColor(.primary.opacity(0.85))
            .lineLimit(2)
            .multilineTextAlignment(.leading)
    }

    // MARK: - Gambar
    @ViewBuilder
    private func imageSection(url: URL) -> some View {
        AsyncImage(url: url) { phase in
            switch phase {
            case .empty:
                ZStack {
                    Rectangle().fill(Color.gray.opacity(0.1))
                    ProgressView()
                }
                .frame(height: 200)


            case .success(let image):
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 200)
                    .frame(maxWidth: .infinity)
                    .clipped()


            case .failure:
                Image(systemName: "photo")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 200)
                    .frame(maxWidth: .infinity)
                    .foregroundStyle(Color.gray)
                    .background(Color.gray.opacity(0.2))


            @unknown default:
                EmptyView()
            }
        }
        .padding(.horizontal, -16)
    }

    // MARK: - Footer
    private var footerSection: some View {
        HStack {
            Text("Oleh: Warga")
                .font(.caption2)
                .foregroundColor(.gray)

            Spacer()

            Text(formatDate(laporan.createdAt))
                .font(.caption2)
                .foregroundColor(.gray)
        }
    }

    // MARK: - Date Formatter
    private func formatDate(_ dateString: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        if let date = formatter.date(from: dateString) {
            formatter.dateStyle = .short
            formatter.timeStyle = .short
            return formatter.string(from: date)
        }
        return dateString
    }
}

#Preview {
    LaporanRow(
        laporan: Laporan(
            id: 1,
            userId: 1,
            kategori: .jalanTransportasi,
            deskripsi: "Jalan rusak parah di depan sekolah SD yang mengganggu akses warga.",
            foto: "test",
            lokasi: "RW 01, RT 04, Jl. Pendidikan No. 3",
            status: .diproses,
            createdAt: "2025-06-27T14:10:00.000Z",
            updatedAt: "2025-06-27T15:00:00.000Z",
            kdLaporan: "LP001",
            isAnonymous: false,
            user: User(
                id: 1,
                nik: "1234567890",
                nama: "Ichwan",
                role: "warga",
                alamat: "Jl. Contoh No. 1"
            ),
            logStatus: []
        )
    )

}
