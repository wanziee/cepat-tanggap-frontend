//
//  KasRTViewModel.swift
//  CepatTanggapApp
//
//  Created by mohammad ichwan al ghifari on 29/06/25.
//

import Foundation
import SwiftUI

class KasRTViewModel: ObservableObject {
    @Published var kasList: [KasBulanan] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // Konfigurasi URL
    private let baseURL = "http://localhost:3000" // Ganti dengan IP komputer Anda
    private let kasBulananEndpoint = "/api/kas-bulanan"
    
    func fetchKas() {
        isLoading = true
        errorMessage = nil
        
        guard let token = UserDefaults.standard.string(forKey: "authToken") else {
            self.errorMessage = "Sesi login telah berakhir. Silakan login kembali."
            self.isLoading = false
            return
        }
        
        guard let url = URL(string: baseURL + kasBulananEndpoint) else {
            self.errorMessage = "URL tidak valid"
            self.isLoading = false
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.timeoutInterval = 30 // Timeout 30 detik
        
        print("Mengirim request ke: \(url.absoluteString)")
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.isLoading = false
                
                // Handle error koneksi
                if let error = error {
                    self.errorMessage = "Kesalahan koneksi: \(error.localizedDescription)"
                    print("Error: \(error.localizedDescription)")
                    return
                }
                
                // Handle response tidak valid
                guard let httpResponse = response as? HTTPURLResponse else {
                    self.errorMessage = "Respon server tidak valid"
                    return
                }
                
                // Handle error HTTP
                guard (200...299).contains(httpResponse.statusCode) else {
                    if httpResponse.statusCode == 403 {
                        // Token tidak valid atau tidak memiliki akses
                        self.errorMessage = "Akses ditolak. Pastikan Anda memiliki izin yang cukup."
                        
                        // Clear token jika unauthorized
                        UserDefaults.standard.removeObject(forKey: "authToken")
                        UserDefaults.standard.synchronize()
                        
                        // Redirect ke halaman login atau refresh token
                        NotificationCenter.default.post(name: NSNotification.Name("UserLoggedOut"), object: nil)
                    } else {
                        self.errorMessage = "Kesalahan server (Kode: \(httpResponse.statusCode))"
                    }
                    
                    // Log response body untuk debugging
                    if let data = data, let responseString = String(data: data, encoding: .utf8) {
                        print("Error response: \(responseString)")
                    }
                    
                    return
                }
                
                // Handle data kosong
                guard let data = data else {
                    self.errorMessage = "Tidak ada data yang diterima"
                    return
                }
                
                // Debug: Cetak response string
                if let responseString = String(data: data, encoding: .utf8) {
                    print("Response: \(responseString)")
                }
                
                // Decode data
                do {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    
                    let response = try decoder.decode(KasResponse.self, from: data)
                    
                    if response.success {
                        self.kasList = response.data
                        self.errorMessage = nil
                    } else {
                        self.errorMessage = "Gagal memuat data kas"
                    }
                } catch let DecodingError.dataCorrupted(context) {
                    self.handleDecodingError(context: context, error: error!)
                } catch let DecodingError.keyNotFound(key, context) {
                    self.handleDecodingError(context: context, error: error!, key: key.stringValue)
                } catch let DecodingError.valueNotFound(value, context) {
                    self.handleDecodingError(context: context, error: error!, value: String(describing: value))
                } catch let DecodingError.typeMismatch(type, context) {
                    self.handleDecodingError(context: context, error: error!, type: String(describing: type))
                } catch {
                    self.errorMessage = "Terjadi kesalahan: \(error.localizedDescription)"
                    print("Decoding error: \(error)")
                }
            }
        }.resume()
    }
    
    private func handleDecodingError(context: DecodingError.Context, error: Error, key: String? = nil, value: String? = nil, type: String? = nil) {
        var errorMessage = "Gagal memproses data: "
        
        if let key = key {
            errorMessage += "\n- Field tidak ditemukan: \(key)"
        }
        
        if let value = value {
            errorMessage += "\n- Nilai tidak valid: \(value)"
        }
        
        if let type = type {
            errorMessage += "\n- Tipe data tidak sesuai: \(type)"
        }
        
        errorMessage += "\n\nDetail teknis: \(context.debugDescription)"
        
        self.errorMessage = errorMessage
        print("Decoding error: \(error)")
        print("Coding path: \(context.codingPath)")
    }
}

struct KasResponse: Decodable {
    let success: Bool
    let data: [KasBulanan]
    let message: String?
}
