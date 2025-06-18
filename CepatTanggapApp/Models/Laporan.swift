import Foundation
import SwiftUI

struct Laporan: Codable, Identifiable {
    let id: Int
    let userId: Int
    let judul: String
    let deskripsi: String
    let foto: String?
    let lokasi: String?
    let status: StatusLaporan
    let createdAt: String
    let updatedAt: String
    let user: User
    let logStatus: [LogStatus]?
    
    // No need for manual encoding/decoding
    // The default Codable implementation with convertFromSnakeCase will handle everything
    // Make sure to set the keyDecodingStrategy to .convertFromSnakeCase when decoding JSON

    // Convenience initializer (digunakan di Preview / pembuatan dummy)
    init(id: Int,
         userId: Int,
         judul: String,
         deskripsi: String,
         foto: String? = nil,
         lokasi: String? = nil,
         status: StatusLaporan = .pending,
         createdAt: String,
         updatedAt: String,
         user: User,
         logStatus: [LogStatus]? = nil) {
        self.id = id
        self.userId = userId
        self.judul = judul
        self.deskripsi = deskripsi
        self.foto = foto
        self.lokasi = lokasi
        self.status = status
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.user = user
        self.logStatus = logStatus
    }

    static var sample: Laporan {
        let user = User(id: 1, nik: "000", nama: "Sample", role: "warga", alamat: nil)
        return Laporan(id: 1, userId: 1, judul: "Contoh", deskripsi: "Desc", createdAt: "2023-01-01T00:00:00Z", updatedAt: "2023-01-01T00:00:00Z", user: user)
    }
}

struct LogStatus: Codable, Identifiable {
    let id: Int
    let laporanId: Int
    let status: StatusLaporan
    let userId: Int
    let waktu: String
    let user: User
    
    // No need for manual CodingKeys
    // Will be handled by convertFromSnakeCase
}

enum StatusLaporan: String, Codable, CaseIterable {
    case pending = "pending"
    case diproses = "diproses"
    case selesai = "selesai"

    var displayName: String {
        switch self {
        case .pending: return "Menunggu"
        case .diproses: return "Diproses"
        case .selesai: return "Selesai"
        }
    }

    var color: String {
        switch self {
        case .pending: return "orange"
        case .diproses: return "blue"
        case .selesai: return "green"
        }
    }

    var uiColor: Color {
        switch self {
        case .pending: return Color.orange
        case .diproses: return Color.blue
        case .selesai: return Color.green
        }
    }
}

struct LaporanListResponse: Codable {
    let message: String?
    let data: [Laporan]
}
