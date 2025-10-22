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
        NavigationView {
            ZStack(alignment: .top) {
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

                VStack {
                    HStack {
                        Button(action: {
                            refreshLoading = true
                            animateRotation()

                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                                vm.fetchAll = true
                                vm.filterUserId = nil
                                vm.fetchLaporan()
                                refreshLoading = false
                            }
                        }) {
                            Image(systemName: "arrow.clockwise")
                                .font(.system(size: 20, weight: .semibold))
                                .rotationEffect(.degrees(rotationAngle))
                                .animation(.linear(duration: 0.8), value: rotationAngle)
                        }

                        Spacer()

                        Text("Laporan Warga")
                            .font(.headline)
                            .bold()

                        Spacer()

                        // Spacer untuk menjaga simetri UI
                        Image(systemName: "arrow.clockwise")
                            .font(.system(size: 20, weight: .semibold))
                            .opacity(0) // transparan agar tetap center
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 10)
                }
                .background(.thinMaterial)
                .overlay(
                    Rectangle()
                        .frame(height: 1)
                        .foregroundColor(Color.gray.opacity(0.2)),
                    alignment: .bottom
                )
                .shadow(color: .black.opacity(0.2), radius: 6, x: 0, y: 0)
            }
            .onAppear {
                vm.fetchAll = true
                vm.filterUserId = nil
                vm.fetchLaporan()
            }
            .navigationBarHidden(true)
        }
        .navigationViewStyle(StackNavigationViewStyle())
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
    }
}
