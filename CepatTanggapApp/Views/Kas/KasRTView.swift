import SwiftUI

struct KasRTView: View {
    @StateObject private var viewModel = KasRTViewModel()

    var body: some View {
        NavigationView {
            ZStack{
                Color(UIColor.systemGroupedBackground) // latar belakang layar
                    .ignoresSafeArea()
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        if viewModel.isLoading {
                            ProgressView("Memuat data...")
                                .padding(.top)
                        } else if let error = viewModel.errorMessage {
                            Text("Gagal memuat data: \(error)")
                                .foregroundColor(.red)
                                .padding()
                        } else if viewModel.kasList.isEmpty {
                            Text("Belum ada data kas untuk RT Anda.")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                                .padding()
                        } else {
                            ForEach(viewModel.kasList) { kas in
                                laporanCard(for: kas)
                            }
                        }
                    }
                    .padding()
                }
                .background(Color(UIColor.systemGroupedBackground).ignoresSafeArea())
                .navigationTitle("Kas RT")
                .navigationBarTitleDisplayMode(.inline)
                .onAppear {
                    viewModel.fetchKas()
                }
            }
        }
        .background(Color(UIColor.systemGroupedBackground).ignoresSafeArea())
    }

    private func laporanCard(for kas: KasBulanan) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Laporan RT - \(kas.bulanFormatted)")
                        .font(.system(.title3, design: .rounded))
                        .fontWeight(.semibold)

                    Text("RT \(kas.relatedRt ?? "-") / RW \(kas.relatedRw ?? "-")")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                Spacer()

                if let url = kas.fileUrl {
                    Link(destination: url) {
                        HStack(spacing: 6) {
                            Image(systemName: "doc.richtext.fill")
                            Text("Lihat PDF")
                        }
                        .font(.caption)
                        .padding(.vertical, 6)
                        .padding(.horizontal, 12)
                        .background(Color.accentColor.opacity(0.15))
                        .foregroundColor(.accentColor)
                        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                    }
                }
            }

            if let desc = kas.description, !desc.isEmpty {
                Text(desc)
                    .font(.footnote)
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.05), radius: 6, x: 0, y: 4)
        )
    }
}

#Preview {
    KasRTView()
}
