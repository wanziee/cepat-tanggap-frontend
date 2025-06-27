import SwiftUI

struct LaporanSayaView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var vm = LaporanViewModel()
    @State private var refreshLoading = false
    @State private var rotationAngle = 0.0



//    @State private var selectedStatus: StatusLaporan?
    @State private var showingNewLaporan = false

    var body: some View {
        NavigationView {
            ZStack(alignment: .top) {
                // Konten utama dengan padding top supaya tidak tertutup navbar
                VStack(spacing: 0) {
                    ZStack {
                        if vm.isLoading && vm.laporanList.isEmpty || refreshLoading{
                            ProgressView("Memuat...")
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                        } else if let error = vm.errorMessage {
                            ErrorView(error: error) {
                                vm.fetchLaporan()
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                        } else {
                            VStack(spacing: 0) {
                                // Filter Status
                                
                                
                                // Daftar laporan atau placeholder kosong
                                if vm.filteredLaporan.isEmpty {
                                    VStack(spacing: 16) {
                                        Image(systemName: "doc.text.magnifyingglass")
                                            .font(.system(size: 50))
                                            .foregroundColor(.gray)
                                        Text("Tidak ada laporan")
                                            .font(.headline)
                                        Text(vm.selectedStatus == nil ?
                                             "Anda belum membuat laporan" :
                                             "Tidak ada laporan dengan status ini")
                                            .font(.subheadline)
                                            .foregroundColor(.gray)
                                            .multilineTextAlignment(.center)
                                        
                                        if vm.selectedStatus == nil {
                                            Button(action: { showingNewLaporan = true }) {
                                                Label("Buat Laporan", systemImage: "plus")
                                                    .padding()
                                                    .background(Color("AccentColor"))
                                                    .foregroundColor(.white)
                                                    .cornerRadius(10)
                                            }
                                        }
                                    }
                                    .padding()
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                                } else {

                                    LaporanListView(
                                        
                                        laporanList: vm.filteredLaporan,
                                        onDelete: { index in
                                            let laporan = vm.filteredLaporan[index]
                                            vm.deleteLaporan(laporanId: laporan.id) { _ in }
                                        }
                                        , laporanSaya: true
                                    )
                                }
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                /*.padding(.top, 60)*/ // kasih padding top sesuai tinggi navbar
                
                
                // Custom Navigation Bar (sticky di atas)
                VStack {
                    HStack {
                        Button(action: {
                            refreshLoading = true
                            animateRotation()

                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                                if let uid = authViewModel.currentUser?.id {
                                    vm.filterUserId = uid
                                    vm.fetchAll = false
                                    vm.fetchLaporan()
                                }
                                refreshLoading = false
                            }
                        }) {
                            Image(systemName: "arrow.clockwise")
                                .font(.system(size: 20, weight: .semibold))
                                .rotationEffect(.degrees(rotationAngle))
                                .animation(.linear(duration: 0.8), value: rotationAngle)
                        }

                        Spacer()
                        
                        Text("Laporan Saya")
                            .font(.headline)
                            .bold()
                        
                        Spacer()
                        
                        Button(action: {
                            showingNewLaporan = true
                        }) {
                            Image(systemName: "plus")
                                .font(.system(size: 20, weight: .semibold))
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 10)

                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            Button(action: { vm.selectedStatus = nil }) {
                                Text("Semua")
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(vm.selectedStatus == nil ? Color("AccentColor") : Color.gray.opacity(0.2))
                                    .foregroundColor(vm.selectedStatus == nil ? .white : .primary)
                                    .cornerRadius(20)
                            }
                            ForEach(StatusLaporan.allCases, id: \.self) { status in
                                Button(action: { vm.selectedStatus = status }) {
                                    Text(status.displayName)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 8)
                                        .background(vm.selectedStatus == status ? status.uiColor : Color.gray.opacity(0.2))
                                        .foregroundColor(vm.selectedStatus == status ? .white : .primary)
                                        .cornerRadius(20)
                                }
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 7)
                    }

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
            .sheet(isPresented: $showingNewLaporan) {
                NewLaporanView()
                    .environmentObject(vm)
            }
            .navigationBarHidden(true)
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .onAppear {
            if let uid = authViewModel.currentUser?.id {
                vm.filterUserId = uid
                vm.fetchAll = false
                vm.fetchLaporan()
            }
        }
    }
    func animateRotation() {
        guard refreshLoading else { return }
        rotationAngle += 360
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            animateRotation()
        }
    }
}

struct laporanSayaView_Previews: PreviewProvider {
    static var previews: some View {
        LaporanSayaView()
            .environmentObject(AuthViewModel())
    }
}


