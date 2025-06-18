import SwiftUI

struct LaporanWargaView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var vm: LaporanViewModel = {
        let m = LaporanViewModel()
        m.fetchAll = true
        return m
    }()
    @State private var showingNewLaporan = false
    
    var body: some View {
        NavigationView {
            VStack {
                if vm.isLoading && vm.laporanList.isEmpty {
                    ProgressView("Memuat semua laporan...")
                } else if let error = vm.errorMessage {
                    ErrorView(error: error, onRetry: {
                        vm.fetchLaporan()
                    })
                } else {
                    LaporanListView(laporanList: vm.laporanList)
                }
            }
            .navigationTitle("Laporan Warga")
            .onAppear {
                vm.filterUserId = nil
                vm.fetchAll = true
                vm.fetchLaporan()
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}
struct LaporanWargaView_Previews: PreviewProvider {
    static var previews: some View {
        LaporanWargaView()
            .environmentObject(AuthViewModel())
    }
}
