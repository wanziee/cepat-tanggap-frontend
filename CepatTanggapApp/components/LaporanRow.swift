//
//  LaporanRow.swift
//  CepatTanggapApp
//
//  Created by mohammad ichwan al ghifari on 14/06/25.
//

import SwiftUI


struct LaporanRow: View {
    let laporan: Laporan
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(laporan.judul)
                        .font(.headline)
                        .foregroundColor(.primary) // Ensure text is fully opaque
                    
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
                    .foregroundColor(.primary.opacity(0.8)) // Slightly dimmed but still clear
                    .lineLimit(2)
            }
            
            if let url = laporan.fullFotoURL{
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                            .frame(height: 120)
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 120)
                            .clipped()
                    case .failure:
                        Image(systemName: "photo")
                            .frame(height: 120)
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
        .padding(.vertical, 8)
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



