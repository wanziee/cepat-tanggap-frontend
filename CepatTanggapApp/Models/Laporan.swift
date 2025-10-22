import Foundation
import SwiftUI

struct Laporan: Codable, Identifiable {
    let id: Int
    let userId: Int
    let kategori: KategoriLaporan
    let deskripsi: String
    let foto: String?
    let lokasi: String?
    let status: StatusLaporan
    let createdAt: String
    let updatedAt: String
    let kdLaporan: String           // ✅ Tambahan
    let isAnonymous: Bool?             // ✅ Tambahan
    let user: User
    let logStatus: [LogStatus]?

    // Convenience initializer (digunakan di Preview / dummy)
    init(
        id: Int,
        userId: Int,
        kategori: KategoriLaporan,
        deskripsi: String,
        foto: String? = nil,
        lokasi: String? = nil,
        status: StatusLaporan = .pending,
        createdAt: String,
        updatedAt: String,
        kdLaporan: String,
        isAnonymous: Bool,
        user: User,
        logStatus: [LogStatus]? = nil
    ) {
        self.id = id
        self.userId = userId
        self.kategori = kategori
        self.deskripsi = deskripsi
        self.foto = foto
        self.lokasi = lokasi
        self.status = status
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.kdLaporan = kdLaporan
        self.isAnonymous = isAnonymous
        self.user = user
        self.logStatus = logStatus
    }

    static var sample: Laporan {
        let user = User(id: 1, nik: "000", nama: "Sample", role: "warga", alamat: nil)
        return Laporan(
            id: 1,
            userId: 1,
            kategori: .fasilitasUmum,
            deskripsi: "Contoh laporan fasilitas umum",
            foto: "contoh_foto",
            lokasi: "Jl. Contoh No. 123",
            status: .pending,
            createdAt: "2023-01-01T00:00:00Z",
            updatedAt: "2023-01-01T00:00:00Z",
            kdLaporan: "LAP20230101001",
            isAnonymous: false,
            user: user,
            logStatus: []
        )
    }
}

struct LogStatus: Codable, Identifiable {
    let id: Int
    let laporanId: Int
    let status: StatusLaporan
    let userId: Int
    let waktu: String
    let tanggapan: String?
    let foto: String?
    let user: User
}

enum StatusLaporan: String, Codable, CaseIterable {
    case pending = "pending"
    case diproses = "diproses"
    case selesai = "selesai"
    case ditolak = "ditolak"

    var displayName: String {
        switch self {
        case .pending: return "Menunggu"
        case .diproses: return "Diproses"
        case .selesai: return "Selesai"
        case .ditolak: return "Ditolak"
        }
    }

    var color: String {
        switch self {
        case .pending: return "blue"
        case .diproses: return "orange"
        case .selesai: return "green"
        case .ditolak: return "red"
        }
    }

    var uiColor: Color {
        switch self {
        case .pending: return .blue
        case .diproses: return .orange
        case .selesai: return .green
        case .ditolak: return .red
        }
    }
}

enum KategoriLaporan: String, Codable, CaseIterable, Identifiable {
    var id: String { rawValue }

    case fasilitasUmum = "Fasilitas Umum"
    case jalanTransportasi = "Jalan & Transportasi"
    case sampahKebersihan = "Sampah & Kebersihan"
    case airDrainase = "Air & Drainase"
    case keamanan = "Keamanan"
    case kesehatan = "Kesehatan"
    case listrikPJU = "Listrik & PJU"
    case parkirLiar = "Parkir Liar"
    case bangunanLiar = "Bangunan Liar"
    case lingkunganSosial = "Lingkungan Sosial"
    case lainnya = "Lainnya"
}

struct LaporanListResponse: Codable {
    let message: String?
    let data: [Laporan]
}


