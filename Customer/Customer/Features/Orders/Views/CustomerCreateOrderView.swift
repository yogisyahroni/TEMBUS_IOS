import SwiftUI

struct CustomerCreateOrderView: View {
    @StateObject private var viewModel = CustomerCreateOrderViewModel()
    
    @State private var showingPickupPicker = false
    @State private var showingDropoffPicker = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    
                    // Lokasi Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Lokasi Pengiriman")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        VStack(spacing: 0) {
                            // Pickup
                            Button {
                                showingPickupPicker = true
                            } label: {
                                HStack(spacing: 16) {
                                    Image(systemName: "mappin.circle.fill")
                                        .foregroundStyle(.blue)
                                        .font(.title2)
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Lokasi Penjemputan")
                                            .font(.caption).foregroundStyle(.secondary)
                                        Text(viewModel.pickupLocation?.name ?? "Pilih lokasi penjemputan")
                                            .font(.subheadline.bold())
                                            .foregroundStyle(viewModel.pickupLocation == nil ? .secondary : .primary)
                                    }
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .font(.caption).foregroundStyle(.secondary)
                                }
                                .padding()
                            }
                            
                            Divider().padding(.leading, 48)
                            
                            // Dropoff
                            Button {
                                showingDropoffPicker = true
                            } label: {
                                HStack(spacing: 16) {
                                    Image(systemName: "mappin.and.ellipse")
                                        .foregroundStyle(.red)
                                        .font(.title2)
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Lokasi Tujuan")
                                            .font(.caption).foregroundStyle(.secondary)
                                        Text(viewModel.dropoffLocation?.name ?? "Pilih lokasi tujuan")
                                            .font(.subheadline.bold())
                                            .foregroundStyle(viewModel.dropoffLocation == nil ? .secondary : .primary)
                                    }
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .font(.caption).foregroundStyle(.secondary)
                                }
                                .padding()
                            }
                        }
                        .background(Color(.secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .padding(.horizontal)
                    }
                    
                    // Detail Paket
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Detail Paket")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        VStack(spacing: 16) {
                            // Kategori
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Kategori Barang").font(.caption.bold()).foregroundStyle(.secondary)
                                Menu {
                                    ForEach(viewModel.availableCategories, id: \.self) { category in
                                        Button(category) { viewModel.selectedCategory = category }
                                    }
                                } label: {
                                    HStack {
                                        Text(viewModel.selectedCategory)
                                            .foregroundStyle(.primary)
                                        Spacer()
                                        Image(systemName: "chevron.up.chevron.down")
                                            .foregroundStyle(.secondary)
                                    }
                                    .padding()
                                    .background(Color(.systemBackground))
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.gray.opacity(0.3), lineWidth: 1))
                                }
                            }
                            
                            // Berat
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Berat Barang (kg)").font(.caption.bold()).foregroundStyle(.secondary)
                                HStack {
                                    TextField("Contoh: 1.5", value: $viewModel.weight, format: .number)
                                        .keyboardType(.decimalPad)
                                    Text("kg").foregroundStyle(.secondary)
                                }
                                .padding()
                                .background(Color(.systemBackground))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.gray.opacity(0.3), lineWidth: 1))
                            }
                            
                            // Dimensi Opsional
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Dimensi (Opsional)").font(.caption.bold()).foregroundStyle(.secondary)
                                HStack(spacing: 12) {
                                    TextField("P", text: $viewModel.length)
                                    Text("x").foregroundStyle(.secondary)
                                    TextField("L", text: $viewModel.width)
                                    Text("x").foregroundStyle(.secondary)
                                    TextField("T", text: $viewModel.height)
                                    Text("cm").foregroundStyle(.secondary)
                                }
                                .keyboardType(.numberPad)
                                .multilineTextAlignment(.center)
                                .padding()
                                .background(Color(.systemBackground))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.gray.opacity(0.3), lineWidth: 1))
                            }
                        }
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .padding(.horizontal)
                    }
                    
                    // Layanan & Harga
                    if viewModel.isReadyForPricing {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Pilih Layanan")
                                .font(.headline)
                                .padding(.horizontal)
                            
                            if viewModel.isLoadingPrices {
                                ProgressView("Menghitung harga...")
                                    .frame(maxWidth: .infinity)
                                    .padding()
                            } else {
                                ForEach(viewModel.availableServices) { service in
                                    ServicePriceCard(
                                        service: service,
                                        isSelected: viewModel.selectedService?.id == service.id
                                    ) {
                                        viewModel.selectedService = service
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                    }
                    
                    Spacer(minLength: 100)
                }
                .padding(.vertical)
            }
            .navigationTitle("Kirim Paket")
            .navigationBarTitleDisplayMode(.inline)
            
            // Bottom Action
            .safeAreaInset(edge: .bottom) {
                if viewModel.selectedService != nil {
                    VStack(spacing: 8) {
                        HStack {
                            Text("Total Harga")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            Spacer()
                            Text(viewModel.selectedService?.formattedPrice ?? "Rp 0")
                                .font(.title3.bold())
                                .foregroundStyle(Color("CustomerPrimary"))
                        }
                        
                        Button {
                            Task { await viewModel.createOrder() }
                        } label: {
                            HStack {
                                if viewModel.isCreatingOrder {
                                    ProgressView().tint(.white)
                                } else {
                                    Text("Lanjutkan ke Pembayaran")
                                        .font(.body.bold())
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color("CustomerPrimary"))
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                        }
                        .disabled(viewModel.isCreatingOrder)
                    }
                    .padding()
                    .background(Color(.systemBackground).shadow(color: .black.opacity(0.1), radius: 10, y: -5))
                }
            }
            .sheet(isPresented: $showingPickupPicker) {
                CustomerLocationPickerView(mode: .pickup) { location in
                    viewModel.pickupLocation = location
                }
            }
            .sheet(isPresented: $showingDropoffPicker) {
                CustomerLocationPickerView(mode: .dropoff) { location in
                    viewModel.dropoffLocation = location
                }
            }
            // Navigate to Payment
            .navigationDestination(isPresented: $viewModel.showPayment) {
                if let orderId = viewModel.createdOrderId {
                    CustomerPaymentView(orderId: orderId)
                }
            }
        }
    }
}

