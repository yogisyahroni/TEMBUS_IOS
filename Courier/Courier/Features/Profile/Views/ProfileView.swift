import SwiftUI

struct ProfileView: View {
    @EnvironmentObject private var authViewModel: AuthViewModel
    @State private var showLogoutConfirm: Bool = false

    var body: some View {
        NavigationStack {
            List {
                // Profile section
                Section {
                    HStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(Color("Primary").opacity(0.15))
                                .frame(width: 60, height: 60)
                            Image(systemName: "person.fill")
                                .font(.title2)
                                .foregroundStyle(Color("Primary"))
                        }
                        VStack(alignment: .leading, spacing: 2) {
                            Text(authViewModel.courierProfile?.name ?? "Kurir TEMBUS")
                                .font(.headline)
                            Text(authViewModel.courierProfile?.phone ?? "-")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.vertical, 4)
                }

                // Settings
                Section("Pengaturan") {
                    Label("Keamanan", systemImage: "lock.shield.fill")
                    Label("Notifikasi", systemImage: "bell.fill")
                    Label("Bahasa", systemImage: "globe")
                }

                // Support
                Section("Bantuan") {
                    Label("Hubungi Support", systemImage: "headphones")
                    Label("Kebijakan Privasi", systemImage: "doc.text.fill")
                    Label("Syarat & Ketentuan", systemImage: "doc.badge.checkmark")
                }

                // Logout
                Section {
                    Button(role: .destructive) {
                        showLogoutConfirm = true
                    } label: {
                        Label("Keluar", systemImage: "rectangle.portrait.and.arrow.right")
                    }
                }
            }
            .navigationTitle("Profil")
            .confirmationDialog("Keluar dari akun?", isPresented: $showLogoutConfirm, titleVisibility: .visible) {
                Button("Keluar", role: .destructive) {
                    authViewModel.logout()
                }
                Button("Batal", role: .cancel) {}
            } message: {
                Text("Kamu akan keluar dari aplikasi TEMBUS Kurir.")
            }
        }
    }
}
