import SwiftUI

struct EditProfileView: View {
    // MARK: - Environment
    @Environment(\.presentationMode) private var presentationMode
    @EnvironmentObject private var authViewModel: AuthViewModel
    
    // MARK: - State
    @State private var phoneNumber = ""
    @State private var address = ""
    @State private var rt = ""
    @State private var rw = ""
    @State private var currentPassword = ""
    @State private var newPassword = ""
    @State private var confirmPassword = ""
    @State private var isEditingPassword = false
    @State private var showPassword = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    
    // MARK: - Computed Properties
    private var currentUser: User? { authViewModel.currentUser }
    
    private var isPasswordFormValid: Bool {
        !currentPassword.isEmpty &&
        !newPassword.isEmpty &&
        !confirmPassword.isEmpty &&
        newPassword == confirmPassword &&
        newPassword.count >= 6
    }
    
    // MARK: - Main View
    var body: some View {
        Form {
            Section(header: Text("Informasi Akun")) {
                if let user = currentUser {
                    HStack {
                        Text("Nama")
                        Spacer()
                        Text(user.nama)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("NIK")
                        Spacer()
                        Text(user.nik ?? "-")
                            .foregroundColor(.secondary)
                    }
                    
                    if let email = user.email, !email.isEmpty {
                        HStack {
                            Text("Email")
                            Spacer()
                            Text(email)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    HStack {
                        Text("Role")
                        Spacer()
                        Text(user.role.capitalized)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("No. HP")
                        Spacer()
                        TextField("", text: $phoneNumber)
                            .multilineTextAlignment(.trailing)
                            .keyboardType(.phonePad)
                    }
                    
                    HStack {
                        Text("Alamat")
                        Spacer()
                        TextField("", text: $address)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    HStack {
                        Text("RT")
                        Spacer()
                        TextField("Contoh: 001", text: $rt)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    HStack {
                        Text("RW")
                        Spacer()
                        TextField("Contoh: 001", text: $rw)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    Button("Simpan Perubahan") {
                        print("EditProfileView: Tombol Simpan Perubahan ditekan")
                        if !authViewModel.isLoading {
                            updateProfile()
                        } else {
                            print("EditProfileView: Permintaan update sedang diproses, abaikan klik ganda")
                        }
                    }
                    .disabled(phoneNumber.isEmpty || authViewModel.isLoading)
                    .foregroundColor(phoneNumber.isEmpty ? .gray : .blue)
                }
            }
            
            Section(header: Text("Ubah Password")) {
                NavigationLink {
                    PasswordChangeView()
                        .environmentObject(authViewModel)
                } label: {
                    Label("Ubah Password", systemImage: "key.fill")
                }
            }
        }
        .navigationTitle("Edit Profil")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            if let user = currentUser {
                phoneNumber = user.noHp ?? ""
                address = user.alamat ?? ""
                rt = user.rt ?? ""
                rw = user.rw ?? ""
            }
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text(alertMessage.contains("berhasil") ? "Sukses" : "Peringatan"),
                message: Text(alertMessage),
                dismissButton: .default(Text("OK")) {
                    if alertMessage.contains("berhasil") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            )
        }
        .overlay {
            if authViewModel.isLoading {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                ProgressView()
                    .scaleEffect(1.5)
            }
        }
    }
    
    // MARK: - Private Methods
    private func updateProfile() {
        print("EditProfileView: updateProfile() dipanggil")
        guard let user = authViewModel.currentUser else {
            showAlert(message: "Tidak dapat menemukan data pengguna")
            return
        }
        
        // Validasi RT dan RW jika diisi
        if !rt.isEmpty && (Int(rt) == nil || rt.count > 3) {
            showAlert(message: "RT harus berupa angka maksimal 3 digit")
            return
        }
        
        if !rw.isEmpty && (Int(rw) == nil || rw.count > 3) {
            showAlert(message: "RW harus berupa angka maksimal 3 digit")
            return
        }
        
        authViewModel.updateProfile(
            name: user.nama, 
            address: address, 
            phone: phoneNumber,
            rt: rt.isEmpty ? nil : rt,
            rw: rw.isEmpty ? nil : rw
        ) { success, message in
            DispatchQueue.main.async {
                print("EditProfileView: Callback updateProfile selesai, success: \(success), message: \(message)")
                self.alertMessage = message
                self.showAlert = true
                if success {
                    authViewModel.fetchUserProfile()
                }
            }
        }
    }
    
    private func updatePassword() {
        guard isPasswordFormValid else {
            showAlert(message: "Mohon isi semua field dengan benar, pastikan password baru cocok dengan konfirmasi, dan minimal 6 karakter.")
            return
        }
        
        authViewModel.changePassword(currentPassword: currentPassword, 
                                  newPassword: newPassword) { success, message in
            DispatchQueue.main.async {
                self.alertMessage = message
                self.showAlert = true
                if success {
                    self.isEditingPassword = false
                    self.resetPasswordFields()
                }
            }
        }
    }
    
    private func resetPasswordFields() {
        currentPassword = ""
        newPassword = ""
        confirmPassword = ""
    }
    
    private func showAlert(message: String) {
        alertMessage = message
        showAlert = true
    }
}

// MARK: - Preview
#if DEBUG
struct EditProfileView_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = AuthViewModel()
        viewModel.currentUser = User(
            id: 1,
            nik: "1234567890123456",
            nama: "John Doe",
            role: "warga",
            alamat: "Jl. Contoh No. 123",
            noHp: "081234567890",
            rt: "001",
            rw: "001"
        )
        
        return NavigationView {
            EditProfileView()
                .environmentObject(AuthViewModel())
        }
    }
}
#endif
