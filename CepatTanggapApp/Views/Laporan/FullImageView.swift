//
//  FullImageVIew.swift
//  CepatTanggapApp
//
//  Created by mohammad ichwan al ghifari on 23/10/25.
//

import SwiftUI

struct FullImageView: View {
    let imageName: String
    var imageURL: URL?

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack(alignment: .topTrailing) {
            Color.black.ignoresSafeArea()

            if let url = imageURL {
                // Gambar dari URL
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } placeholder: {
                    ProgressView()
                        .tint(.white)
                }
            } else {
                // Gambar dari asset lokal
                Image(imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }

            // Tombol Tutup / Back
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.white)
                    .font(.system(size: 28))
                    .padding()
            }
        }
    }
}
