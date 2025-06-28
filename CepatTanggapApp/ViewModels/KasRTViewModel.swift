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

    func fetchKas() {
        isLoading = true
        errorMessage = nil
        
        guard let token = UserDefaults.standard.string(forKey: "authToken"),
              let url = URL(string: "http://localhost:3000/api/kas-bulanan") else {
            self.errorMessage = "Tidak ada token atau URL salah"
            self.isLoading = false
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                self.isLoading = false
                if let error = error {
                    self.errorMessage = error.localizedDescription
                    return
                }
                
                guard let data = data else {
                    self.errorMessage = "Data tidak ditemukan"
                    return
                }

                do {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    
                    let response = try decoder.decode(KasResponse.self, from: data)
                    self.kasList = response.data
                } catch {
                    self.errorMessage = "Gagal decode data: \(error.localizedDescription)"
                }
                
            }
        }.resume()
    }
}

struct KasResponse: Decodable {
    let success: Bool
    let data: [KasBulanan]
}
