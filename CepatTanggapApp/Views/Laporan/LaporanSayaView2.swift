//
//  LaporanSayaView2.swift
//  CepatTanggapApp
//
//  Created by Mohammad Ichwan Al Ghifari on 26/10/25.
//

import SwiftUI

struct LaporanSayaView2: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var vm = LaporanViewModel()
    @State private var selectedFilter: Filter = .aktif
    @State private var showingNewLaporan = false
    @State private var rotationAngle: Double = 0 // For refresh button rotation

    enum Filter: String, CaseIterable, Identifiable {
        case aktif = "Aktif"
        case selesai = "Selesai"
        case belumDiulas = "Belum Diulas"

        var id: String { rawValue }
    }

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {

                    statistikCard()
                        .padding(.horizontal, 20)

                    jelajahiGrid()

                    filterSegment()

                    laporanSection()
                }
                .padding(.vertical)
            }
            .background(Color(.systemGray6))
            .navigationTitle("Laporan Saya")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(.hidden, for: .tabBar)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        // Force a visible loading state for 1 second
                        vm.isLoading = true

                        // Start rotation animation loop for ~1s
                        startRotationForOneSecond()

                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                            vm.fetchLaporan()
                        }
                    } label: {
                        Image(systemName: "arrow.trianglehead.2.clockwise")
                            .rotationEffect(.degrees(rotationAngle))
                            .animation(.linear(duration: 0.6), value: rotationAngle)
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingNewLaporan = true
                    } label: {
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
        }
    }

    // MARK: - Statistik
    @ViewBuilder
    private func statistikCard() -> some View {
        let total = vm.laporanList.count

        VStack(spacing: 18) {
            Text("Sejak menggunakan CepatTanggap, kamu sudah melapor sebanyak")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)

            Text("\(total)")
                .font(.system(size: 44, weight: .bold))
                .foregroundColor(.primary)

            Text("Laporan")
                .font(.subheadline)
                .foregroundColor(.secondary)

            Button(action: {}) {
                Text("Lihat Cerita Laporanmu")
                    .font(.headline)
                    .fontWeight(.bold)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.accentColor.opacity(0.2))
            .cornerRadius(10)
            .foregroundColor(Color.accentColor)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.accentColor, lineWidth: 2)
            )
        }
        .padding(30)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.06), radius: 6, x: 0, y: 3)
        )
        .padding(.horizontal)
        .padding(.top)
    }

    // MARK: - Jelajahi Laporanmu
    @ViewBuilder
    private func jelajahiGrid() -> some View {
        let pendingCount = vm.laporanList.filter { $0.status == .pending }.count
        let prosesCount = vm.laporanList.filter { $0.status == .diproses }.count
        let selesaiCount = vm.laporanList.filter { $0.status == .selesai }.count
        let ditolakCount = vm.laporanList.filter { $0.status == .ditolak }.count

        let statusItems: [(String, Int, Color, String)] = [
            ("Menunggu", pendingCount, StatusLaporan.pending.uiColor, "clock"),
            ("Diproses", prosesCount, StatusLaporan.diproses.uiColor, "arrow.triangle.2.circlepath"),
            ("Selesai", selesaiCount, StatusLaporan.selesai.uiColor, "checkmark.circle.fill"),
            ("Ditolak", ditolakCount, StatusLaporan.ditolak.uiColor, "xmark.circle.fill")
        ]

        VStack(alignment: .leading, spacing: 12) {
            Text("Jelajahi Laporanmu")
                .font(.headline)
                .foregroundColor(.primary)
                .padding(.horizontal)

            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 2), spacing: 8) {
                ForEach(statusItems, id: \.0) { item in
                    HStack {
                        Image(systemName: item.3)
                            .font(.system(size: 16))
                            .foregroundColor(item.2)
                            .frame(width: 20)

                        Text(item.0)
                            .font(.system(size: 12))
                            .foregroundColor(.primary)
                            .fontWeight(.semibold)

                        Spacer()

                        Text("\(item.1)")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(10)
                    .background(Color.white)
                    .cornerRadius(12)
                    .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 2)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(item.2.opacity(0.2), lineWidth: 1)
                    )
                }
            }
            .padding(.horizontal)
        }
    }

    // MARK: - Filter Status
    @ViewBuilder
    private func filterSegment() -> some View {
        HStack(spacing: 8) {
            ForEach(Filter.allCases) { filter in
                Button {
                    selectedFilter = filter
                } label: {
                    Text(filter.rawValue)
                        .font(.subheadline)
                        .foregroundColor(selectedFilter == filter ? .white : .accentColor)
                        .padding(.vertical, 8)
                        .frame(maxWidth: .infinity)
                        .background(selectedFilter == filter ? Color.accentColor : Color.clear)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.accentColor, lineWidth: 1)
                        )
                        .cornerRadius(8)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal)
    }

    // MARK: - Laporan Berdasarkan Filter
    @ViewBuilder
    private func laporanSection() -> some View {
        let filtered = vm.laporanList.filter { laporan in
            switch selectedFilter {
            case .aktif:
                return laporan.status == .pending || laporan.status == .diproses
            case .selesai:
                return laporan.status == .selesai
            case .belumDiulas:
                return laporan.status == .ditolak
            }
        }

        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "doc.text.fill")
                    .foregroundColor(.accentColor)
                Text(selectedFilter.rawValue)
                    .font(.headline)
                Spacer()
            }

            if vm.isLoading {
                ProgressView("Memuat laporan...")
                    .frame(maxWidth: .infinity, minHeight: 150)
            } else if filtered.isEmpty {
                emptyStateCard(
                    systemImage: "megaphone.fill",
                    title: "Belum ada laporan \(selectedFilter.rawValue.lowercased())",
                    subtitle: "Yuk buat laporan untuk membantu lingkunganmu.",
                    buttonTitle: "Buat Laporan"
                ) {
                    showingNewLaporan = true
                }
            } else {
                VStack(spacing: 12) {
                    ForEach(filtered) { laporan in
                        // Wrap card in NavigationLink to detail
                        NavigationLink(destination: LaporanDetailView(laporan: laporan, isLaporanWarga: true)) {
                            laporanCard(laporan)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            }
        }
        .padding(.horizontal)
        .padding(.bottom, 50)
    }

    // MARK: - Kartu Laporan (match LaporanHistoryCard style + optional image)
    @ViewBuilder
    private func laporanCard(_ laporan: Laporan) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            // Optional photo at the top
            if let url = laporan.fullFotoURL {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        ZStack {
                            Rectangle()
                                .fill(Color(UIColor.secondarySystemBackground))
                            ProgressView()
                        }
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                    case .failure:
                        ZStack {
                            Rectangle()
                                .fill(Color(UIColor.secondarySystemBackground))
                            Image(systemName: "photo.on.rectangle.angled")
                                .font(.system(size: 28))
                                .foregroundColor(.secondary)
                        }
                    @unknown default:
                        EmptyView()
                    }
                }
                .frame(height: 160)
                .clipped()
                .cornerRadius(10)
            }

            // Title (kategori) and description, matching LaporanHistoryCard
            Text(laporan.kategori.rawValue)
                .font(.headline)
                .fontWeight(.bold)

            Text(laporan.deskripsi)
                .font(.subheadline)
                .lineLimit(2)
                .foregroundColor(.primary)

            HStack {
                Text(formattedDate(laporan.createdAt))
                    .font(.caption)
                    .foregroundColor(.secondary)

                Spacer()

                HStack(spacing: 0) {
                    Text("Lihat Detail ")
                        .font(.caption)
                        .foregroundStyle(Color.blue)

                    Image(systemName: "arrow.right")
                        .font(.caption)
                        .foregroundStyle(Color.blue)
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.2), radius: 2, x: 0, y: 0)
    }

    // MARK: - Empty State
    @ViewBuilder
    private func emptyStateCard(
        systemImage: String,
        title: String,
        subtitle: String? = nil,
        buttonTitle: String? = nil,
        action: (() -> Void)? = nil
    ) -> some View {
        VStack(spacing: 40) {
            Image(systemName: systemImage)
                .font(.system(size: 36))
                .foregroundColor(.gray.opacity(0.6))

            VStack(spacing: 15) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)

                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 16)
                }

                if let buttonTitle = buttonTitle, let action = action {
                    Button(action: action) {
                        Text(buttonTitle)
                            .font(.headline)
                            .fontWeight(.bold)
                            .padding()
                            .background(Color.accentColor.opacity(0.2))
                            .cornerRadius(10)
                            .foregroundColor(Color.accentColor)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.accentColor, lineWidth: 2)
                            )
                    }
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 2)
    }

    // MARK: - Helpers
    private func formattedDate(_ isoString: String) -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        if let date = formatter.date(from: isoString) {
            let outputFormatter = DateFormatter()
            outputFormatter.locale = Locale(identifier: "id_ID") // agar bulan tampil dalam bahasa Indonesia
            outputFormatter.dateFormat = "dd MMM yyyy, HH:mm" // contoh hasil: 26 Okt 2025, 06:42
            return outputFormatter.string(from: date)
        }
        
        return isoString
    }

    private func startRotationForOneSecond() {
        // Perform ~2 full spins over 1 second (0.5s per 360 degrees)
        rotationAngle += 360
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            rotationAngle += 360
        }
    }
}

#Preview {
    LaporanSayaView2()
        .environmentObject(AuthViewModel())
}
