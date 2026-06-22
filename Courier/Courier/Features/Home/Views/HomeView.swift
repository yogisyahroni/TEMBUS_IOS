import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var authViewModel: AuthViewModel
    @StateObject private var viewModel = HomeViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Header greeting
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Selamat datang,")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            Text(authViewModel.courierProfile?.name ?? "Kurir")
                                .font(.title2.bold())
                        }
                        Spacer()
                        // Duty toggle
                        Toggle("", isOn: $viewModel.isOnline)
                            .labelsHidden()
                            .tint(Color("Primary"))
                    }
                    .padding(.horizontal)

                    // Status banner
                    HStack {
                        Image(systemName: viewModel.isOnline ? "circle.fill" : "circle")
                            .foregroundStyle(viewModel.isOnline ? .green : .gray)
                        Text(viewModel.isOnline ? "On Duty — Siap menerima order" : "Off Duty")
                            .font(.subheadline.weight(.medium))
                        Spacer()
                    }
                    .padding()
                    .background(
                        (viewModel.isOnline ? Color.green : Color.gray).opacity(0.12)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding(.horizontal)

                    // Stats summary
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                        StatCard(title: "Order Hari Ini", value: "\(viewModel.todayOrderCount)", icon: "shippingbox.fill", color: .blue)
                        StatCard(title: "Selesai", value: "\(viewModel.completedToday)", icon: "checkmark.circle.fill", color: .green)
                        StatCard(title: "Pending", value: "\(viewModel.pendingCount)", icon: "clock.fill", color: .orange)
                        StatCard(title: "Penghasilan", value: viewModel.todayEarningsFormatted, icon: "banknote.fill", color: Color("Primary"))
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .navigationTitle("TEMBUS Kurir")
            .navigationBarTitleDisplayMode(.inline)
            .refreshable {
                await viewModel.refresh()
            }
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(color)
            Text(value)
                .font(.title2.bold())
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}
