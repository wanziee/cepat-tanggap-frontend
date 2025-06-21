import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var laporanViewModel = LaporanViewModel()
    
    var body: some View {
        TabView {
            DashboardView()
                .tabItem {
                    Label("Dashboard", systemImage: "house")
                }
                .environmentObject(authViewModel)
                .environmentObject(laporanViewModel)
            
            LaporanSayaView()
                .environmentObject(authViewModel)
                .environmentObject(laporanViewModel)
                .tabItem {
                    Label("Laporan Saya", systemImage: "doc.text")
                }
            
            LaporanWargaView()
                .environmentObject(authViewModel)
                .tabItem {
                    Label("Laporan Warga", systemImage: "person.3")
                }
            
            ProfilePageView()
                .environmentObject(authViewModel)
                .tabItem {
                    Label("Profil", systemImage: "person")
                }
                .environmentObject(authViewModel)
        }
    }
}

struct ProfileView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    var body: some View {
        VStack(spacing: 16) {
            Text("Profil")
            Button("Logout") {
                authViewModel.logout()
            }
        }
    }
}

struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
            .environmentObject(AuthViewModel())
    }
}
