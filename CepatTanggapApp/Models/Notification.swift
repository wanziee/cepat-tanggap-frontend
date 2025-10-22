//
//  Notification.swift
//  CepatTanggapApp
//
//  Created by mohammad ichwan al ghifari on 28/06/25.
//
import Foundation
import SwiftUI

struct Notification: Identifiable {
    let id = UUID()
    let title: String
    let message: String
    let rawDate: Date
    let foto: String?
    var date: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "id_ID")
        formatter.dateFormat = "d MMM yyyy"
        return formatter.string(from: rawDate)
    }
    let icon: String
    let color: Color
    let bgColor: Color
    let kodeLaporan: String

    init(from log: LogStatus, laporan: Laporan) {
        switch log.status {
        case .diproses:
            title = "Laporan sedang diproses"
            icon = "arrow.clockwise.circle.fill"
            color = .orange
            bgColor = .orange.opacity(0.2)
        case .selesai:
            title = "Laporanmu selesai ditangani"
            icon = "checkmark.seal.fill"
            color = .green
            bgColor = .green.opacity(0.2)
        case .ditolak:
            title = "Laporan ditolak"
            icon = "xmark.octagon.fill"
            color = .red
            bgColor = .red.opacity(0.2)
        case .pending:
            title = "Laporan berhasil dibuat"
            icon = "square.and.pencil"
            color = .blue
            bgColor = .blue.opacity(0.2)
        }


        message = log.tanggapan ?? ""
        rawDate = log.waktu.toDate() ?? Date()
        kodeLaporan = laporan.kdLaporan
        foto = log.foto ?? nil
    }
}



extension String {
    func toDate() -> Date? {
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return isoFormatter.date(from: self)
    }

    func formattedDate() -> String {
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        if let date = isoFormatter.date(from: self) {
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "id_ID")
            formatter.dateFormat = "d MMM yyyy"
            return formatter.string(from: date)
        }
        return self
    }
}

extension Date {
    func formattedToString() -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "id_ID")
        formatter.dateFormat = "d MMM yyyy"
        return formatter.string(from: self)
    }
}
