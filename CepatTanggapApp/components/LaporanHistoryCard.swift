//
//  LaporanHistoryCard.swift
//  CepatTanggapApp
//
//  Created by mohammad ichwan al ghifari on 21/06/25.
//

import SwiftUI

struct LaporanHistoryCard: View {
    
    var category: String
    var deskripsi: String
    var tanggal: String
    var body: some View {
        VStack(alignment: .leading, spacing: 10){
            Text(category)
                .font(.headline)
                .fontWeight(.bold)
            
            Text(deskripsi)
                .font(.subheadline)
            
            HStack{
                Text(tanggal)
                    .font(.caption)
                
                Spacer()
                
                NavigationLink{
                    
                } label:{
                    HStack(spacing: 0){
                        Text("Lihat Detail ")
                            .font(.caption)
                            .foregroundStyle(Color.darkBlue)
                        
                        Image(systemName: "arrow.right")
                            .font(.caption)
                            .foregroundStyle(Color.darkBlue)
                    }

                }
                
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .cornerRadius(10)
        .shadow(color: Color.gray, radius: 1)

    }
}

#Preview {
    LaporanHistoryCard(category: "Jalan", deskripsi: "fjaslkjdflksa flskadj flkasdf klsa", tanggal: "03/04/2025")
        .padding()
}
