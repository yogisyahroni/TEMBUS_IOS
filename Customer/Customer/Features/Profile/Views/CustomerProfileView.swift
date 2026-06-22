import SwiftUI

struct CustomerProfileView: View {
    @EnvironmentObject private var authViewModel: CustomerAuthViewModel
    @State private var showLogoutConfirm: Bool = false

    var body: some View {
        NavigationStack {
            List {
                Section {
                    HStack(spacing: 16) {
                        ZStack {
                            Circle().fill(Color("CustomerPrimary").opacity(0.15)).frame(width: 60, height: 60)
                            Image(systemName: "person.fill").font(.title2).foregroundStyle(Color("CustomerPrimary"))
                        }
                        VStack(alignment: .leading, spacing: 2) {
                            Text(authViewModel.customerProfile?.name ?? "Pelanggan TEMBUS")
                                .font(.headline)
                            Text(authViewModel.customerProfile?.email ?? "-")
                                .font(.subheadline).foregroundStyle(.secondary)
                        }
                    }
                    .padding(.vertical, 4)
                }

                Section("Akun") {
                    NavigationLink {
                        CustomerAddressBookView()
                    } label: {
                        Label("Alamat Tersimpan", systemImage: "mappin.circle.fill")
                    }
                    Label("Metode Pembayaran", systemImage: "creditcard.fill")
                    Label("Notifikasi", systemImage: "bell.fill")
                }

                Section("Bantuan") {
                    Label("Pusat Bantuan", systemImage: "questionmark.circle.fill")
                    Label("Hubungi CS", systemImage: "headphones")
                    Label("Tentang TEMBUS", systemImage: "info.circle.fill")
                }

                Section {
                    Button(role: .destructive) { showLogoutConfirm = true } label: {
                        Label("Keluar", systemImage: "rectangle.portrait.and.arrow.right")
                    }
                }
            }
            .navigationTitle("Profil")
            .confirmationDialog("Keluar dari akun?", isPresented: $showLogoutConfirm, titleVisibility: .visible) {
                Button("Keluar", role: .destructive) { authViewModel.logout() }
                Button("Batal", role: .cancel) {}
            } message: {
                Text("Kamu akan keluar dari aplikasi TEMBUS.")
            }
        }
    }
}
