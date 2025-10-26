import SwiftUI

struct LaporanWargaView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var vm: LaporanViewModel = {
        let m = LaporanViewModel()
        m.fetchAll = true
        return m
    }()
    @State private var refreshLoading = false
    @State private var rotationAngle = 0.0

    var body: some View {
        NavigationStack {
            
                VStack(spacing: 0) {
                    ZStack {
                        if vm.isLoading && vm.laporanList.isEmpty || refreshLoading {
                            ProgressView("Memuat semua laporan...")
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                        } else if let error = vm.errorMessage {
                            ErrorView(error: error, onRetry: {
                                vm.fetchLaporan()
                            })
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                        } else {
                            LaporanListView(laporanList: vm.laporanList, isLaporanWarga: true)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                .navigationTitle("Laporan Warga")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar(.hidden, for: .tabBar)
                .toolbar{
                    ToolbarItem(placement: .topBarTrailing) {
                        Image(systemName: "ellipsis")
                    }
                }

                
            
            .onAppear {
                vm.fetchAll = true
                vm.filterUserId = nil
                vm.fetchLaporan()
            }
        }
        
        

    }

    private func animateRotation() {
        guard refreshLoading else { return }
        rotationAngle += 360
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            animateRotation()
        }
    }
}

struct LaporanWargaView_Previews: PreviewProvider {
    static var previews: some View {
        LaporanWargaView()
            .environmentObject(AuthViewModel())
            .navigationTitle("Laporan Warga")
    }
}
