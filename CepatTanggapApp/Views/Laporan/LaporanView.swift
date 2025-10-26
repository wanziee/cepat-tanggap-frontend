//
//  LaporanView.swift
//  CepatTanggapApp
//
//  Created by mohammad ichwan al ghifari on 25/10/25.
//
//
//  LaporanView.swift
//  CepatTanggapApp
//
//  Created by mohammad ichwan al ghifari on 25/10/25.
//

import SwiftUI

struct LaporanView: View {
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 20) {
                        
                        // MARK: - Card Utama
                        VStack(spacing: 16) {
                            ZStack {
                                Circle()
                                    .fill(Color.accentColor)
                                    .blur(radius: 30)
                                    .frame(width: 80, height: 80)
                                    .opacity(0.7)
                                
                                Image("laporanIllustration")
                                    .resizable()
                                    .frame(width: 130, height: 130)
                            }

                            VStack {
                                Text("Mengalami Masalah di Jakarta?")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                
                                Text("Buat Laporan Warga, Yuk!")
                                    .font(.headline)
                            }

                            VStack(spacing: 16) {
                                // Tombol Laporan Foto
                                Button(action: {
                                    // Aksi buat laporan foto
                                }) {
                                    Label {
                                        Text("Buat Laporan Foto")
                                            .font(.headline)
                                            .fontWeight(.bold)
                                    } icon: {
                                        Image("photoCameraIcon")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 24, height: 24)
                                    }
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.accentColor)
                                .cornerRadius(10)
                                .foregroundColor(.white)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.accentColor, lineWidth: 2)
                                )

                                // Tombol Laporan Video
                                Button(action: {
                                    // Aksi buat laporan video
                                }) {
                                    Label {
                                        Text("Buat Laporan Video")
                                            .font(.headline)
                                            .fontWeight(.bold)
                                    } icon: {
                                        Image("videoCameraIcon")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 24, height: 24)
                                    }
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
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(16)
                        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                        .padding(.horizontal)

                        // MARK: - Info Box
                        HStack(alignment: .top) {
                            Image(systemName: "info.circle.fill")
                                .foregroundColor(.blue)
                                .font(.system(size: 22))
                                .frame(width: 50)

                            VStack(alignment: .leading, spacing: 4) {
                                Text("Belum Pernah Melapor?")
                                    .fontWeight(.semibold)
                                
                                Button(action: {
                                    // Aksi pelajari
                                }) {
                                    Text("Pelajari cara buat laporan disini")
                                        .underline()
                                        .foregroundColor(.blue)
                                        .font(.subheadline)
                                }
                            }
                            Spacer()
                            Button(action: {
                                // Tutup info
                            }) {
                                Image(systemName: "xmark")
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding()
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(12)
                        .padding(.horizontal)

                        // MARK: - Eksplor
                        VStack(alignment: .leading, spacing: 20) {
                            Text("Eksplor Laporan Warga")
                                .font(.headline)
                                .fontWeight(.bold)
                                .padding(.horizontal)
                            
                            VStack(spacing: 20) {
                                
                                //navigate to Laporan Warga
                                NavigationLink(destination: LaporanWargaView().environmentObject(AuthViewModel())) {
                                    ExploreRow(icon: "rocketIcon", text: "Lihat laporan warga lainnya")
                                }
                                
                                
                                // Navigate to Laporan Saya
                                NavigationLink(destination: LaporanSayaView2().environmentObject(AuthViewModel())) {
                                    ExploreRow(icon: "documentSearchIcon", text: "Pantau laporan yang kamu buat")
                                }
                                

                                ExploreRow(icon: "magnifyingGlassIcon", text: "Cari laporan")
                            }
                            .padding(.horizontal)
                        }

                        // MARK: - Bantuan
                        VStack(alignment: .leading, spacing: 20) {
                            Text("Butuh Bantuan Lebih Lanjut?")
                                .font(.headline)
                                .fontWeight(.bold)
                                .padding(.horizontal)
                            
                            VStack(spacing: 20) {
                                BantuanRow(icon: "mailIcon", headline: "Kirim Pertanyaanmu via Email", subHeadline: "ichwanalghifa@gmail.com")
                         
                            }
                            .padding(.horizontal)
                        }

                        Spacer(minLength: 40)
                    }
                    .padding(.top, 20)
                    .padding(.horizontal, 10)
                }
                .background(Color(.systemGray6))
            }
            .navigationTitle("Laporan")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Image(systemName: "ellipsis")
                }
            }
        }
    }
}

// MARK: - Reusable Row for Explore section
struct ExploreRow: View {
    let icon: String
    let text: String
 

    var body: some View {
        HStack {
            Image(icon)
                .resizable()
                .scaledToFit()
                .frame(width: 50, height: 50)
            

                Text(text)
                    .foregroundColor(.black)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.leading)
                
            Spacer()
            
            Image(systemName: "chevron.right")
                .fontWeight(.bold)
                .foregroundColor(Color.accentColor)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 2)
    }
}
struct BantuanRow: View {
    let icon: String
    let headline: String
    var subHeadline: String? = ""

    var body: some View {
        HStack {
            Image(icon)
                .resizable()
                .scaledToFit()
                .frame(width: 50, height: 50)
            
            VStack(alignment: .leading) {
                Text(headline)
                    .foregroundColor(.black)
                    .fontWeight(.semibold)
                
                Text(subHeadline ?? "")
                    .foregroundStyle(Color.blue)
            
            }
            
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .fontWeight(.bold)
                .foregroundColor(Color.accentColor)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 2)
    }
}

#Preview {
    LaporanView()
}
