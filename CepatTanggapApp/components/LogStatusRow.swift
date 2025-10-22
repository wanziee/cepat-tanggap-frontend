import SwiftUI

struct LogStatusRow: View {
    let log: LogStatus
    let isLast: Bool

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // MARK: - Indicator
            VStack {
                // Lingkaran
                ZStack {
                    Circle()
                        .fill(log.status.uiColor)
                        .frame(width: 14, height: 14)
                        .shadow(color: log.status.uiColor.opacity(0.5), radius: 4, x: 0, y: 1)
                    Circle()
                        .stroke(Color.white, lineWidth: 2)
                        .frame(width: 14, height: 14)
                }

                // Garis Vertikal
                if !isLast {
                    Rectangle()
                        .fill(log.status.uiColor.opacity(0.4))
                        .frame(width: 2)
                        .frame(maxHeight: .infinity)
                        .padding(.top, 2) // Sedikit ruang antara lingkaran dan garis
                } else {
                    Spacer()
                }
            }
            .frame(width: 20)
            .alignmentGuide(.top) { d in d[.top] } // Biar sejajar

            // MARK: - Konten
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 4) {
                    Text(log.status.displayName)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(log.status.uiColor)

                    Text("• \(formatDate(log.waktu))")
                        .font(.subheadline)
                        .foregroundColor(.primary)
                }

                Text("Oleh: \(log.user.nama) (\(log.user.role))")
                    .font(.caption)
                    .foregroundColor(.gray)

                if let tanggapan = log.tanggapan, !tanggapan.isEmpty {
                    Text(tanggapan)
                        .font(.caption)
                        .foregroundColor(.primary)
                        .padding(8)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(10)
                }

                if let url = log.fullFotoURL {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                                .frame(height: 140)
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(height: 140)
                                .clipped()
                        case .failure:
                            Image(systemName: "photo")
                                .frame(height: 140)
                                .background(Color.gray.opacity(0.2))
                        @unknown default:
                            EmptyView()
                        }
                    }
                    .cornerRadius(8)
                }
            }

            Spacer()
        }
        .padding(.vertical, 6)
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
