//
//  StatusHeaderView.swift
//  CepatTanggapApp
//
//  Created by mohammad ichwan al ghifari on 13/06/25.
//

import SwiftUI



struct StatusHeaderView: View {
    let status: StatusLaporan
    let canUpdate: Bool
    let onSelect: (StatusLaporan) -> Void

    var body: some View {
        HStack {
            Text(status.displayName)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(status.uiColor)
                .foregroundColor(.white)
                .cornerRadius(12)

            Spacer()

            if canUpdate {
                Menu {
                    ForEach(StatusLaporan.allCases, id: \.self) { s in
                        if s != status {
                            Button(s.displayName) {
                                onSelect(s)
                            }
                        }
                    }
                } label: {
                    HStack {
                        Text("Ubah Status")
                        Image(systemName: "chevron.down")
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
            }
        }
    }
}
