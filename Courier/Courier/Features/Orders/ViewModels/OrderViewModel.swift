import Foundation

@MainActor
final class OrderListViewModel: ObservableObject {
    @Published var orders: [Order] = []
    @Published var isLoading: Bool = false

    private let apiClient = APIClient.shared

    func fetchOrders() async {
        isLoading = true
        defer { isLoading = false }
        do {
            let result: [Order] = try await apiClient.request(.orders)
            orders = result
        } catch {
            // Handle silently for now
        }
    }
}

@MainActor
final class OrderDetailViewModel: ObservableObject {
    @Published var isUpdating: Bool = false
    @Published var errorMessage: String? = nil

    private let apiClient = APIClient.shared

    func updateStatus(orderId: String, newStatus: String) async {
        isUpdating = true
        defer { isUpdating = false }
        // TODO: Call update status API
    }
}
