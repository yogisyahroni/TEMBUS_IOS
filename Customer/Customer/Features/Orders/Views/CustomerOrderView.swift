import SwiftUI

struct CustomerOrderView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Hero card
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Kirim Paket")
                            .font(.title2.bold())
                        Text("Isi detail pengiriman dan dapatkan kurir terpercaya di area kamu.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)

                        Button {
                            // TODO: navigate to create order
                        } label: {
                            Label("Buat Pengiriman Baru", systemImage: "plus.circle.fill")
                                .font(.body.bold())
                                .frame(maxWidth: .infinity).padding()
                                .background(Color("CustomerPrimary"))
                                .foregroundStyle(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                        }
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .padding(.horizontal)

                    // Service types
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Layanan Pengiriman")
                            .font(.headline)
                            .padding(.horizontal)

                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                            ServiceCard(title: "Regular", subtitle: "1-2 Hari", icon: "shippingbox.fill", color: .blue)
                            ServiceCard(title: "Express", subtitle: "Hari Ini", icon: "bolt.fill", color: .orange)
                            ServiceCard(title: "Bulk", subtitle: "Banyak Paket", icon: "doc.on.doc.fill", color: .purple)
                            ServiceCard(title: "On-Demand", subtitle: "Segera", icon: "location.fill", color: Color("CustomerPrimary"))
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("Pesan Kirim")
        }
    }
}

struct ServiceCard: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)
                .padding()
                .background(color.opacity(0.12))
                .clipShape(Circle())
            Text(title).font(.subheadline.bold())
            Text(subtitle).font(.caption).foregroundStyle(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}
