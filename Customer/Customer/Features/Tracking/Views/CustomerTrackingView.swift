import SwiftUI

struct CustomerTrackingView: View {
    @State private var trackingCode: String = ""
    @State private var trackingResult: TrackingInfo? = nil
    @State private var isLoading: Bool = false
    @State private var errorMessage: String? = nil

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Search bar
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Lacak Paket")
                            .font(.headline)

                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundStyle(.secondary)
                            TextField("Masukkan kode order...", text: $trackingCode)
                                .autocorrectionDisabled()
                                .textInputAutocapitalization(.characters)
                            if !trackingCode.isEmpty {
                                Button { trackingCode = "" } label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 12))

                        Button {
                            Task { await track() }
                        } label: {
                            Group {
                                if isLoading {
                                    ProgressView().tint(.white)
                                } else {
                                    Text("Lacak Sekarang").font(.body.bold())
                                }
                            }
                            .frame(maxWidth: .infinity).padding()
                            .background(Color("CustomerPrimary"))
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        .disabled(trackingCode.isEmpty || isLoading)
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 20))

                    // Result
                    if let info = trackingResult {
                        TrackingResultView(info: info)
                    }

                    if let error = errorMessage {
                        Label(error, systemImage: "exclamationmark.triangle.fill")
                            .font(.subheadline).foregroundStyle(.red)
                    }
                }
                .padding()
            }
            .navigationTitle("Lacak Paket")
        }
    }

    private func track() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        // TODO: call track API
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        errorMessage = "Kode order tidak ditemukan."
    }
}

struct TrackingResultView: View {
    let info: TrackingInfo

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Status Pengiriman")
                .font(.headline)

            HStack {
                Image(systemName: "circle.fill")
                    .foregroundStyle(.green)
                    .font(.caption)
                Text(info.status.uppercased())
                    .font(.subheadline.bold())
                    .foregroundStyle(Color("CustomerPrimary"))
            }

            if let name = info.courierName {
                Label("Kurir: \(name)", systemImage: "person.fill")
                    .font(.subheadline)
            }

            if let eta = info.estimatedArrival {
                Label("Estimasi tiba: \(eta)", systemImage: "clock.fill")
                    .font(.subheadline)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}
