//
//  RoundedStatusView.swift
//  CepatTanggapApp
//
//  Created by mohammad ichwan al ghifari on 28/06/25.
//

import SwiftUI

import SwiftUI

struct RoundedStatusView: View {
    let status: StatusLaporan
    let onSelect: (StatusLaporan) -> Void

    var body: some View {
        Menu {
            ForEach(StatusLaporan.allCases, id: \.self) { s in
                if s != status {
                    Button(s.displayName) {
                        onSelect(s)
                    }
                }
            }
        } label: {
            HStack(spacing: 6) {
                Circle()
                    .fill(status.uiColor)
                    .frame(width: 10, height: 10)

                Text(status.displayName)
                    .font(.subheadline)
                    .foregroundColor(.primary)
            }
        }
        .fixedSize()
    }
}


//#Preview {
//    VStack(spacing: 16) {
//        RoundedStatusView(status: .pending) { newStatus in
//            print("Pilih status:", newStatus)
//        }
//
//        RoundedStatusView(status: .selesai) { _ in }
//    }
//    .padding()
//    .previewLayout(.sizeThatFits)
//}
