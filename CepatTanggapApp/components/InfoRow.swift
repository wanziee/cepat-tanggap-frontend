import SwiftUI

struct InfoRow: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .frame(width: 24)
                .foregroundColor(.blue)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(value)
                    .foregroundColor(.primary)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    InfoRow(icon: "person.fill", title: "NIK", value: "1234567890123456")
}
