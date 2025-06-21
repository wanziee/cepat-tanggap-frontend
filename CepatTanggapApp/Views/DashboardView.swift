//
//  DashboardView.swift
//  CepatTanggapApp
//
//  Created by mohammad ichwan al ghifari on 21/06/25.
//

import SwiftUI

struct DashboardView: View {
    var body: some View {
        VStack{
            HeaderView()
            
            GeometryReader{ _ in
                
                HStack{
                    Text("Riwayat Laporan")
                        .font(.headline)
                }
                .padding(20)
                
                
                
                ScrollView(.vertical){
                    VStack{
                        LaporanHistoryCard(category: "Jalan", deskripsi: "fjkalsjdf alsdf kslad flskdkflsa ", tanggal: "02/04/2025")
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 3)
                    

                }
                .padding(.top, 60)

            }
            .background(Color.white)
            .clipShape(UnevenRoundedRectangle(topLeadingRadius: 30,bottomLeadingRadius: 0, bottomTrailingRadius: 0, topTrailingRadius: 30 ))
            .ignoresSafeArea(.all, edges: .bottom)
            
            
        }
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color.darkBlue,Color.darkBlue,Color.darkBlue,Color.lightBlue,Color.lightBlue]),
                startPoint: .bottom,
                endPoint: .top
            )
        )


    }
}

#Preview {
    DashboardView()
}


func HeaderView() -> some View{
    VStack{
        HStack{
            VStack(alignment: .leading){
                Text("Hai, Tania!")
                    .font(.system(size: 25))
                    .fontWeight(.bold)

                Text("RT.03 RW.004")
                    .font(.caption)
            }
            Spacer()
            Image(systemName: "bell.fill")
                .font(.system(size: 25))
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
                    Text("Laporan Anda (3)")
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("1 Proses, 2 Selesai")
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
                    Text("Saldo Kas")
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
