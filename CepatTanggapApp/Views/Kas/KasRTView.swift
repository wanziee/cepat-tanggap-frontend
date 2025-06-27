import SwiftUI

struct KasRTView: View {
    @State private var laporanKas: [LaporanKas] = [
        .init(id: 1, bulan: "Mei 2025", rt: "04/017", gambar: "test"),
        .init(id: 2, bulan: "April 2025", rt: "04/017", gambar: "test"),
        .init(id: 3, bulan: "Maret 2025", rt: "04/017", gambar: "test")
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    ForEach(laporanKas) { laporan in
                        laporanCard(for: laporan)
                    }
                }
                .padding()
            }
            .navigationTitle("Kas RT")
            .navigationBarTitleDisplayMode(.inline)
            .background(Color(UIColor.systemGroupedBackground).ignoresSafeArea())
        }
    }

    // MARK: - Kartu Tampilan
    private func laporanCard(for laporan: LaporanKas) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Image(laporan.gambar)
                .resizable()
                .scaledToFill()
                .frame(height: 180)
                .clipped()
//                .cornerRadius(12, corners: [.topLeft, .topRight])
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Laporan Kas")
                    .font(.caption)
                    .foregroundColor(.accentColor)
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Text("Bulan \(laporan.bulan)")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                    .frame(maxWidth: .infinity, alignment: .leading)

                HStack(spacing: 6) {
                    Image(systemName: "house.fill")
                        .foregroundColor(.accentColor)
                    Text("RT \(laporan.rt)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            .padding()
        }
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .shadow(color: Color.black.opacity(0.05), radius: 6, x: 0, y: 3)
    }
}

struct LaporanKas: Identifiable {
    let id: Int
    let bulan: String
    let rt: String
    let gambar: String
}

#Preview {
    KasRTView()
}
