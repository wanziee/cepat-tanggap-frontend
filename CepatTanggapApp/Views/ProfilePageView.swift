import SwiftUI

struct ProfileInfoRow: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .frame(width: 24)
                .foregroundColor(.blue)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(value)
                    .foregroundColor(.primary)
            }
        }
        .padding(.vertical, 4)
    }
}

struct ProfilePageView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var isShowingEditProfile = false
    @State private var isRefreshing = false
    
    private func loadUserProfile() {
        guard let token = UserDefaults.standard.string(forKey: "authToken") else { return }
        
        isRefreshing = true
        
        guard let url = URL(string: "\(authViewModel.baseURL)/auth/profile") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                isRefreshing = false
                
                if let error = error {
                    print("Error fetching profile:", error.localizedDescription)
                    return
                }
                
                guard let data = data else {
                    print("No data received")
                    return
                }
                
                do {
                    // Cetak respons JSON mentah
                    if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                        print("Raw JSON response:", json)
                    }
                    
                    // Coba decode ke Dictionary dulu untuk inspeksi
                    if let jsonDict = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                        print("Decoded dictionary:", jsonDict)
                        if let noHp = jsonDict["no_hp"] {
                            print("no_hp in response:", noHp)
                        } else {
                            print("no_hp is missing in response")
                            print("All keys in response:", jsonDict.keys)
                        }
                    }
                    
                    // Decode ke model User
                    let user = try JSONDecoder().decode(User.self, from: data)
                    print("Decoded user:", user)
                    print("User noHp:", user.noHp ?? "nil")
                    authViewModel.currentUser = user
                } catch {
                    print("Error decoding user:", error)
                    if let jsonString = String(data: data, encoding: .utf8) {
                        print("Response JSON:", jsonString)
                    }
                }
            }
        }.resume()
    }

    
    var body: some View {
        let _ = print("Current user in ProfilePageView: \(String(describing: authViewModel.currentUser))")
        
        NavigationView {
            List {
                if let user = authViewModel.currentUser {
                    Section {
                        HStack {
                            Spacer()
                            VStack(spacing: 8) {
                                Image(systemName: "person.circle.fill")
                                    .resizable()
                                    .frame(width: 80, height: 80)
                                    .foregroundColor(.blue)
                                
                                Text(user.nama)
                                    .font(.title3)
                                    .fontWeight(.medium)
                                
                                Text(user.role.capitalized)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            .padding(.vertical, 16)
                            Spacer()
                        }
                    }
                    .listRowBackground(Color(.systemGroupedBackground))
                    
                    Section(header: Text("Informasi Akun")) {
                        ProfileInfoRow(icon: "person.fill", title: "NIK", value: user.nik ?? "-")
                        ProfileInfoRow(icon: "phone.fill", title: "No. HP", value: user.noHp ?? "-")
                        ProfileInfoRow(icon: "mappin.and.ellipse", title: "Alamat", value: user.alamat ?? "-")
                    }
                }
                
                Section {
                    NavigationLink {
                        EditProfileView()
                            .environmentObject(authViewModel)
                    } label: {
                        Label("Edit Profil", systemImage: "pencil")
                    }
                    
                    Button(action: {
                        authViewModel.logout()
                    }) {
                        Label("Logout", systemImage: "rectangle.portrait.and.arrow.right")
                            .foregroundColor(.red)
                    }
                }
            }
            .navigationTitle("Profil")
            .refreshable {
                loadUserProfile()
            }
            .onAppear {
                loadUserProfile()
            }
            .sheet(isPresented: $isShowingEditProfile) {
                NavigationView {
                    EditProfileView()
                        .environmentObject(authViewModel)
                }
            }

        }
    }
}



#Preview {
    let viewModel = AuthViewModel()
    viewModel.currentUser = User(
        id: 1,
        nik: "1234567890123456",
        nama: "John Doe",
        role: "warga",
        alamat: "Jl. Contoh No. 123",
        noHp: "081234567890"
    )
    
    return ProfilePageView()
        .environmentObject(viewModel)
}