struct ServicePriceCard: View {
    let service: DeliveryServicePricing
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: service.iconName)
                    .font(.title2)
                    .foregroundStyle(isSelected ? .white : Color("CustomerPrimary"))
                    .frame(width: 50, height: 50)
                    .background(isSelected ? Color("CustomerPrimary") : Color("CustomerPrimary").opacity(0.12))
                    .clipShape(Circle())
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(service.name)
                        .font(.headline)
                        .foregroundStyle(isSelected ? .white : .primary)
                    Text(service.estimatedTime)
                        .font(.caption)
                        .foregroundStyle(isSelected ? .white.opacity(0.8) : .secondary)
                }
                
                Spacer()
                
                Text(service.formattedPrice)
                    .font(.subheadline.bold())
                    .foregroundStyle(isSelected ? .white : .primary)
            }
            .padding()
            .background(isSelected ? Color("CustomerPrimaryDark") : Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(isSelected ? .clear : Color.gray.opacity(0.2), lineWidth: 1))
        }
        .buttonStyle(.plain)
    }
}

struct DeliveryServicePricing: Identifiable, Decodable {
    let id: String
    let name: String
    let estimatedTime: String
    let price: Double
    let iconName: String
    
    enum CodingKeys: String, CodingKey {
        case id, name, price
        case estimatedTime = "estimated_time"
        case iconName = "icon_name"
    }
    
    var formattedPrice: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "IDR"
        formatter.currencySymbol = "Rp "
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: price)) ?? "Rp \(price)"
    }
}

struct PricingEstimateResponse: Decodable {
    let estimateId: String
    let services: [DeliveryServicePricing]
    
    enum CodingKeys: String, CodingKey {
        case estimateId = "estimate_id"
        case services
    }
}

struct CreateOrderResponse: Decodable {
    let orderId: String
    
