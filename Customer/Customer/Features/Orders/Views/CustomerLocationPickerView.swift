import SwiftUI
import MapKit

struct CustomerLocationPickerView: View {
    @Environment(\.dismiss) private var dismiss
    
    enum PickerMode {
        case pickup
        case dropoff
    }
    
    let mode: PickerMode
    let onLocationSelected: (LocationDetail) -> Void
    
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: -6.2088, longitude: 106.8456), // Default Jakarta
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    
    @State private var searchQuery: String = ""
    @State private var isSearching: Bool = false
    @State private var searchResults: [LocationDetail] = []
    
    @State private var selectedLocationName: String = "Pilih lokasi di peta"
    @State private var selectedAddressDetail: String = "Geser peta untuk menentukan titik"
    @State private var isLoadingAddress: Bool = false

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                // Map Background
                Map(coordinateRegion: $region, interactionModes: .all, showsUserLocation: true)
                    .ignoresSafeArea()
                    .onChange(of: region.center.latitude) { _ in
                        debouncedReverseGeocode()
                    }
                    .onChange(of: region.center.longitude) { _ in
                        debouncedReverseGeocode()
                    }
                
                // Center Pin
                VStack {
                    Spacer()
                    Image(systemName: mode == .pickup ? "mappin.circle.fill" : "mappin.and.ellipse")
                        .font(.system(size: 44))
                        .foregroundStyle(mode == .pickup ? .blue : .red)
                        .padding(.bottom, 44) // Offset for pin point
                    Spacer()
                }
                .allowsHitTesting(false)
                
                // Top Search Bar
                VStack {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundStyle(.secondary)
                        TextField("Cari lokasi atau alamat...", text: $searchQuery)
                            .onSubmit {
                                performSearch()
                            }
                        if !searchQuery.isEmpty {
                            Button {
                                searchQuery = ""
                                searchResults.removeAll()
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
                    
                    if !searchResults.isEmpty {
                        List(searchResults) { result in
                            Button {
                                selectSearchResult(result)
                            } label: {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(result.name).font(.subheadline.bold())
                                    Text(result.address).font(.caption).foregroundStyle(.secondary)
                                }
                                .padding(.vertical, 4)
                            }
                        }
                        .listStyle(.plain)
                        .background(Color(.systemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .padding(.horizontal)
                        .frame(maxHeight: 250)
                    }
                    
                    Spacer()
                }
                
                // Bottom Panel
                VStack(spacing: 16) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(mode == .pickup ? "Lokasi Penjemputan" : "Lokasi Tujuan")
                            .font(.caption.bold())
                            .foregroundStyle(.secondary)
                        
                        if isLoadingAddress {
                            ProgressView()
                                .frame(maxWidth: .infinity, alignment: .leading)
                        } else {
                            Text(selectedLocationName)
                                .font(.headline)
                            Text(selectedAddressDetail)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .lineLimit(2)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Button {
                        let finalLocation = LocationDetail(
                            id: UUID().uuidString,
                            name: selectedLocationName,
                            address: selectedAddressDetail,
                            latitude: region.center.latitude,
                            longitude: region.center.longitude
                        )
                        onLocationSelected(finalLocation)
                        dismiss()
                    } label: {
                        Text("Konfirmasi Lokasi")
                            .font(.body.bold())
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(isLoadingAddress ? Color.gray : Color("CustomerPrimary"))
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                    .disabled(isLoadingAddress)
                }
                .padding()
                .background(Color(.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 24))
                .shadow(color: .black.opacity(0.15), radius: 10, y: -5)
                .ignoresSafeArea(edges: .bottom)
            }
            .navigationTitle(mode == .pickup ? "Pilih Penjemputan" : "Pilih Tujuan")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Batal") { dismiss() }
                }
            }
        }
    }
    
    // Stub methods for Geocoding APIs (In real app, calls /api/v1/maps/reverse-geocode)
    private func debouncedReverseGeocode() {
        // Normally use a Combine Publisher or Task to debounce
        Task {
            isLoadingAddress = true
            try? await Task.sleep(nanoseconds: 500_000_000) // 0.5s debounce simulation
            // Fake reverse geocode result
            selectedLocationName = "Titik Pilihan"
            selectedAddressDetail = "Lat: \(String(format: "%.4f", region.center.latitude)), Lon: \(String(format: "%.4f", region.center.longitude))"
            isLoadingAddress = false
        }
    }
    
    private func performSearch() {
        // Mock search
        isSearching = true
        searchResults = [
            LocationDetail(id: "1", name: "Monas", address: "Gambir, Jakarta Pusat", latitude: -6.1754, longitude: 106.8272),
            LocationDetail(id: "2", name: "Bundaran HI", address: "Menteng, Jakarta Pusat", latitude: -6.1950, longitude: 106.8230)
        ]
        isSearching = false
    }
    
    private func selectSearchResult(_ result: LocationDetail) {
        region.center = CLLocationCoordinate2D(latitude: result.latitude, longitude: result.longitude)
        selectedLocationName = result.name
        selectedAddressDetail = result.address
        searchResults.removeAll()
        searchQuery = ""
    }
}

// Data Model
struct LocationDetail: Identifiable {
    let id: String
    let name: String
    let address: String
    let latitude: Double
    let longitude: Double
}

#Preview {
    CustomerLocationPickerView(mode: .pickup) { _ in }
}
