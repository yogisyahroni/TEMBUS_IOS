import Foundation

@MainActor
final class NotificationViewModel: ObservableObject {
    @Published var notifications: [AppNotification] = []
    @Published var isLoading: Bool = false
    @Published var unreadCount: Int = 0

    private let apiClient = APIClient.shared

    func fetchNotifications() async {
        isLoading = true
        defer { isLoading = false }
        do {
            let result: [AppNotification] = try await apiClient.request(.notifications)
            notifications = result
            unreadCount = result.filter { !$0.isRead }.count
        } catch {
            // Handle silently
        }
    }

    func markAllAsRead() async {
        do {
            // Fire-and-forget mark all
            let _: Bool = try await apiClient.request(.markAllRead, method: .patch)
            notifications = notifications.map { AppNotification(
                id: $0.id, title: $0.title, body: $0.body,
                isRead: true, category: $0.category, createdAt: $0.createdAt
            )}
            unreadCount = 0
        } catch {
            // Handle silently
        }
    }
}
