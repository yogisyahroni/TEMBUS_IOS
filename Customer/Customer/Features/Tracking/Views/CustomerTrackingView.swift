import SwiftUI
import MapKit
import Combine

struct CustomerTrackingView: View {
    @StateObject private var viewModel = CustomerTrackingViewModel()
    @State private var trackingCode: String = ""

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                // Tracking Map (Live)
                Map(
                    coordinateRegion: .constant(MKCoordinateRegion(
                        center: viewModel.courierLocation ?? CLLocationCoordinate2D(latitude: -6.2088, longitude: 106.8456),
                        span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
                    )),
                    annotationItems: viewModel.mapAnnotations
                ) { annotation in
                    MapAnnotation(coordinate: annotation.coordinate) {
                        Image(systemName: annotation.isCourier ? "box.truck.fill" : "mappin.circle.fill")
                            .font(.title)
                            .foregroundStyle(annotation.isCourier ? .green : .blue)
                            .background(Circle().fill(.white).frame(width: 40, height: 40).shadow(radius: 4))
                    }
                }
                .ignoresSafeArea()
                
                // Top Search Bar (Floating)
                VStack {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundStyle(.secondary)
                        TextField("Masukkan kode order...", text: $trackingCode)
                            .autocorrectionDisabled()
                            .textInputAutocapitalization(.characters)
                            .onSubmit {
                                Task { await viewModel.trackOrder(code: trackingCode) }
                            }
                        if !trackingCode.isEmpty {
                            Button {
                                trackingCode = ""
                                viewModel.trackingResult = nil
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .shadow(color: .black.opacity(0.1), radius: 5, y: 2)
                    .padding()
                    
                    if viewModel.isLoading {
                        ProgressView()
                            .padding()
                            .background(Color(.systemBackground))
                            .clipShape(Circle())
                            .shadow(radius: 5)
                    } else if let error = viewModel.errorMessage {
                        Text(error)
                            .font(.caption)
                            .padding()
                            .background(Color.red.opacity(0.8))
                            .foregroundStyle(.white)
                            .clipShape(Capsule())
                    }
                    
                    Spacer()
                }

                // Bottom Panel (Courier Info & Actions)
                if let info = viewModel.trackingResult {
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Status Pengiriman").font(.subheadline).foregroundStyle(.secondary)
                                Text(info.status.uppercased()).font(.headline.bold()).foregroundStyle(Color("CustomerPrimary"))
                            }
                            Spacer()
                            VStack(alignment: .trailing, spacing: 4) {
                                Text("Estimasi").font(.subheadline).foregroundStyle(.secondary)
                                Text(info.estimatedArrival ?? "--").font(.headline.bold())
                            }
                        }
                        
                        Divider()
                        
                        HStack(spacing: 16) {
                            Image(systemName: "person.crop.circle.fill")
                                .font(.system(size: 40))
                                .foregroundStyle(.gray)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(info.courierName ?? "Mencari Kurir...")
                                    .font(.headline)
                                Text(info.vehiclePlate ?? "")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                            
                            Spacer()
                            
                            if info.courierName != nil {
                                Button {
                                    // Buka layar chat
                                    viewModel.showChat = true
                                } label: {
                                    Image(systemName: "message.fill")
                                        .font(.title3)
                                        .foregroundStyle(.white)
                                        .padding(12)
                                        .background(Color.blue)
                                        .clipShape(Circle())
                                }
                                
                                Button {
                                    // Panggilan In-App WebRTC
                                    viewModel.showCall = true
                                } label: {
                                    Image(systemName: "phone.fill")
                                        .font(.title3)
                                        .foregroundStyle(.white)
                                        .padding(12)
                                        .background(Color.green)
                                        .clipShape(Circle())
                                }
                            }
                        }
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 24))
                    .shadow(color: .black.opacity(0.15), radius: 10, y: -5)
                    .ignoresSafeArea(edges: .bottom)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 24)
                }
            }
            .navigationTitle("Lacak Paket")
            .navigationBarTitleDisplayMode(.inline)
            // Sheet untuk Chat & Call
            .sheet(isPresented: $viewModel.showChat) {
                if let orderId = viewModel.trackingResult?.id {
                    CustomerChatView(orderId: orderId)
                        .presentationDetents([.medium, .large])
                }
            }
            .fullScreenCover(isPresented: $viewModel.showCall) {
                if let orderId = viewModel.trackingResult?.id {
                    CustomerCallView(orderId: orderId)
                }
            }
        }
        .onDisappear {
            viewModel.disconnectSocket()
        }
    }
}

