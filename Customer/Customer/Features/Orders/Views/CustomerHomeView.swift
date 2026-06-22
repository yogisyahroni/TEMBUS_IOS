import SwiftUI

struct CustomerHomeView: View {
    @EnvironmentObject private var authViewModel: CustomerAuthViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Header / Greeting
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Halo, \(authViewModel.customerProfile?.name ?? "Pelanggan")!")
                                .font(.title2.bold())
                            Text("Mau kirim apa hari ini?")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        
                        // Wallet Balance or Points Placeholder
                        VStack(alignment: .trailing, spacing: 2) {
                            Text("Saldo T-Pay")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                            Text("Rp 0")
                                .font(.headline.bold())
                                .foregroundStyle(Color("CustomerPrimary"))
                        }
                        .padding(12)
                        .background(Color(.secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)

                    // Hero card / Call to action
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Kirim Paket Sekarang")
                                    .font(.title3.bold())
                                Text("Aman, Cepat, dan Terpercaya.")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            Image(systemName: "box.truck.fill")
                                .font(.system(size: 40))
                                .foregroundStyle(Color("CustomerPrimary"))
                        }

                        NavigationLink {
                            CustomerCreateOrderView()
                        } label: {
                            HStack {
                                Text("Buat Pesanan Baru")
                                    .font(.body.bold())
                                Spacer()
                                Image(systemName: "arrow.right.circle.fill")
                                    .font(.title3)
                            }
                            .padding()
                            .background(Color("CustomerPrimary"))
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                        }
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .shadow(color: .black.opacity(0.05), radius: 10, y: 5)
                    .padding(.horizontal)

                    // Layanan Tersedia (Service Config)
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Layanan Kami")
                            .font(.headline)
                            .padding(.horizontal)

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                ServiceTypeCard(title: "Motor", subtitle: "Kecil & Cepat", icon: "bicycle", color: .orange)
                                ServiceTypeCard(title: "Mobil", subtitle: "Besar & Aman", icon: "car.fill", color: .blue)
                                ServiceTypeCard(title: "Same Day", subtitle: "Hari ini sampai", icon: "clock.fill", color: .purple)
                            }
                            .padding(.horizontal)
                        }
                    }

                    // Promo / Banner Banner
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Promo & Info")
                            .font(.headline)
                            .padding(.horizontal)

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                PromoCard(title: "Diskon 50% Ongkir", subtitle: "Khusus pengguna baru", gradientColors: [.orange, .red])
                                PromoCard(title: "Kirim Banyak, Lebih Hemat", subtitle: "Cek paket bulk kita", gradientColors: [.blue, .purple])
                            }
                            .padding(.horizontal)
                        }
                    }
                    
                    Spacer(minLength: 40)
                }
                .padding(.vertical)
            }
            .navigationTitle("Beranda")
            .navigationBarTitleDisplayMode(.inline)
            // Sembunyikan navigasi default di Home
            .toolbar(.hidden, for: .navigationBar)
        }
    }
}

struct ServiceTypeCard: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Image(systemName: icon)
                .font(.title)
                .foregroundStyle(color)
                .padding(12)
                .background(color.opacity(0.12))
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title).font(.subheadline.bold())
                Text(subtitle).font(.caption).foregroundStyle(.secondary)
            }
        }
        .padding()
        .frame(width: 140, alignment: .leading)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 8, y: 4)
    }
}

struct PromoCard: View {
    let title: String
    let subtitle: String
    let gradientColors: [Color]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline.bold())
                .foregroundStyle(.white)
            Text(subtitle)
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.9))
        }
        .padding(20)
        .frame(width: 280, height: 120, alignment: .bottomLeading)
        .background(
            LinearGradient(colors: gradientColors, startPoint: .topLeading, endPoint: .bottomTrailing)
        )
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: gradientColors.last?.opacity(0.3) ?? .clear, radius: 10, y: 5)
    }
}

#Preview {
    CustomerHomeView()
        .environmentObject(CustomerAuthViewModel())
}
