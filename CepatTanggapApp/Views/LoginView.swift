import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var nik = ""
    @State private var password = ""
    @State private var isPasswordVisible = false

    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Header
                VStack(spacing: 10) {
                    Image("logo")
                        .resizable()
                        .frame(width: 70, height: 70)
                        .padding(30)
                        .background(Color("AccentColor"))
                        .clipShape(.circle)
                    
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
                    VStack(alignment: .leading, spacing: 6) {
                        Text("NIK")
                            .font(.caption)
                            .foregroundColor(.black)

                        TextField("Masukkan NIK", text: $nik)
                            .keyboardType(.numberPad)
                            .disableAutocorrection(true)
                            .autocapitalization(.none)
                            .padding(12)
                            .background(Color.white)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.black.opacity(0.4), lineWidth: 1)
                            )
                            .cornerRadius(10)
                    }

                    
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Password")
                            .font(.caption)
                            .foregroundColor(.black)

                        ZStack(alignment: .trailing) {
                            Group {
                                if isPasswordVisible {
                                    TextField("Masukkan Password", text: $password)
                                } else {
                                    SecureField("Masukkan Password", text: $password)
                                }
                            }
                            .disableAutocorrection(true)
                            .autocapitalization(.none)
                            .padding(12)
                            .background(Color.white)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.black.opacity(0.4), lineWidth: 1)
                            )
                            .cornerRadius(10)

                            Button(action: {
                                isPasswordVisible.toggle()
                            }) {
                                Image(systemName: isPasswordVisible ? "eye.slash" : "eye")
                                    .foregroundColor(.gray)
                                    .padding(.trailing, 16)
                            }
                        }
                    }


                    
//                    if let error = authViewModel.errorMessage {
//                        Text(error)
//                            .foregroundColor(.red)
//                            .font(.caption)
//                    }
                    
                    Button(action: login) {
                        if authViewModel.isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Text("Login")
                                .foregroundStyle(Color.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical)
                                .background(Color("AccentColor"))
                                .cornerRadius(10)

                        }
                    }
                    .padding(.top, 10)
                    .disabled(nik.isEmpty || password.isEmpty || authViewModel.isLoading)
                }
                .padding(.horizontal, 30)
                
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
