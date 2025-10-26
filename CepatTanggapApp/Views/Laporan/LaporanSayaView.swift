import SwiftUI

struct LaporanSayaView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var vm = LaporanViewModel()
    @State private var refreshLoading = false
    @State private var rotationAngle = 0.0
    @State private var showingNewLaporan = false

    var body: some View {
        NavigationStack {
            if #available(iOS 26.0, *) {
                ScrollView {
                    LazyVStack(spacing: 0, pinnedViews: [.sectionHeaders]) {
                        
                        // 🔹 Section dengan header sticky (kategori)
                        
                        Section {
                            // Konten daftar laporan
                            Group {
                                if vm.isLoading && vm.laporanList.isEmpty || refreshLoading {
                                    VStack {
                                        Spacer()
                                        ProgressView("Memuat...")
                                        Spacer()
                                    }
                                } else if let error = vm.errorMessage {
                                    ErrorView(error: error) {
                                        vm.fetchLaporan()
                                    }
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                                } else {
                                    if vm.filteredLaporan.isEmpty {
                                        VStack(spacing: 16) {
                                            Image(systemName: "doc.text.magnifyingglass")
                                                .font(.system(size: 50))
                                                .foregroundColor(.gray)
                                            Text("Tidak ada laporan")
                                                .font(.headline)
                                            Text(vm.selectedStatus == nil
                                                 ? "Anda belum membuat laporan"
                                                 : "Tidak ada laporan dengan status ini")
                                            .font(.subheadline)
                                            .foregroundColor(.gray)
                                            .multilineTextAlignment(.center)
                                            
                                            if vm.selectedStatus == nil {
                                                Button(action: { showingNewLaporan = true }) {
                                                    Label("Buat Laporan", systemImage: "plus")
                                                        .padding()
                                                        .background(Color.accentColor)
                                                        .foregroundColor(.white)
                                                        .cornerRadius(10)
                                                }
                                            }
                                        }
                                        .padding(.top, 160)
                                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                                    } else {
                                        LaporanListView(
                                            laporanList: vm.filteredLaporan,
                                            onDelete: { index in
                                                let laporan = vm.filteredLaporan[index]
                                                vm.deleteLaporan(laporanId: laporan.id) { _ in }
                                            },
                                            laporanSaya: true
                                        )
                                    }
                                }
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                        }
                        
                        
                        
                    }
                }
                .navigationTitle("Laporan Saya")
                .safeAreaBar(edge: .top){
                    
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                
                                // Tombol "Semua"
                                Button(action: { vm.selectedStatus = nil }) {
                                    Text("Semua")
                                        .foregroundStyle(vm.selectedStatus == nil ?
                                                         Color.accentColor : Color.black)
                                        .font(.system(.body, design: .rounded))
                                        .fontWeight(vm.selectedStatus == nil ? .semibold : .regular)
                                        .padding(.horizontal, 18)
                                        .padding(.vertical, 10)
                                        .contentShape(Capsule())
                                        .glassEffect()
                                        .overlay(
                                            Capsule()
                                                .strokeBorder(vm.selectedStatus == nil ? Color.accentColor.opacity(0.6) : Color.secondary.opacity(0.3), lineWidth: 1)
                                                .fill(vm.selectedStatus == nil ? Color.accentColor.opacity(0.6) : Color.clear)
                                        )
                                        

                                }
                                .tint(.primary)
                                .buttonStyle(.plain)
                                .hoverEffect(.highlight)
                                .transition(.scale.combined(with: .opacity))
                                .animation(.smooth, value: vm.selectedStatus)
                                
                                // Tombol kategori lain
                                ForEach(StatusLaporan.allCases, id: \.self) { status in
                                    Button(action: { vm.selectedStatus = status }) {
                                        Text(status.displayName)
                                            .font(.system(.body, design: .rounded))
                                            .fontWeight(vm.selectedStatus == status ? .semibold : .regular)
                                            .padding(.horizontal, 18)
                                            .padding(.vertical, 10)
                                            .contentShape(Capsule())
                                            .glassEffect()
                                            .overlay(
                                              Capsule()
                                                 .strokeBorder(
                                                    vm.selectedStatus == status
                                                    ? status.uiColor
                                                    : Color.secondary.opacity(0.3),
                                                    lineWidth: 1)
                                                 .fill(vm.selectedStatus == status ? status.uiColor.opacity(0.6) : Color.clear )
                                            )
                                    }
                                    .tint(.primary)
                                    .buttonStyle(.plain)
                                    .hoverEffect(.highlight)
                                    .transition(.scale.combined(with: .opacity))
                                    .animation(.smooth, value: vm.selectedStatus)
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                        }
                        .clipShape(RoundedRectangle(cornerRadius: 0))
                        .overlay(Divider(), alignment: .bottom)
                    

                }
                .scrollEdgeEffectStyle(.hard, for: .top)
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarTitleDisplayMode(.large)
                .toolbar {
                    // 🔹 Tombol refresh
                    ToolbarItem(placement: .navigationBarLeading) {
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
                                .rotationEffect(.degrees(rotationAngle))
                                .animation(.linear(duration: 0.8), value: rotationAngle)
                        }
                    }
                    
                    // 🔹 Tombol tambah
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
                .onAppear {
                    if let uid = authViewModel.currentUser?.id {
                        vm.filterUserId = uid
                        vm.fetchAll = false
                        vm.fetchLaporan()
                    }
                }
            } else {
                // Fallback on earlier versions
            }
        }
        
    }

    // 🔄 Animasi tombol refresh
    func animateRotation() {
        guard refreshLoading else { return }
        rotationAngle += 360
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            animateRotation()
        }
    }
}

#Preview {
    LaporanSayaView()
        .environmentObject(AuthViewModel())
}
