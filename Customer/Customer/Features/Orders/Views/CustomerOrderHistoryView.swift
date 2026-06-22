import SwiftUI

struct CustomerOrderHistoryView: View {
    @StateObject private var viewModel = CustomerOrderHistoryViewModel()

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.orders.isEmpty && !viewModel.isLoading {
                    ContentUnavailableView("Belum Ada Riwayat", systemImage: "list.bullet.rectangle",
                                          description: Text("Order yang sudah kamu buat akan muncul di sini."))
                } else {
                    List(viewModel.orders) { order in
                        CustomerOrderRowView(order: order)
                            .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Riwayat Order")
            .task { await viewModel.fetchOrders() }
            .refreshable { await viewModel.fetchOrders() }
        }
    }
}

struct CustomerOrderRowView: View {
    let order: CustomerOrder

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "shippingbox.fill")
                .foregroundStyle(Color("CustomerPrimary"))
                .font(.title3)
                .padding(10)
                .background(Color("CustomerPrimary").opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 10))

            VStack(alignment: .leading, spacing: 4) {
                Text(order.orderId)
                    .font(.caption.monospaced())
                    .foregroundStyle(.secondary)
                Text(order.recipientName ?? "Penerima tidak tersedia")
                    .font(.subheadline.bold())
                Text(order.status.uppercased())
                    .font(.caption2.bold())
                    .foregroundStyle(Color("CustomerPrimary"))
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}

@MainActor
final class CustomerOrderHistoryViewModel: ObservableObject {
    @Published var orders: [CustomerOrder] = []
    @Published var isLoading: Bool = false

    func fetchOrders() async {
        isLoading = true
        defer { isLoading = false }
        // TODO: fetch from API
    }
}
