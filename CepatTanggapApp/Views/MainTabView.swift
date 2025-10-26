import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var laporanViewModel = LaporanViewModel()
    
    var body: some View {
        TabView {
                   // MARK: - Tab 1
                   Tab("Beranda", systemImage: "house.fill") {
                       DashboardView()
                           .environmentObject(authViewModel)
                           .environmentObject(laporanViewModel)
                   }

                   // MARK: - Tab 2
//                   Tab("Laporan", systemImage: "doc.text.fill") {
//                       LaporanSayaView()
//                           .environmentObject(authViewModel)
//                           .environmentObject(laporanViewModel)
//                   }
            
            // MARK: - Tab 2
            Tab("Laporan", systemImage: "doc.text.fill") {
                LaporanView()
                    .environmentObject(authViewModel)
                    .environmentObject(laporanViewModel)
            }

//                   // MARK: - Tab 3
//                   Tab("LaporanW", systemImage: "doc.on.doc.fill") {
//                       LaporanWargaView()
//                           .environmentObject(authViewModel)
//                   }

                   // MARK: - Tab 4
                   Tab("Kas RT", systemImage: "dollarsign.square.fill") {
                       KasRTView()
                           .environmentObject(authViewModel)
                   }

                   // MARK: - Tab 5 (terpisah di kanan)
            Tab("Profil", systemImage: "plus",role: .search) {
                       ProfilePageView()
                           .environmentObject(authViewModel)
                   }
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