// Map Annotation Model
struct TrackingAnnotation: Identifiable {
    let id: String
    let coordinate: CLLocationCoordinate2D
    let isCourier: Bool
}

// ViewModel & Socket Mock Logic
@MainActor
class CustomerTrackingViewModel: ObservableObject {
    @Published var trackingResult: CustomerTrackingInfo?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    
    @Published var courierLocation: CLLocationCoordinate2D?
    @Published var dropoffLocation: CLLocationCoordinate2D?
    
    @Published var showChat = false
    @Published var showCall = false
    
    private var cancellables = Set<AnyCancellable>()
    
    var mapAnnotations: [TrackingAnnotation] {
        var annotations: [TrackingAnnotation] = []
        if let drop = dropoffLocation {
            annotations.append(TrackingAnnotation(id: "drop", coordinate: drop, isCourier: false))
        }
        if let courier = courierLocation {
            annotations.append(TrackingAnnotation(id: "courier", coordinate: courier, isCourier: true))
        }
        return annotations
    }
    
    func trackOrder(code: String) async {
        guard !code.isEmpty else { return }
        isLoading = true
        errorMessage = nil
        
        do {
            let response: TrackingDetailResponse = try await NetworkManager.shared.request(
                APIEndpoint.baseURL + "/customer/orders/\(code)/tracking-detail",
                method: "GET"
            )
            
            let order = response.order
            
            self.trackingResult = CustomerTrackingInfo(
                id: order.id,
                status: order.status,
                courierName: order.courier_name,
                vehiclePlate: order.courier_plate,
                estimatedArrival: response.tracking?.eta_minutes != nil ? "\(response.tracking!.eta_minutes!) Menit" : "--"
            )
            
            if let dLat = order.dropoff_address?.lat, let dLng = order.dropoff_address?.lng {
                self.dropoffLocation = CLLocationCoordinate2D(latitude: dLat, longitude: dLng)
            }
            
            if let cLat = response.tracking?.courier_location?.latitude, let cLng = response.tracking?.courier_location?.longitude {
                self.courierLocation = CLLocationCoordinate2D(latitude: cLat, longitude: cLng)
            }
            
            connectSocketAndListen(orderId: order.id)
            
        } catch {
            print("Failed to track order: \(error)")
            self.errorMessage = "Gagal memuat status pengiriman. Pastikan kode benar."
            self.trackingResult = nil
        }
        
        isLoading = false
    }
    
    func connectSocketAndListen(orderId: String) {
        WebSocketManager.shared.connect()
        WebSocketManager.shared.joinOrderRoom(orderId: orderId)
        
        WebSocketManager.shared.trackingUpdatePublisher
            .sink { [weak self] payload in
                guard payload.order_id == orderId, let loc = payload.location else { return }
                self?.courierLocation = CLLocationCoordinate2D(latitude: loc.latitude, longitude: loc.longitude)
            }
            .store(in: &cancellables)
    }
    
    func disconnectSocket() {
        WebSocketManager.shared.disconnect()
        cancellables.removeAll()
    }
}

// Extracted existing TrackingInfo
struct CustomerTrackingInfo: Identifiable {
    let id: String
    let status: String
    let courierName: String?
    let vehiclePlate: String?
    let estimatedArrival: String?
}

// Data models for API Response
struct TrackingDetailResponse: Decodable {
    let order: OrderDetailData
    let tracking: TrackingData?
}

struct OrderDetailData: Decodable {
    let id: String
    let order_number: String
    let status: String
    let courier_name: String?
    let courier_vehicle: String?
    let courier_plate: String?
    let dropoff_address: LocationData?
}

struct LocationData: Decodable {
    let lat: Double?
    let lng: Double?
}

struct TrackingData: Decodable {
    let courier_location: CourierLocationData?
    let eta_minutes: Int?
}

struct CourierLocationData: Decodable {
    let latitude: Double?
    let longitude: Double?
}

#Preview {
    CustomerTrackingView()
}
