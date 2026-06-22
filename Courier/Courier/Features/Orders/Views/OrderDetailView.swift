import SwiftUI

struct OrderDetailView: View {
    let order: Order
    @StateObject private var viewModel = OrderDetailViewModel()
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Status badge
                HStack {
                    Spacer()
                    Text(order.status.uppercased())
                        .font(.subheadline.bold())
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color("Primary").opacity(0.15))
                        .foregroundStyle(Color("Primary"))
                        .clipShape(Capsule())
                    Spacer()
                }

                // Info sections
                InfoSection(title: "Penerima") {
                    InfoRow(label: "Nama", value: order.recipientName ?? "-")
                    InfoRow(label: "Telepon", value: order.recipientPhone ?? "-")
                    InfoRow(label: "Alamat", value: order.recipientAddress ?? "-")
                }

                if let notes = order.notes, !notes.isEmpty {
                    InfoSection(title: "Catatan") {
                        Text(notes)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }

                // Action buttons
                VStack(spacing: 12) {
                    if order.status.lowercased() == "accepted" {
                        ActionButton(title: "Konfirmasi Pickup", icon: "cube.box.fill", color: .orange) {
                            Task { await viewModel.updateStatus(orderId: order.orderId, newStatus: "picked_up") }
                        }
                    }
                    if order.status.lowercased() == "picked_up" {
                        ActionButton(title: "Mulai Pengiriman", icon: "car.fill", color: Color("Primary")) {
                            Task { await viewModel.updateStatus(orderId: order.orderId, newStatus: "in_transit") }
                        }
                    }
                    if order.status.lowercased() == "in_transit" {
                        ActionButton(title: "Konfirmasi Terkirim", icon: "checkmark.circle.fill", color: .green) {
                            Task { await viewModel.updateStatus(orderId: order.orderId, newStatus: "delivered") }
                        }
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Detail Order")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct InfoSection<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
            content
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

struct InfoRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack(alignment: .top) {
            Text(label)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
                .frame(width: 80, alignment: .leading)
            Text(value)
                .font(.subheadline)
        }
    }
}

struct ActionButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Label(title, systemImage: icon)
                .font(.body.bold())
                .frame(maxWidth: .infinity)
                .padding()
                .background(color)
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 14))
        }
    }
}
