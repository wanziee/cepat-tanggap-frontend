//
//  CustomNavbarView.swift
//  CepatTanggapApp
//
//  Created by mohammad ichwan al ghifari on 20/06/25.
//

import SwiftUI

struct CustomNavbarView: View {
    var body: some View {
        HStack{
            VStack(alignment: .leading){
                Text("Hai, Tania!")
                    .font(.system(size: 25))
                    .fontWeight(.bold)
                Text("Perumahan Mawar no.20")
                    .font(.caption)
                Text("RT.03 RW.004")
                    .font(.caption)
            }
            Spacer()
            Image(systemName: "bell.fill")
                .font(.system(size: 25))
               
        }
        .foregroundStyle(Color.white)
        .padding(.horizontal, 20)
        .padding(.vertical)
        .background(Color("lightBlue"))
        .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
    }
}

#Preview {
    CustomNavbarView()
    Spacer()
}
