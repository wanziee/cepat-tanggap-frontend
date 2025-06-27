//
//  DashboardView.swift
//  CepatTanggapApp
//
//  Created by mohammad ichwan al ghifari on 21/06/25.
//

import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var viewModel = LaporanViewModel()
    @AppStorage("hasNewNotification") private var hasNewNotification: Bool = true



    var body: some View {
        NavigationStack {
            VStack {
                HeaderView(viewModel: viewModel, authViewModel: authViewModel, hasNewNotification: $hasNewNotification)
                
                GeometryReader { _ in
                    VStack(alignment: .leading) {
                        Text("Riwayat Laporan")
                            .font(.headline)
                            .padding(.top, 20)
                            .padding(.horizontal, 20)
                        
                        if viewModel.isLoading {
                            ProgressView()
                                .frame(maxWidth: .infinity, alignment: .center)
                        } else {
                            ScrollView(.vertical) {
                                VStack(spacing: 12) {
                                    ForEach(viewModel.laporanList.prefix(5)) { laporan in
                                        LaporanHistoryCard(
                                            category: laporan.kategori.rawValue,
                                            deskripsi: laporan.deskripsi,
                                            tanggal: formatDate(from: laporan.createdAt)
                                        )
                                    }
                                    
                                    VStack{
                                        
                                    }
                                    .frame(width: 30, height: 120)
                                }
                                
                                .padding(.horizontal, 20)
                                .padding(.top, 3)
                            }
                            
                        }
                    }
                    
                }
                .background(Color.white)
                .clipShape(UnevenRoundedRectangle(topLeadingRadius: 30, bottomLeadingRadius: 0, bottomTrailingRadius: 0, topTrailingRadius: 30))
                .ignoresSafeArea(.all, edges: .bottom)
            }
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [Color.darkBlue, Color.darkBlue, Color.darkBlue, Color.lightBlue, Color.lightBlue]),
                    startPoint: .bottom,
                    endPoint: .top
                )
            )
            .onAppear {
                viewModel.fetchLaporan()
            }
        }
    }

    // Ubah String ISO8601 (ex: "2023-01-01T00:00:00Z") menjadi format lokal
    func formatDate(from string: String) -> String {
        let isoFormatter = ISO8601DateFormatter()
        if let date = isoFormatter.date(from: string) {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .none
            return formatter.string(from: date)
        } else {
            return "Tanggal tidak valid"
        }
    }
}

#Preview {
    DashboardView()
        .environmentObject(AuthViewModel()) // Tambahkan ini agar tidak crash
}


func HeaderView(viewModel: LaporanViewModel, authViewModel: AuthViewModel, hasNewNotification: Binding<Bool>) -> some View {
    let total = viewModel.laporanList.count
    let proses = viewModel.laporanList.filter { $0.status == .diproses }.count
    let selesai = viewModel.laporanList.filter { $0.status == .selesai }.count
    
    let nama = authViewModel.currentUser?.nama ?? "Warga"
    let rt = authViewModel.currentUser?.rt ?? "-"
    let rw = authViewModel.currentUser?.rw ?? "-"


    return VStack {
        HStack {
            VStack(alignment: .leading) {
                Text("Hai, \(nama)!")
                    .font(.system(size: 20))
                    .fontWeight(.bold)

                Text(" RW.\(rw), RT.\(rt)")
                    .font(.caption)
            }
            .frame(maxWidth: 250, alignment: .leading)
            Spacer()
            NavigationLink(destination: NotificationView(laporanList: viewModel.laporanList, hasNewNotification: hasNewNotification)) {
                ZStack(alignment: .topTrailing) {
                    Image(systemName: "bell.fill")
                        .font(.system(size: 25))
                    
                    if hasNewNotification.wrappedValue {
                        Circle()
                            .fill(Color.red)
                            .frame(width: 10, height: 10)
                            .offset(x: 8, y: -8)
                    }
                }
            }

        }
        .padding(.horizontal, 20)
        .padding(.bottom, 15)
        .foregroundStyle(Color.white)
        .background(Color.lightBlue)
        .shadow(color: Color.veryDarkBlue, radius: 5)
        

        VStack(spacing: 20) {
            Text("Informasi Terkini")
                .foregroundStyle(Color.white)
                .font(.headline)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity, alignment: .leading)

            HStack(spacing: 16) {
                VStack(alignment: .leading) {
                    Text("Laporan Anda (\(total))")
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)

                    Text("\(proses) Proses, \(selesai) Selesai")
                        .font(.system(size: 11))
                        .fontWeight(.light)
                        .foregroundColor(.white)

                    HStack {
                        Spacer()
                        Image("megaphone")
                            .resizable()
                            .scaledToFit()
                        Spacer()
                    }
                }
                .padding(10)
                .frame(maxWidth: .infinity)
                .frame(height: 150)
                .background(Color("veryDarkBlue"))
                .cornerRadius(20)

                VStack(alignment: .leading) {
                    Text("Saldo Kas RT")
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)

                    Text("Rp. 10.000.000")
                        .font(.system(size: 11))
                        .fontWeight(.light)
                        .foregroundColor(.white)

                    HStack {
                        Spacer()
                        Image("wallet")
                            .resizable()
                            .scaledToFit()
                        Spacer()
                    }
                }
                .padding(10)
                .frame(maxWidth: .infinity)
                .frame(height: 150)
                .background(Color("veryDarkBlue"))
                .cornerRadius(20)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 20)
    }
}
