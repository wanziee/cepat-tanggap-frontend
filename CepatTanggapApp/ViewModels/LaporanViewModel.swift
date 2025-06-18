import Foundation
import SwiftUI
import Combine

class LaporanViewModel: ObservableObject {
    @Published var laporanList: [Laporan] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var selectedStatus: StatusLaporan?
    @Published var currentLaporan: Laporan?
    var laporanId: Int?
    var filterUserId: Int?
    var fetchAll = false
    
    private let baseURL = "http://localhost:3000/api"
    
    // MARK: - Fetch Laporan
    
    func fetchLaporan() {
        isLoading = true
        errorMessage = nil
        
        var urlString = fetchAll ? "\(baseURL)/laporan/all" : "\(baseURL)/laporan"
        if let status = selectedStatus {
            urlString += "?status=\(status.rawValue)"
        }
        
        guard let url = URL(string: urlString) else {
            errorMessage = "Invalid URL"
            isLoading = false
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        if !fetchAll {
            // Hanya tambahkan token jika bukan fetchAll
            guard let token = UserDefaults.standard.string(forKey: "authToken") else {
                errorMessage = "Not authenticated"
                isLoading = false
                return
            }
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                if let error = error {
                    self?.errorMessage = error.localizedDescription
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse,
                      (200...299).contains(httpResponse.statusCode) || httpResponse.statusCode == 304 else {
                    self?.errorMessage = "Failed to fetch laporan"
                    return
                }
                
                // For 304 Not Modified, keep existing data
                if httpResponse.statusCode == 304 {
                    return
                }
                
                if let data = data {
                    do {
                        let decoder = JSONDecoder()
                        decoder.keyDecodingStrategy = .convertFromSnakeCase
                        decoder.dateDecodingStrategy = .iso8601
                        let response = try decoder.decode(LaporanListResponse.self, from: data)
                        let list = response.data
                        self?.laporanList = list
                    } catch {
                        if let raw = String(data: data, encoding: .utf8) {
                            print("Raw JSON:\n", raw)
                        }
                        self?.errorMessage = "Failed to decode laporan"
                        print("Decoding error:", error)
                    }
                }
            }
        }.resume()
    }
    
    // MARK: - Create Laporan
    
    func createLaporan(judul: String, deskripsi: String, lokasi: String?, image: UIImage?, completion: @escaping (Bool) -> Void) {
        isLoading = true
        errorMessage = nil
        
        guard let url = URL(string: "\(baseURL)/laporan"),
              let token = UserDefaults.standard.string(forKey: "authToken") else {
            errorMessage = "Invalid URL or not authenticated"
            isLoading = false
            completion(false)
            return
        }
        
        let boundary = UUID().uuidString
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var body = Data()
        
        // Add text fields
        let textParams: [String: String] = [
            "judul": judul,
            "deskripsi": deskripsi,
            "lokasi": lokasi ?? ""
        ]
        
        for (key, value) in textParams {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".data(using: .utf8)!)
            body.append("\(value)\r\n".data(using: .utf8)!)
        }
        
        // Add image if exists
        if let image = image, let imageData = image.jpegData(compressionQuality: 0.8) {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"foto\"; filename=\"laporan.jpg\"\r\n".data(using: .utf8)!)
            body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
            body.append(imageData)
            body.append("\r\n".data(using: .utf8)!)
        }
        
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        request.httpBody = body
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                if let error = error {
                    self?.errorMessage = error.localizedDescription
                    completion(false)
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse,
                      (200...299).contains(httpResponse.statusCode) else {
                    self?.errorMessage = "Failed to create laporan"
                    completion(false)
                    return
                }
                
                completion(true)
                self?.fetchLaporan()
            }
        }.resume()
    }
    
    // MARK: - Update Status Laporan
    
    func updateStatus(laporanId: Int, status: StatusLaporan, completion: @escaping (Bool) -> Void) {
        isLoading = true
        errorMessage = nil
        
        guard let url = URL(string: "\(baseURL)/laporan/\(laporanId)/status"),
              let token = UserDefaults.standard.string(forKey: "authToken") else {
            errorMessage = "Invalid URL or not authenticated"
            isLoading = false
            completion(false)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let body: [String: String] = ["status": status.rawValue]
        request.httpBody = try? JSONEncoder().encode(body)
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                if let error = error {
                    self?.errorMessage = error.localizedDescription
                    completion(false)
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse,
                      (200...299).contains(httpResponse.statusCode) else {
                    self?.errorMessage = "Failed to update status"
                    completion(false)
                    return
                }
                
                completion(true)
                self?.fetchLaporan()
            }
        }.resume()
    }
    
    // MARK: - Delete Laporan
    
    func deleteLaporan(laporanId: Int, completion: @escaping (Bool) -> Void) {
        isLoading = true
        errorMessage = nil
        
        guard let url = URL(string: "\(baseURL)/laporan/\(laporanId)"),
              let token = UserDefaults.standard.string(forKey: "authToken") else {
            errorMessage = "Invalid URL or not authenticated"
            isLoading = false
            completion(false)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                if let error = error {
                    self?.errorMessage = error.localizedDescription
                    completion(false)
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse,
                      (200...299).contains(httpResponse.statusCode) else {
                    self?.errorMessage = "Failed to delete laporan"
                    completion(false)
                    return
                }
                
                completion(true)
                self?.fetchLaporan()
            }
        }.resume()
    }
    
    // MARK: - Check if current user can update status
    
    func currentUserCanUpdateStatus() -> Bool {
        guard let token = UserDefaults.standard.string(forKey: "authToken") else {
            return false
        }
        
        // Decode the token to get user role
        let parts = token.components(separatedBy: ".")
        guard parts.count > 1, 
              let payloadData = Data(base64Encoded: parts[1]),
              let payload = try? JSONSerialization.jsonObject(with: payloadData, options: []) as? [String: Any],
              let role = payload["role"] as? String else {
            return false
        }
        
        return ["admin", "rt", "rw"].contains(role.lowercased())
    }
}
