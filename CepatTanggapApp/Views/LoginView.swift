import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var nik = ""
    @State private var password = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Header
                VStack(spacing: 10) {
                    Image(systemName: "exclamationmark.bubble.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.blue)
                    
                    Text("Cepat Tanggap")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Aplikasi Laporan Masyarakat")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                .padding(.top, 40)
                .padding(.bottom, 40)
                
                // Form
                VStack(spacing: 16) {
                    TextField("NIK", text: $nik)
                        .keyboardType(.numberPad)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .disableAutocorrection(true)
                        .autocapitalization(.none)
                    
                    SecureField("Password", text: $password)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    if let error = authViewModel.errorMessage {
                        Text(error)
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                    
                    Button(action: login) {
                        if authViewModel.isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Text("Login")
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .buttonStyle(PrimaryButtonStyle())
                    .disabled(nik.isEmpty || password.isEmpty || authViewModel.isLoading)
                }
                .padding(.horizontal)
                
                Spacer()
                
                // Footer
                VStack(spacing: 4) {
                    Text(" 2025 Cepat Tanggap")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text("Versi 1.0.0")
                        .font(.caption2)
                        .foregroundColor(.gray)
                }
                .padding(.bottom, 20)
            }
            .onAppear {
                // Check if user is already logged in
                authViewModel.checkAuth()
            }
            .navigationBarHidden(true)
        }
    }
    
    private func login() {
        authViewModel.login(nik: nik, password: password)
    }
}

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
            .opacity(configuration.isPressed ? 0.8 : 1.0)
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
            .environmentObject(AuthViewModel())
    }
}
