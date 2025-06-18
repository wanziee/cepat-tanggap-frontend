//
//  LogStatusRow.swift
//  CepatTanggapApp
//
//  Created by mohammad ichwan al ghifari on 13/06/25.
//
import SwiftUI
struct LogStatusRow: View {
    let log: LogStatus
    let isLast: Bool

    var body: some View {
        HStack(alignment: .top) {
            VStack {
                Circle()
                    .fill(Color(log.status.color))
                    .frame(width: 12, height: 12)
                    .padding(4)

                if !isLast {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 2)
                        .padding(.vertical, 4)
                }
            }

            VStack(alignment: .leading, spacing: 4) {
                Text("\(log.status.displayName) - \(formatDate(log.waktu))")
                    .font(.subheadline)

                Text("Oleh: \(log.user.nama) (\(log.user.role))")
                    .font(.caption)
                    .foregroundColor(.gray)
            }

            Spacer()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func formatDate(_ dateString: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        if let date = formatter.date(from: dateString) {
            formatter.dateStyle = .medium
            formatter.timeStyle = .short
            return formatter.string(from: date)
        }
        return dateString
    }
}


