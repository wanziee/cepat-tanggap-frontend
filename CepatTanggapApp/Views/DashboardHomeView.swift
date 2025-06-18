import SwiftUI

struct DashboardHomeView: View {
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                Image(systemName: "megaphone")
                    .font(.system(size: 60))
                    .foregroundColor(.blue)
                Text("Selamat datang di Cepat Tanggap!")
                    .font(.title2)
                    .multilineTextAlignment(.center)
                Text("Gunakan menu di bawah untuk membuat laporan baru atau melihat laporan yang ada.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding()
            .navigationTitle("Dashboard")
        }
    }
}
