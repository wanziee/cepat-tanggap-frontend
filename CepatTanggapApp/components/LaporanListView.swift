//
//  LaporanListView.swift
//  CepatTanggapApp
//
//  Created by mohammad ichwan al ghifari on 14/06/25.
//

import SwiftUI

struct LaporanListView: View {
    let laporanList: [Laporan]
    var onDelete: ((Int) -> Void)? = nil
    var laporanSaya: Bool = false
    
    var body: some View {
        ScrollView (showsIndicators: false){
            

                
            if laporanSaya {
                Rectangle()
                    .frame(height: 100)/// ini padding atas
                    .foregroundStyle(Color.clear)
            }

            ForEach(Array(laporanList.enumerated()), id: \.element.id) { index, laporan in
                NavigationLink(destination: LaporanDetailView(laporan: laporan)) {
                    LaporanRow(laporan: laporan)
                        .background(Color.white)
                }
                .buttonStyle(PlainButtonStyle()) // Hindari padding default dari NavigationLink
                .frame(maxWidth: .infinity, alignment: .leading)


                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                    if let onDelete = onDelete {
                        Button(role: .destructive) {
                            onDelete(index)
                        } label: {
                            Label("Hapus", systemImage: "trash")
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }

    }
}


#Preview {
    NavigationView {
        LaporanListView(
            laporanList: [
                Laporan(
                    id: 1,
                    userId: 1,
                    kategori: .jalanTransportasi,
                    deskripsi: "Jalan berlubang di depan sekolah SD alhdfjkah kahsdjkah fka fkajhd f",
                    foto: nil, lokasi: "RW 1, RT 4, Jl. Semangka No. 7",
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
                        alamat: nil
                    ),
                    logStatus: []
                ),
                Laporan(
                    id: 2,
                    userId: 2,
                    kategori: .listrikPJU, // ✅ perbaikan ini
                    deskripsi: "Kabel listrik menjuntai ke jalan, berbahaya.",
                    foto: nil, lokasi: "RW 2, RT 7, Jl. Mangga No. 9",
                    status: .pending,
                    createdAt: "2025-06-26T12:30:00.000Z",
                    updatedAt: "2025-06-26T13:00:00.000Z",
                    kdLaporan: "LP002",
                    isAnonymous: false,
                    user: User(
                        id: 2,
                        nik: "9876543210",
                        nama: "Warga RW 2",
                        role: "warga",
                        alamat: nil
                    ),
                    logStatus: []
                )
            ],
            laporanSaya: true
        )
    }
}

