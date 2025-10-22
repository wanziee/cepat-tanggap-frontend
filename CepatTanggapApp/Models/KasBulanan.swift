import Foundation

struct KasBulanan: Identifiable, Decodable {
    let id: Int
    let filename: String
    let filepath: String
    let description: String?
    let relatedRt: String?
    let relatedRw: String?
    let uploadDate: String?
    
    // Tidak perlu init manual jika property name cocok
    
    var bulanFormatted: String {
        guard let uploadDate = uploadDate else { return "-" }

        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        let outputFormatter = DateFormatter()
        outputFormatter.locale = Locale(identifier: "id_ID")
        outputFormatter.dateFormat = "MMMM yyyy"

        if let date = isoFormatter.date(from: uploadDate) {
            return outputFormatter.string(from: date).capitalized
        } else {
            return uploadDate // fallback kalau gagal parse
        }
    }


    var fileUrl: URL? {
        guard !filepath.isEmpty,
              let baseURL = URL(string: "http://192.168.43.191:3000/uploads/") else {
            return nil
        }

        let cleanPath = filepath.hasPrefix("/") ? String(filepath.dropFirst()) : filepath
        return baseURL.appendingPathComponent(cleanPath)
    }
}

