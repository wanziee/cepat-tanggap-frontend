import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var nik = ""
    @State private var password = ""
    @State private var isRegistering = false
    
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
                            Text("Masuk")
                                .fontWeight(.semibold)
                        }
                    }
                    .buttonStyle(PrimaryButtonStyle())
                    .disabled(authViewModel.isLoading || nik.isEmpty || password.isEmpty)
                    
                    Button(action: { isRegistering = true }) {
                        Text("Belum punya akun? Daftar")
                            .foregroundColor(.blue)
                            .font(.subheadline)
                    }
                    .sheet(isPresented: $isRegistering) {
                        RegisterView()
                            .environmentObject(authViewModel)
                    }
                }
                .padding(.horizontal, 30)
                
                Spacer()
                
                // Footer
                VStack(spacing: 4) {
                    Text("© 2025 Cepat Tanggap")
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
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
            .opacity(configuration.isPressed ? 0.8 : 1.0)
    }
}

struct RegisterView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var authViewModel: AuthViewModel
    
    @State private var nik = ""
    @State private var nama = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var alamat = ""
    @State private var selectedRole = "warga"
    
    let roles = ["warga", "rt", "rw"]
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Informasi Akun")) {
                    TextField("NIK", text: $nik)
                        .keyboardType(.numberPad)
                    
                    SecureField("Password", text: $password)
                    
                    SecureField("Konfirmasi Password", text: $confirmPassword)
                }
                
                Section(header: Text("Data Diri")) {
                    TextField("Nama Lengkap", text: $nama)
                    
                    Picker("Peran", selection: $selectedRole) {
                        ForEach(roles, id: \.self) { role in
                            Text(role.capitalized).tag(role)
                        }
                    }
                    
                    TextField("Alamat", text: $alamat)
                }
                
                if let error = authViewModel.errorMessage {
                    Section {
                        Text(error)
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                }
                
                Section {
                    Button(action: register) {
                        if authViewModel.isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Text("Daftar")
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .buttonStyle(BorderlessButtonStyle())
                    .disabled(isFormInvalid || authViewModel.isLoading)
                }
            }
            .navigationTitle("Daftar Akun")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Batal") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
    
    private var isFormInvalid: Bool {
        nik.isEmpty || nama.isEmpty || password.isEmpty ||
        password != confirmPassword || alamat.isEmpty ||
        password.count < 6
    }
    
    private func register() {
        let userData: [String: Any] = [
            "nik": nik,
            "nama": nama,
            "password": password,
            "role": selectedRole,
            "alamat": alamat
        ]
        
        authViewModel.register(userData: userData)
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
            .environmentObject(AuthViewModel())
    }
}
