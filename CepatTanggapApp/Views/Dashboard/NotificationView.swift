//
//  NotificationView.swift
//  CepatTanggapApp
//
//  Created by mohammad ichwan al ghifari on 27/06/25.
//


import SwiftUI

struct NotificationView: View {
    let laporanList: [Laporan]
    @Binding var hasNewNotification: Bool


    var notifications: [Notification] {
        var hasil: [Notification] = []

        for laporan in laporanList {
            if let logStatusList = laporan.logStatus {
                for log in logStatusList {
                    let notif = Notification(from: log, laporan: laporan)
                    hasil.append(notif)
                }
            }
        }

        return hasil.sorted { $0.rawDate > $1.rawDate }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    ForEach(Array(notifications.enumerated()), id: \.element.id) { index, notification in
                        VStack(spacing: 12) {
                            HStack(alignment: .top, spacing: 12) {
                                Image(systemName: notification.icon)
                                    .foregroundColor(notification.color)
                                    .font(.title3)
                                    .padding(10)
                                    .background(notification.bgColor)
                                    .clipShape(Circle())

                                VStack(alignment: .leading, spacing: 4) {
                                    HStack {
                                        Text(notification.title)
                                            .font(.subheadline)
                                            
                                        Spacer()
                                        Text(notification.date)
                                            .font(.caption2)
                                            .foregroundColor(.gray)
                                    }
                                    HStack{
                                        if notification.message != "" {
                                            Text(notification.message)
                                                .font(.footnote)
                                                .foregroundColor(.secondary)
                                        }
                                        
                                        if notification.foto != nil {
                                            Text("(foto lampiran)")
                                                .font(.footnote)
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                    Text("Kode Laporan: \(notification.kodeLaporan)")
                                        .font(.caption)
                                        .foregroundColor(.blue)
                                }

                                Spacer()
                            }
                            .padding(.horizontal)
                            .padding(.vertical, 8)
                            

                                Divider()
                        }
                    }
                }
                .padding(.top)
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("Notifikasi")
        }
        .onAppear{
            hasNewNotification = false
        }
    }
}

//#Preview {
//    let user = User(id: 1, nik: "000", nama: "Sample User", role: "warga", alamat: "Jl. Testing")
//
//    let laporan1 = Laporan(
//        id: 1,
//        userId: 1,
//        kategori: .fasilitasUmum,
//        deskripsi: "Laporan fasilitas rusak",
//        foto: nil,
//        lokasi: "Lokasi A",
//        status: .diproses,
//        createdAt: "2025-06-27T08:00:00Z",
//        updatedAt: "2025-06-27T09:00:00Z",
//        kdLaporan: "LAP001",
//        isAnonymous: false,
//        user: user,
//        logStatus: [
//            LogStatus(id: 1, laporanId: 1, status: .diproses, userId: 2, waktu: "2025-06-27T09:00:00Z", tanggapan: "Sedang kami proses", foto: nil, user: user)
//        ]
//    )
//
//    let laporan2 = Laporan(
//        id: 2,
//        userId: 1,
//        kategori: .sampahKebersihan,
//        deskripsi: "Sampah menumpuk",
//        foto: nil,
//        lokasi: "Lokasi B",
//        status: .selesai,
//        createdAt: "2025-06-26T08:00:00Z",
//        updatedAt: "2025-06-26T10:00:00Z",
//        kdLaporan: "LAP002",
//        isAnonymous: false,
//        user: user,
//        logStatus: [
//            LogStatus(id: 2, laporanId: 2, status: .selesai, userId: 2, waktu: "2025-06-26T10:00:00Z", tanggapan: "Sudah ditangani", foto: nil, user: user)
//        ]
//    )
//
//    let laporan3 = Laporan(
//        id: 3,
//        userId: 1,
//        kategori: .keamanan,
//        deskripsi: "Kejadian mencurigakan",
//        foto: nil,
//        lokasi: "Lokasi C",
//        status: .ditolak,
//        createdAt: "2025-06-25T08:00:00Z",
//        updatedAt: "2025-06-25T10:00:00Z",
//        kdLaporan: "LAP003",
//        isAnonymous: true,
//        user: user,
//        logStatus: [
//            LogStatus(id: 3, laporanId: 3, status: .ditolak, userId: 2, waktu: "2025-06-25T10:00:00Z", tanggapan: "Tidak sesuai prosedur", foto: nil, user: user)
//        ]
//    )
//
//    NotificationView(laporanList: [laporan1, laporan2, laporan3], hasNewNotification: constant(false))
//}
