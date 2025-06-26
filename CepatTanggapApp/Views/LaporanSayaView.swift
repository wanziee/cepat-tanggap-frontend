import SwiftUI

struct LaporanSayaView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var vm = LaporanViewModel()
    @State private var selectedStatus: StatusLaporan?
    @State private var showingNewLaporan = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // ✅ Custom Navigation Bar
                HStack {
                    Button(action: {
                        if let uid = authViewModel.currentUser?.id {
                            vm.filterUserId = uid
                            vm.fetchAll = false
                            vm.fetchLaporan()
                        }
                    }) {

                            Image(systemName: "arrow.clockwise")
                                .font(.system(size: 20, weight: .semibold))
   

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
                .padding()
                .background(Color(UIColor.systemBackground))
                

                // ✅ Konten
                ZStack {
                    if vm.isLoading && vm.laporanList.isEmpty {
                        ProgressView("Memuat...")
                    } else if let error = vm.errorMessage {
                        ErrorView(error: error) {
                            vm.fetchLaporan()
                        }
                    } else {
                        VStack {
                            // Status Filter
                            VStack(spacing: 0) {
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack {
                                        Button(action: { selectedStatus = nil }) {
                                            Text("Semua")
                                                .padding(.horizontal, 16)
                                                .padding(.vertical, 8)
                                                .background(selectedStatus == nil ? Color("AccentColor") : Color.gray.opacity(0.2))
                                                .foregroundColor(selectedStatus == nil ? .white : .primary)
                                                .cornerRadius(20)
                                        }
                                        
                                        ForEach(StatusLaporan.allCases, id: \.self) { status in
                                            Button(action: { selectedStatus = status }) {
                                                Text(status.displayName)
                                                    .padding(.horizontal, 16)
                                                    .padding(.vertical, 8)
                                                    .background(selectedStatus == status ? status.uiColor : Color.gray.opacity(0.2))
                                                    .foregroundColor(selectedStatus == status ? .white : .primary)
                                                    .cornerRadius(20)
                                            }
                                        }
                                    }
                                    .padding(.horizontal)
                                    .padding(.vertical, 3)
                                }
                                
                                
                            }
   
                            

                            
                            
                            if vm.filteredLaporan.isEmpty {
                                VStack(spacing: 16) {
                                    Image(systemName: "doc.text.magnifyingglass")
                                        .font(.system(size: 50))
                                        .foregroundColor(.gray)
                                    Text("Tidak ada laporan")
                                        .font(.headline)
                                    Text(selectedStatus == nil ?
                                         "Anda belum membuat laporan" :
                                         "Tidak ada laporan dengan status ini")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                    .multilineTextAlignment(.center)
                                    
                                    if selectedStatus == nil {
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
                                )
                            }
                        }
                    }
                }
            }
            .sheet(isPresented: $showingNewLaporan) {
                NewLaporanView()
                    .environmentObject(vm)
            }
            .navigationBarHidden(true) // ✅ Hilangkan nav bar asli
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
}

struct laporanSayaView_Previews: PreviewProvider {
    static var previews: some View {
        LaporanSayaView()
            .environmentObject(AuthViewModel())
    }
}
