import Foundation

struct KasBulanan: Identifiable, Decodable {
    let id: Int
    let filename: String
    let filepath: String
    let relatedRt: String?
    let relatedRw: String?
    let uploadDate: String? // Ganti dari Date ke String
    // Bisa juga pakai Date? jika yakin nilainya pasti ISO

    var bulanFormatted: String {
        guard let uploadDate = uploadDate else { return "-" }

        let formatter = ISO8601DateFormatter()
        if let date = formatter.date(from: uploadDate) {
            let output = DateFormatter()
            output.locale = Locale(identifier: "id_ID")
            output.dateFormat = "MMMM yyyy"
            return output.string(from: date)
        }
        return "-"
    }

    var fileUrl: URL? {
        guard let baseURL = URL(string: "http://localhost:3000/uploads/") else { return nil }
        return baseURL.appendingPathComponent(filepath)
    }
}
