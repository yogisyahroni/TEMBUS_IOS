import SwiftUI

struct OrderListView: View {
    @StateObject private var viewModel = OrderListViewModel()

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading && viewModel.orders.isEmpty {
                    ProgressView("Memuat order...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if viewModel.orders.isEmpty {
                    ContentUnavailableView(
                        "Belum Ada Order",
                        systemImage: "shippingbox",
                        description: Text("Order baru akan muncul di sini.")
                    )
                } else {
                    List(viewModel.orders) { order in
                        NavigationLink(destination: OrderDetailView(order: order)) {
                            OrderRowView(order: order)
                        }
                        .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Daftar Order")
            .task { await viewModel.fetchOrders() }
            .refreshable { await viewModel.fetchOrders() }
        }
    }
}

struct OrderRowView: View {
    let order: Order

    var statusColor: Color {
        switch order.status.lowercased() {
        case "pending":     return .orange
        case "accepted":    return .blue
        case "picked_up":   return .purple
        case "in_transit":  return Color("Primary")
        case "delivered":   return .green
        case "cancelled":   return .red
        default:            return .gray
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(order.orderId)
                    .font(.caption.monospaced())
                    .foregroundStyle(.secondary)
                Spacer()
                Text(order.status.uppercased())
                    .font(.caption2.bold())
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(statusColor.opacity(0.15))
                    .foregroundStyle(statusColor)
                    .clipShape(Capsule())
            }

            Text(order.recipientName ?? "Nama tidak tersedia")
                .font(.subheadline.bold())

            if let address = order.recipientAddress {
                Label(address, systemImage: "location.fill")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}
