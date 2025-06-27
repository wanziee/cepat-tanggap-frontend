//
//  TopCurveShape.swift
//  CepatTanggapApp
//
//  Created by mohammad ichwan al ghifari on 16/06/25.
//

import SwiftUI

struct SplashView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    var body: some View{
        VStack(spacing: 0) {
            
            VStack{
                Image("logo")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 170, height: 170)
                    
            }
            .frame(height: 500)
            .frame(maxWidth: .infinity)
            .background(Color("AccentColor"))
            .clipShape(CustomCorner(corner: .bottomLeft, size: 70))
            
            ZStack{
                Color("AccentColor")
                
                Color(Color.white)
                    .clipShape(CustomCorner(corner: .topRight, size: 70))
                
                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Selamat Datang di")
                        Text("CEPAT TANGGAP")
                    }
                    .foregroundStyle(Color.black)
                    .font(.largeTitle)
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Layanan Transparansi &")
                        Text("Pengaduan Warga Proaktif")
                    }
                    .foregroundStyle(Color.gray)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Spacer()
                    
//                    NavigationLink{
//                        LoginView()
//                    } label: {
//                        Text("Masuk")
//                            .foregroundStyle(.white)
//                            .fontWeight(.bold)
//                            .frame(maxWidth: .infinity)
//                            .padding()
//                            .background(Color("AccentColor"))
//                            .cornerRadius(10)
//                    }
                }
                .padding(.vertical, 50)
                .padding(.horizontal, 30)
            }
            Spacer()
        }
        .background(Color.white)
        .ignoresSafeArea(.all, edges: .top)
        
    }
}


struct CustomCorner : Shape {
    var corner: UIRectCorner
    var size: CGFloat
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corner, cornerRadii: CGSize(width: size, height: size))
        
        return Path(path.cgPath)
    }
}

#Preview {
    SplashView()
}
