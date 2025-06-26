import SwiftUI

struct LaporanRow: View {
    let laporan: Laporan

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(laporan.kategori.rawValue)
                        .font(.headline)
                        .foregroundColor(.primary)

                    if let lokasi = laporan.lokasi, !lokasi.isEmpty {
                        HStack {
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

            if !laporan.deskripsi.isEmpty {
                Text(laporan.deskripsi)
                    .font(.subheadline)
                    .foregroundColor(.primary.opacity(0.8))
                    .lineLimit(2)
            }

            if let url = laporan.fullFotoURL {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
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
                            .frame(height: 200)
                            .frame(maxWidth: .infinity)
                            .background(Color.gray.opacity(0.2))
                    @unknown default:
                        EmptyView()
                    }
                }
                .cornerRadius(8)
            }

            HStack {
                Text("Oleh: \(laporan.user.nama)")
                    .font(.caption2)
                    .foregroundColor(.gray)

                Spacer()

                Text(formatDate(laporan.createdAt))
                    .font(.caption2)
                    .foregroundColor(.gray)
            }
        }
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white) // Ganti dari merah ke putih (seperti Instagram)
    }

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
