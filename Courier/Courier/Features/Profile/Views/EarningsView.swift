import SwiftUI

struct EarningsView: View {
    @State private var filterSegment = 0
    let filters = ["Hari Ini", "Minggu Ini", "Bulan Ini"]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Picker("Periode", selection: $filterSegment) {
                    ForEach(0..<filters.count, id: \.self) { index in
                        Text(filters[index]).tag(index)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                
                // Total earnings
                VStack(spacing: 8) {
                    Text("Total Penghasilan")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    
                    Text(dummyEarnings(for: filterSegment))
                        .font(.system(size: 40, weight: .bold, design: .rounded))
                        .foregroundStyle(Color("Primary"))
                }
                .padding(.vertical, 20)
                
                // Details breakdown
                VStack(spacing: 0) {
                    EarningRow(title: "Biaya Pengiriman", value: "Rp 150.000", isPositive: true)
                    Divider()
                    EarningRow(title: "Tips Pelanggan", value: "Rp 20.000", isPositive: true)
                    Divider()
                    EarningRow(title: "Potongan Platform", value: "- Rp 17.000", isPositive: false)
                }
                .padding()
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .padding(.horizontal)
                
                // Recent transactions
                VStack(alignment: .leading, spacing: 12) {
                    Text("Riwayat Terakhir")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    VStack(spacing: 0) {
                        ForEach(1...5, id: \.self) { i in
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Order #TB-100\(i)")
                                        .font(.subheadline.bold())
                                    Text("Selesai pada 10:\(String(format: "%02d", i * 10))")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                                Text("+ Rp 30.000")
                                    .font(.subheadline.bold())
                                    .foregroundStyle(.green)
                            }
                            .padding()
                            if i < 5 { Divider() }
                        }
                    }
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .padding(.horizontal)
                }
            }
            .padding(.vertical)
        }
        .navigationTitle("Penghasilan")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func dummyEarnings(for index: Int) -> String {
        switch index {
        case 0: return "Rp 153.000"
        case 1: return "Rp 850.000"
        case 2: return "Rp 3.450.000"
        default: return "Rp 0"
        }
    }
}

struct EarningRow: View {
    let title: String
    let value: String
    let isPositive: Bool
    
    var body: some View {
        HStack {
            Text(title)
                .font(.subheadline)
            Spacer()
            Text(value)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(isPositive ? Color.primary : Color.red)
        }
        .padding(.vertical, 12)
    }
}
