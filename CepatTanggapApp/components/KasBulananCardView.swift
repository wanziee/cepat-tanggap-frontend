//
//  KasBulananCardView.swift
//  CepatTanggapApp
//
//  Created by mohammad ichwan al ghifari on 29/06/25.
//

import SwiftUI


struct KasBulananCardView: View {
    let kas: KasBulanan

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "doc.richtext")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 32, height: 32)
                    .foregroundColor(.blue)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Laporan RT Bulan \(kas.bulanFormatted)")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    if let desc = kas.description, !desc.isEmpty {
                        Text(desc)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }

                Spacer()
            }

            HStack(spacing: 16) {
                if let rt = kas.relatedRt {
                    Label("RT \(rt)", systemImage: "person.2.fill")
                        .font(.caption)
                        .foregroundColor(.gray)
                }

                if let rw = kas.relatedRw {
                    Label("RW \(rw)", systemImage: "house.fill")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }

            if let fileUrl = kas.fileUrl {
                Link(destination: fileUrl) {
                    HStack {
                        Image(systemName: "arrow.down.doc")
                        Text("Lihat File")
                    }
                    .font(.subheadline.bold())
                    .foregroundColor(.white)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 16)
                    .background(Color.blue)
                    .cornerRadius(10)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 6, x: 0, y: 3)
    }
}
