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
    
    var body: some View {
        List {
            ForEach(Array(laporanList.enumerated()), id: \.element.id) { index, laporan in
                NavigationLink(destination: LaporanDetailView(laporan: laporan)) {
                    LaporanRow(laporan: laporan)
                }
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
        }
        .listStyle(PlainListStyle())
    }
}

