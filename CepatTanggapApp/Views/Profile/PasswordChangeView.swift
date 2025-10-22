import SwiftUI

struct PasswordChangeView: View {
    @Environment(\.presentationMode) private var presentationMode
    @EnvironmentObject private var authViewModel: AuthViewModel
    
    @State private var currentPassword = ""
    @State private var newPassword = ""
    @State private var confirmPassword = ""
    
    @State private var showCurrentPassword = false
    @State private var showNewPassword = false
    @State private var showConfirmPassword = false
    
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    private var isFormValid: Bool {
        !currentPassword.isEmpty &&
        !newPassword.isEmpty &&
        !confirmPassword.isEmpty &&
        newPassword == confirmPassword &&
        newPassword.count >= 6
    }
    
    private func changePassword() {
        guard isFormValid else {
            showAlert(message: "Mohon isi semua field dengan benar, pastikan password baru cocok dengan konfirmasi, dan minimal 6 karakter.")
            return
        }
        
        authViewModel.changePassword(currentPassword: currentPassword, newPassword: newPassword) { success, message in
            DispatchQueue.main.async {
                self.alertMessage = message
                self.showAlert = true
                if success {
                    resetFields()
                }
            }
        }
    }
    
    private func resetFields() {
        currentPassword = ""
        newPassword = ""
        confirmPassword = ""
        showCurrentPassword = false
        showNewPassword = false
        showConfirmPassword = false
    }
    
    private func dismiss() {
        presentationMode.wrappedValue.dismiss()
    }
    
    private func showAlert(message: String) {
        alertMessage = message
        showAlert = true
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    // Section untuk form
                    VStack(spacing: 16) {
                        PasswordField(
                            title: "Password Saat Ini",
                            text: $currentPassword,
                            isSecure: !showCurrentPassword,
                            toggleSecure: { showCurrentPassword.toggle() },
                            isVisible: showCurrentPassword
                        )
                        
                        PasswordField(
                            title: "Password Baru",
                            text: $newPassword,
                            isSecure: !showNewPassword,
                            toggleSecure: { showNewPassword.toggle() },
                            isVisible: showNewPassword
                        )
                        
                        PasswordField(
                            title: "Konfirmasi Password",
                            text: $confirmPassword,
                            isSecure: !showConfirmPassword,
                            toggleSecure: { showConfirmPassword.toggle() },
                            isVisible: showConfirmPassword
                        )
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(15)
                    .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                    .padding(.top)
                    
                    // Tombol
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
                    .background(isFormValid ? Color.accentColor : Color.gray)
                    .cornerRadius(10)
                }
                .padding()
                .navigationTitle("Ubah Password")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Batal") {
                            dismiss()
                        }
                        .foregroundColor(.blue)
                    }
                }
            }
            .background(Color(UIColor.secondarySystemBackground).ignoresSafeArea())
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
        }
    }
}

// Reusable Password Field sesuai tampilan NewLaporanView
struct PasswordField: View {
    let title: String
    @Binding var text: String
    let isSecure: Bool
    let toggleSecure: () -> Void
    let isVisible: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .foregroundColor(.black)
                .font(.subheadline)
            
            ZStack(alignment: .trailing) {
                Group {
                    if isSecure {
                        SecureField(title, text: $text)
                    } else {
                        TextField(title, text: $text)
                    }
                }
                .padding(.trailing, 36)
                .padding(10)
                .background(Color("secondWhiteForm"))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color("borderForm"), lineWidth: 0.5)
                )
                .cornerRadius(10)
                
                Button(action: toggleSecure) {
                    Image(systemName: isVisible ? "eye.slash" : "eye")
                        .foregroundColor(.gray)
                        .padding(.trailing, 12)
                }
            }
        }
    }
}
