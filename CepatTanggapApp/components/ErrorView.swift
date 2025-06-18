//
//  ErrorView.swift
//  CepatTanggapApp
//
//  Created by mohammad ichwan al ghifari on 14/06/25.
//

import SwiftUI


struct ErrorView: View {
    let error: String
    let onRetry: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 50))
                .foregroundColor(.orange)
            
            VStack(spacing: 8) {
                Text("Terjadi Kesalahan")
                    .font(.headline)
                Text(error)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            Button(action: onRetry) {
                Label("Coba Lagi", systemImage: "arrow.clockwise")
                    .padding(.horizontal, 24)
                    .padding(.vertical, 8)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(20)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground))
    }
}


