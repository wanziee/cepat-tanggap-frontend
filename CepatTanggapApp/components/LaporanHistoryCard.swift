//
//  LaporanHistoryCard.swift
//  CepatTanggapApp
//
//  Created by mohammad ichwan al ghifari on 21/06/25.
//

import SwiftUI



struct LaporanHistoryCard: View {
    let laporan: Laporan
    var isLaporanWarga: Bool = false

    var body: some View {
        NavigationLink(destination: LaporanDetailView(laporan: laporan, isLaporanWarga: isLaporanWarga)) {
            VStack(alignment: .leading, spacing: 10) {
                Text(laporan.kategori.rawValue) // Pastikan kategori pakai enum .rawValue
                    .font(.headline)
                    .fontWeight(.bold)
                
                Text(laporan.deskripsi)
                    .font(.subheadline)
                    .lineLimit(2)
                    .foregroundColor(.primary)

                HStack {
                    Text(formattedDate(laporan.createdAt))
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Spacer()

                    HStack(spacing: 0){
                        Text("Lihat Detail ")
                            .font(.caption)
                            .foregroundStyle(Color.blue)

                        Image(systemName: "arrow.right")
                            .font(.caption)
                            .foregroundStyle(Color.blue)
                    }
                }
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.2), radius: 2, x: 0, y: 0)
        }
        .buttonStyle(PlainButtonStyle())
    }

    private func formattedDate(_ isoString: String) -> String {
        let formatter = ISO8601DateFormatter()
        if let date = formatter.date(from: isoString) {
            let outputFormatter = DateFormatter()
            outputFormatter.dateStyle = .medium
            return outputFormatter.string(from: date)
        }
        return isoString
    }
}
