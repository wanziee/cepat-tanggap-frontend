import SwiftUI

struct KasRTView: View {
    @StateObject private var viewModel = KasRTViewModel()

    var body: some View {
        NavigationView {
            ScrollView {
                if viewModel.isLoading {
                    ProgressView("Memuat data...")
                        .padding()
                } else if let error = viewModel.errorMessage {
                    Text("Gagal memuat data: \(error)")
                        .foregroundColor(.red)
                        .padding()
                } else if viewModel.kasList.isEmpty {
                    Text("Belum ada data kas untuk RT Anda.")
                        .padding()
                } else {
                    VStack(spacing: 16) {
                        ForEach(viewModel.kasList) { kas in
                            laporanCard(for: kas)
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Kas RT")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                viewModel.fetchKas()
            }
            .background(Color(UIColor.systemGroupedBackground).ignoresSafeArea())
        }
    }

    private func laporanCard(for kas: KasBulanan) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Image(systemName: "doc.richtext.fill")
                .resizable()
                .scaledToFit()
                .frame(height: 160)
                .frame(maxWidth: .infinity)
                .foregroundColor(.blue)
                .background(Color.blue.opacity(0.1))

            VStack(alignment: .leading, spacing: 8) {
                Text("Laporan Kas")
                    .font(.caption)
                    .foregroundColor(.accentColor)
                    .fontWeight(.semibold)

                Text(kas.bulanFormatted)
                    .font(.title3)
                    .fontWeight(.bold)

                HStack(spacing: 6) {
                    Image(systemName: "house.fill")
                        .foregroundColor(.accentColor)
                    Text("RT \(kas.relatedRt ?? "-") / RW \(kas.relatedRw ?? "-")")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                if let url = kas.fileUrl {
                    Link("Lihat PDF", destination: url)
                        .font(.subheadline)
                        .foregroundColor(.blue)
                        .padding(.top, 4)
                }
            }
            .padding()
        }
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .shadow(color: Color.black.opacity(0.05), radius: 6, x: 0, y: 3)
    }
}

#Preview {
    KasRTView()
}