    enum CodingKeys: String, CodingKey {
        case orderId = "order_id"
    }
}

@MainActor
class CustomerCreateOrderViewModel: ObservableObject {
    @Published var pickupLocation: LocationDetail? {
        didSet { checkPricingReadiness() }
    }
    @Published var dropoffLocation: LocationDetail? {
        didSet { checkPricingReadiness() }
    }
    
    let availableCategories = ["Dokumen", "Makanan", "Pakaian", "Elektronik", "Pecah Belah", "Lainnya"]
    @Published var selectedCategory: String = "Dokumen"
    @Published var weight: Double? {
        didSet { checkPricingReadiness() }
    }
    
    @Published var length: String = ""
    @Published var width: String = ""
    @Published var height: String = ""
    
    @Published var isReadyForPricing = false
    @Published var isLoadingPrices = false
    @Published var availableServices: [DeliveryServicePricing] = []
    @Published var selectedService: DeliveryServicePricing?
    @Published var currentEstimateId: String?
    
    @Published var isCreatingOrder = false
    @Published var showPayment = false
    @Published var createdOrderId: String?
    
    private func checkPricingReadiness() {
        if pickupLocation != nil && dropoffLocation != nil && (weight ?? 0) > 0 {
            isReadyForPricing = true
            Task { await fetchPrices() }
        } else {
            isReadyForPricing = false
            availableServices = []
            selectedService = nil
        }
    }
    
    private func fetchPrices() async {
        guard let pickup = pickupLocation, let dropoff = dropoffLocation, let w = weight else { return }
        isLoadingPrices = true
        
        do {
            struct PricingRequest: Encodable {
                let pickupLat: Double
                let pickupLng: Double
                let dropoffLat: Double
                let dropoffLng: Double
                let length: Double
                let width: Double
                let height: Double
                let weight: Double
                
                enum CodingKeys: String, CodingKey {
                    case pickupLat = "pickup_lat"
                    case pickupLng = "pickup_lng"
                    case dropoffLat = "dropoff_lat"
                    case dropoffLng = "dropoff_lng"
                    case length, width, height, weight
                }
            }
            
            let req = PricingRequest(
                pickupLat: pickup.latitude, pickupLng: pickup.longitude,
                dropoffLat: dropoff.latitude, dropoffLng: dropoff.longitude,
                length: Double(length) ?? 10.0,
                width: Double(width) ?? 10.0,
                height: Double(height) ?? 10.0,
                weight: w
            )
            
            let body = try JSONEncoder().encode(req)
            let response: PricingEstimateResponse = try await NetworkManager.shared.request(
                APIEndpoint.baseURL + "/customer/orders/calculate",
                method: "POST",
                body: body
            )
            
            self.currentEstimateId = response.estimateId
            self.availableServices = response.services
            if !availableServices.isEmpty {
                self.selectedService = availableServices[0]
            }
        } catch {
            print("Failed to fetch prices: \(error)")
        }
        
        isLoadingPrices = false
    }
    
    func createOrder() async {
        guard let estimateId = currentEstimateId else { return }
        isCreatingOrder = true
        
        do {
            struct CreateOrderReq: Encodable {
                let estimateId: String
                let itemDescription: String
                
                enum CodingKeys: String, CodingKey {
                    case estimateId = "estimate_id"
                    case itemDescription = "item_description"
                }
            }
            
            let req = CreateOrderReq(estimateId: estimateId, itemDescription: selectedCategory)
            let body = try JSONEncoder().encode(req)
            
            let idempotencyKey = UUID().uuidString
            let response: CreateOrderResponse = try await NetworkManager.shared.request(
                APIEndpoint.baseURL + "/customer/orders",
                method: "POST",
                body: body,
                headers: ["Idempotency-Key": idempotencyKey]
            )
            
            createdOrderId = response.orderId
            showPayment = true
        } catch {
            print("Failed to create order: \(error)")
        }
        
        isCreatingOrder = false
    }
}

#Preview {
    CustomerCreateOrderView()
}
