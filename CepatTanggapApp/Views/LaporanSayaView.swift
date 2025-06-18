import SwiftUI

struct LaporanSayaView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var vm = LaporanViewModel()
    @State private var selectedStatus: StatusLaporan?
    @State private var showingNewLaporan = false
    
    var filteredLaporan: [Laporan] {
        var reports = vm.laporanList
        
        // Filter by user ID
        if let uid = authViewModel.currentUser?.id {
            reports = reports.filter { $0.userId == uid }
        }
        
        // Filter by selected status if any
        if let status = selectedStatus {
            reports = reports.filter { $0.status == status }
        }
        
        return reports
    }
    
    var body: some View {
        NavigationView {
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
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                Button(action: { selectedStatus = nil }) {
                                    Text("Semua")
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 8)
                                        .background(selectedStatus == nil ? Color.blue : Color.gray.opacity(0.2))
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
                            .padding()
                        }
                        
                        if filteredLaporan.isEmpty {
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
                                            .background(Color.blue)
                                            .foregroundColor(.white)
                                            .cornerRadius(10)
                                    }
                                }
                            }
                            .padding()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                        } else {
                            LaporanListView(
                                laporanList: filteredLaporan,
                                onDelete: { index in
                                    let laporan = filteredLaporan[index]
                                    vm.deleteLaporan(laporanId: laporan.id) { _ in
                                        // Handle completion if needed
                                    }
                                }
                            )
                        }
                    }
                }
            }
            .navigationTitle("Laporan Saya")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingNewLaporan = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingNewLaporan) {
                NewLaporanView()
                    .environmentObject(vm)
            }
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
