import Foundation
import SwiftUI
import Combine

final class AuthViewModel: ObservableObject {
    @Published var isAuthenticated = false
    @Published var currentUser: User?
    @Published var errorMessage: String?
    @Published var isLoading = false
    
    
    // kostan http://192.168.0.107:3000/api
    //kontrakan:http://192.168.100.12:3000/api

    public let baseURL = "http://192.168.0.107:3000/api"
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        checkAuth()
    }
    
    
    
    
    // MARK: - Implementation moved to extensions
    
    func setIsLoading(_ isLoading: Bool) {
        self.isLoading = isLoading
    }
    
    func setErrorMessage(_ message: String?) {
        self.errorMessage = message
    }
    
    func setCurrentUser(_ user: User?) {
        self.currentUser = user
    }
    
    
    
    // MARK: - Authentication
    
    func login(nik: String, password: String) {
        isLoading = true
        errorMessage = nil
        
        guard let url = URL(string: "\(baseURL)/auth/login") else {
            errorMessage = "Invalid URL"
            isLoading = false
            return
        }
        
        let loginData = ["nik": nik, "password": password]
        let jsonData = try? JSONEncoder().encode(loginData)
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                if let error = error {
                    self?.errorMessage = error.localizedDescription
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse,
                      (200...299).contains(httpResponse.statusCode) else {
                    self?.errorMessage = "Invalid credentials"
                    return
                }
                
                if let data = data {
                    do {
                        let response = try JSONDecoder().decode(LoginResponse.self, from: data)
                        self?.currentUser = response.user
                        self?.isAuthenticated = true
                        UserDefaults.standard.set(response.token, forKey: "authToken")
                    } catch {
                        self?.errorMessage = "Failed to decode response"
                    }
                }
            }
        }.resume()
    }
    
    
    
    func register(userData: [String: Any]) {
        isLoading = true
        errorMessage = nil
        
        guard let url = URL(string: "\(baseURL)/auth/register") else {
            errorMessage = "Invalid URL"
            isLoading = false
            return
        }
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: userData) else {
            errorMessage = "Invalid user data"
            isLoading = false
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                if let error = error {
                    self?.errorMessage = error.localizedDescription
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse,
                      (200...299).contains(httpResponse.statusCode) else {
                    self?.errorMessage = "Registration failed"
                    return
                }
                
                if let data = data {
                    do {
                        let response = try JSONDecoder().decode(LoginResponse.self, from: data)
                        self?.currentUser = response.user
                        self?.isAuthenticated = true
                        UserDefaults.standard.set(response.token, forKey: "authToken")
                    } catch {
                        self?.errorMessage = "Failed to decode response"
                    }
                }
            }
        }.resume()
    }
    
    func logout() {
        isAuthenticated = false
        currentUser = nil
        UserDefaults.standard.removeObject(forKey: "authToken")
    }
    
    func checkAuth() {
        if let _ = UserDefaults.standard.string(forKey: "authToken") {
            fetchUserProfile()
        }
    }
    
    func fetchUserProfile() {
        guard let token = UserDefaults.standard.string(forKey: "authToken"),
              let url = URL(string: "\(baseURL)/auth/profile") else {
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Profile fetch error:", error.localizedDescription)
                    self?.errorMessage = "Gagal mengambil profil"
                    self?.setIsLoading(false)
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    print("Invalid response")
                    self?.errorMessage = "Respon server tidak valid"
                    self?.setIsLoading(false)
                    return
                }
                
                switch httpResponse.statusCode {
                case 200...299:
                    if let data = data {
                        do {
                            let user = try JSONDecoder().decode(User.self, from: data)
                            self?.currentUser = user
                            self?.isAuthenticated = true
                            self?.setErrorMessage(nil)
                        } catch {
                            print("Failed to decode user:", error.localizedDescription)
                            self?.errorMessage = "Gagal memproses data profil"
                        }
                    }
                case 304:
                    print("Profile not modified")
                    // No need to update anything, data is still valid
                    self?.setErrorMessage(nil)
                default:
                    print("Unexpected status code:", httpResponse.statusCode)
                    self?.errorMessage = "Gagal mengambil profil"
                }
                
                self?.setIsLoading(false)
            }
        }.resume()
    }
    
    // Method untuk mengecek apakah user bisa mengupdate status laporan
    func currentUserCanUpdateStatus() -> Bool {
        guard let role = currentUser?.role.lowercased() else { return false }
        return ["admin", "rt", "rw"].contains(role)
    }
    
    struct ProfileUpdateResponse: Codable {
        let message: String
        let user: User

        enum CodingKeys: String, CodingKey {
            case message, user
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            message = try container.decode(String.self, forKey: .message)
            user = try container.decode(User.self, forKey: .user)
        }
    }
    
    // Method untuk mengupdate profil
    func updateProfile(
        name: String,
        address: String?,
        phone: String?,
        completion: @escaping (Bool, String) -> Void
    ) {
        self.isLoading = true
        self.errorMessage = nil
        
        guard let token = UserDefaults.standard.string(forKey: "authToken") else {
            self.isLoading = false
            completion(false, "Anda belum login")
            return
        }
        
        // Pastikan URL endpoint benar dengan /auth
        guard let url = URL(string: "\(baseURL)/auth/profile") else {
            self.isLoading = false
            completion(false, "URL tidak valid")
            return
        }
        
        // Siapkan data yang akan dikirim
        let profileData: [String: Any] = [
            "nama": name,
            "alamat": address ?? "",
            "no_hp": phone ?? ""
        ]
        
        // Encode data ke JSON
        guard let jsonData = try? JSONSerialization.data(withJSONObject: profileData) else {
            self.isLoading = false
            completion(false, "Gagal memproses data")
            return
        }
        
        // Buat request
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.httpBody = jsonData
        
        // Log request untuk debugging
        print("Sending request to:", url.absoluteString)
        print("Method:", request.httpMethod ?? "")
        print("Headers:", request.allHTTPHeaderFields ?? "")
        print("Body:", String(data: jsonData, encoding: .utf8) ?? "")
        
        // Kirim request
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.isLoading = false
                
                // Handle error jaringan
                if let error = error {
                    print("Network error:", error.localizedDescription)
                    completion(false, "Gagal terhubung ke server")
                    return
                }
                
                // Pastikan response adalah HTTPURLResponse
                guard let httpResponse = response as? HTTPURLResponse else {
                    print("Invalid response")
                    completion(false, "Respon server tidak valid")
                    return
                }
                
                // Cetak status code dan data response untuk debugging
                let responseData = data.flatMap { String(data: $0, encoding: .utf8) } ?? "No data"
                print("Response status code:", httpResponse.statusCode)
                print("Response data:", responseData)
                
                // Handle response berdasarkan status code
                switch httpResponse.statusCode {
                case 200...299:
                    // Jika sukses, update data user
                    if let data = data {
                        do {
                            let response = try JSONDecoder().decode(ProfileUpdateResponse.self, from: data)
                            self.currentUser = response.user
                            completion(true, response.message)
                        } catch {
                            print("Decoding error:", error)
                            completion(false, "Gagal memproses data profil")
                        }
                    } else {
                        completion(false, "Tidak ada data yang diterima")
                    }
                case 401:
                    completion(false, "Sesi telah berakhir, silakan login kembali")
                case 404:
                    completion(false, "Endpoint tidak ditemukan")
                default:
                    completion(false, "Terjadi kesalahan (Kode: \(httpResponse.statusCode))")
                }
            }
        }.resume()
    }
    
    // Method untuk mengubah password
    func changePassword(
        currentPassword: String,
        newPassword: String,
        completion: @escaping (Bool, String) -> Void
    ) {
        setIsLoading(true)
        setErrorMessage(nil)
        
        guard let token = UserDefaults.standard.string(forKey: "authToken") else {
            completion(false, "Anda belum login")
            self.setIsLoading(false)
            return
        }
        
        guard let url = URL(string: "\(self.baseURL)/auth/change-password") else {
            completion(false, "URL tidak valid")
            self.setIsLoading(false)
            return
        }
        
        let passwordData: [String: Any] = [
            "current_password": currentPassword,
            "new_password": newPassword,
            "confirm_password": newPassword
        ]
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: passwordData)
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            request.httpBody = jsonData
            
            URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    self.setIsLoading(false)
                    
                    if let error = error {
                        completion(false, error.localizedDescription)
                        return
                    }
                    
                    guard let httpResponse = response as? HTTPURLResponse else {
                        completion(false, "Respon server tidak valid")
                        return
                    }
                    
                    if (200...299).contains(httpResponse.statusCode) {
                        completion(true, "Password berhasil diubah")
                    } else {
                        // Parse error message from server if available
                        if let data = data {
                            do {
                                let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
                                if let message = json?["message"] as? String {
                                    completion(false, message)
                                    return
                                }
                            } catch {
                                print("Error parsing error response: \(error)")
                            }
                        }
                        completion(false, "Gagal mengubah password. Kode status: \(httpResponse.statusCode)")
                    }
                }
            }.resume()
            
        } catch {
            completion(false, "Gagal memproses data: \(error.localizedDescription)")
            self.setIsLoading(false)
        }
    }
}
