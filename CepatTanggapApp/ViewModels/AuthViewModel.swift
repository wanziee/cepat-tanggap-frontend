import Foundation
import SwiftUI
import Combine

final class AuthViewModel: ObservableObject {
//    @Published var isAuthenticated = false
//    @Published var isCheckingAuth = true
    @AppStorage("authToken") private var authToken: String?
    @Published var isAuthenticated = false
    @Published var isCheckingAuth = true


    @Published var currentUser: User?
    @Published var errorMessage: String?
    @Published var isLoading = false
    
    
    // kostan http://192.168.0.107:3000/api
    //kontrakan:http://192.168.100.12:3000/api
    
    public let baseURL = "http://localhost:3000/api"
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
                errorMessage = "Gagal terhubung ke server. Periksa koneksi internet Anda."
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
                        self?.errorMessage = "Gagal terhubung ke server: \(error.localizedDescription)"
                        return
                    }
                    
                    guard let httpResponse = response as? HTTPURLResponse else {
                        self?.errorMessage = "Gagal mendapatkan respons dari server"
                        return
                    }
                    
                    if (200...299).contains(httpResponse.statusCode) {
                        if let data = data {
                            do {
                                let response = try JSONDecoder().decode(LoginResponse.self, from: data)
                                self?.currentUser = response.user
                                self?.isAuthenticated = true
                                UserDefaults.standard.set(response.token, forKey: "authToken")
                            } catch {
                                self?.errorMessage = "Gagal memproses data login"
                            }
                        }
                    } else {
                        // Handle error responses
                        if let data = data,
                           let errorResponse = try? JSONDecoder().decode([String: String].self, from: data),
                           let message = errorResponse["message"] {
                            self?.errorMessage = message
                        } else if httpResponse.statusCode == 401 {
                            self?.errorMessage = "NIK atau password salah"
                        } else if httpResponse.statusCode == 400 {
                            self?.errorMessage = "NIK dan password harus diisi"
                        } else {
                            self?.errorMessage = "Terjadi kesalahan. Kode: \(httpResponse.statusCode)"
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
        isCheckingAuth = true
        
        if let _ = authToken {
            fetchUserProfile()
        } else {
            isAuthenticated = false
            isCheckingAuth = false
        }
    }



    func fetchUserProfile() {
        guard let token = UserDefaults.standard.string(forKey: "authToken"),
              let url = URL(string: "\(baseURL)/auth/profile") else {
            // Tambahkan ini agar SplashView tidak stuck jika URL tidak valid

            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                defer { self?.isCheckingAuth = false }


                if let error = error {
                    self?.errorMessage = error.localizedDescription
                    self?.isAuthenticated = false
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse,
                      (200...299).contains(httpResponse.statusCode),
                      let data = data else {
                    self?.isAuthenticated = false
                    return
                }

                do {
                    let decoder = JSONDecoder()
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
                    decoder.dateDecodingStrategy = .formatted(dateFormatter)
                    
                    let response = try decoder.decode(User.self, from: data)
                    self?.currentUser = response
                    self?.isAuthenticated = true
                } catch {
                    self?.isAuthenticated = false
                    self?.errorMessage = "Gagal decode profil: \(error.localizedDescription)"
                }
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
        let data: User?
        
        enum CodingKeys: String, CodingKey {
            case message, user, data
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            message = try container.decode(String.self, forKey: .message)
            
            // Coba decode user dari root terlebih dahulu (untuk kompatibilitas ke belakang)
            if let user = try? container.decodeIfPresent(User.self, forKey: .user) {
                self.user = user
            }
            // Jika tidak ada di root, coba ambil dari data.user
            else if let data = try? container.nestedContainer(keyedBy: CodingKeys.self, forKey: .data),
                    let user = try? data.decodeIfPresent(User.self, forKey: .user) {
                self.user = user
            }
            // Jika masih tidak ada, gunakan nilai default
            else {
                throw DecodingError.dataCorruptedError(forKey: .user, in: container, debugDescription: "User data is missing or corrupted")
            }
            
            // Decode data jika ada
            self.data = try container.decodeIfPresent(User.self, forKey: .data)
        }
        
        // Jika perlu encode juga
        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(message, forKey: .message)
            try container.encode(user, forKey: .user)
            try container.encodeIfPresent(data, forKey: .data)
        }
    }
    
    // Method untuk mengupdate profil
    func updateProfile(
        name: String,
        address: String?,
        phone: String?,
        email: String?,
//        rt: String? = nil,
//        rw: String? = nil,
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
            "no_hp": phone ?? "",
            "email": email ?? ""
        ]
        
//        // Tambahkan RT dan RW jika ada
//        if let rt = rt, !rt.isEmpty {
//            profileData["rt"] = rt
//        }
//        
//        if let rw = rw, !rw.isEmpty {
//            profileData["rw"] = rw
//        }
//        
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
//        print("RT value being sent:", rt ?? "nil")
//        print("RW value being sent:", rw ?? "nil")
        
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
                guard let data = data else {
                    completion(false, "Tidak ada data yang diterima dari server")
                    return
                }
                
                // Cetak respons untuk debugging
                if let responseString = String(data: data, encoding: .utf8) {
                    print("Raw response:", responseString)
                }
                
                do {
                    let decoder = JSONDecoder()
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
                    decoder.dateDecodingStrategy = .formatted(dateFormatter)
                    
                    let response = try decoder.decode(ProfileUpdateResponse.self, from: data)
                    
                    // Update current user dengan data terbaru
                    DispatchQueue.main.async {
                        self.currentUser = response.user
                        self.isAuthenticated = true
                        completion(true, response.message)
                    }
                } catch {
                    print("Decoding error:", error)
                    
                    // Coba parse pesan error dari server
                    if let errorResponse = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                       let message = errorResponse["message"] as? String {
                        completion(false, message)
                    } else {
                        completion(false, "Gagal memproses data profil: \(error.localizedDescription)")
                    }
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

