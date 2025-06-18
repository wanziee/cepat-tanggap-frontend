import SwiftUI

struct PasswordChangeView: View {
    // MARK: - Environment
    @Environment(\.presentationMode) private var presentationMode
    @EnvironmentObject private var authViewModel: AuthViewModel
    
    // MARK: - State
    @State private var currentPassword = ""
    @State private var newPassword = ""
    @State private var confirmPassword = ""
    @State private var showPassword = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    // MARK: - Computed Properties
    private var isFormValid: Bool {
        !currentPassword.isEmpty &&
        !newPassword.isEmpty &&
        !confirmPassword.isEmpty &&
        newPassword == confirmPassword &&
        newPassword.count >= 6
    }
    
    // MARK: - Methods
    private func changePassword() {
        guard isFormValid else {
            showAlert(message: "Mohon isi semua field dengan benar, pastikan password baru cocok dengan konfirmasi, dan minimal 6 karakter.")
            return
        }
        
        authViewModel.changePassword(
            currentPassword: currentPassword,
            newPassword: newPassword
        ) { success, message in
            DispatchQueue.main.async {
                self.alertMessage = message
                self.showAlert = true
                
                if success {
                    self.resetFields()
                    self.dismiss()
                }
            }
        }
    }
    
    private func resetFields() {
        currentPassword = ""
        newPassword = ""
        confirmPassword = ""
        showPassword = false
    }
    
    private func dismiss() {
        presentationMode.wrappedValue.dismiss()
    }
    
    private func showAlert(message: String) {
        alertMessage = message
        showAlert = true
    }
    
    // MARK: - Body
    var body: some View {
        Form {
            Section(header: Text("Ubah Password")) {
                SecureField("Password Saat Ini", text: $currentPassword)
                    .textContentType(.password)
                    .autocorrectionDisabled()
                    .autocapitalization(.none)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                if showPassword {
                    TextField("Password Baru", text: $newPassword)
                        .textContentType(.newPassword)
                        .autocorrectionDisabled()
                        .autocapitalization(.none)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    TextField("Konfirmasi Password", text: $confirmPassword)
                        .textContentType(.newPassword)
                        .autocorrectionDisabled()
                        .autocapitalization(.none)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                } else {
                    SecureField("Password Baru", text: $newPassword)
                        .textContentType(.newPassword)
                        .autocorrectionDisabled()
                        .autocapitalization(.none)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    SecureField("Konfirmasi Password", text: $confirmPassword)
                        .textContentType(.newPassword)
                        .autocorrectionDisabled()
                        .autocapitalization(.none)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                
                Toggle("Tampilkan Password", isOn: $showPassword)
                    .tint(.blue)
            }
            
            Section {
                Button(action: changePassword) {
                    HStack {
                        Spacer()
                        Text(authViewModel.isLoading ? "Memproses..." : "Ubah Password")
                            .font(.headline)
                            .foregroundColor(.white)
                        Spacer()
                    }
                }
                .disabled(!isFormValid || authViewModel.isLoading)
                .frame(maxWidth: .infinity)
                .padding()
                .background(isFormValid ? Color.blue : Color.gray)
                .cornerRadius(10)
                .padding(.vertical, 8)
            }
        }
        .navigationTitle("Ubah Password")
        .navigationBarItems(
            trailing: Button("Batal") {
                dismiss()
            }
            .foregroundColor(.blue)
        )
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Pesan"),
                message: Text(alertMessage),
                dismissButton: .default(Text("OK")) {
                    if alertMessage.contains("berhasil") {
                        dismiss()
                    }
                }
            )
        }
        .padding()
    }
}

// MARK: - Preview
struct PasswordChangeView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            PasswordChangeView()
                .environmentObject(AuthViewModel())
        }
    }
}
