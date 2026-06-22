import Foundation

@MainActor
final class HomeViewModel: ObservableObject {
    @Published var isOnline: Bool = false
    @Published var todayOrderCount: Int = 0
    @Published var completedToday: Int = 0
    @Published var pendingCount: Int = 0
    @Published var todayEarnings: Double = 0

    private let apiClient = APIClient.shared

    var todayEarningsFormatted: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "IDR"
        formatter.currencySymbol = "Rp"
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: todayEarnings)) ?? "Rp 0"
    }

    func refresh() async {
        // TODO: fetch from API
    }

    func toggleDuty() async {
        do {
            let _: DutyStatusResponse = try await apiClient.request(
                .toggleDuty,
                method: .post
            )
            isOnline.toggle()
        } catch {
            // handle error
        }
    }
}
