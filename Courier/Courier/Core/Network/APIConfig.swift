import Foundation

// MARK: - API Base
enum APIConfig {
    static let baseURL = "https://api.tembus.id/api/v1"
    static let wsURL   = "wss://api.tembus.id"
}

// MARK: - Endpoints
enum APIEndpoint {
    // Auth
    case login
    case logout
    case refreshToken
    case courierProfile

    // Orders
    case orders
    case orderDetail(id: String)
    case updateOrderStatus(id: String)

    // Notifications
    case notifications
    case notificationsUnreadCount
    case markAllRead
    case markRead(id: String)

    // Duty
    case dutyStatus
    case toggleDuty

    var path: String {
        switch self {
        case .login:                        return "/mobile/auth/login"
        case .logout:                       return "/mobile/auth/logout"
        case .refreshToken:                 return "/mobile/auth/refresh"
        case .courierProfile:               return "/mobile/profile"
        case .orders:                       return "/mobile/orders"
        case .orderDetail(let id):          return "/mobile/orders/\(id)"
        case .updateOrderStatus(let id):    return "/mobile/orders/\(id)/status"
        case .notifications:                return "/mobile/notifications"
        case .notificationsUnreadCount:     return "/mobile/notifications/unread-count"
        case .markAllRead:                  return "/mobile/notifications/read-all"
        case .markRead(let id):             return "/mobile/notifications/\(id)/read"
        case .dutyStatus:                   return "/mobile/duty"
        case .toggleDuty:                   return "/mobile/duty/toggle"
        }
    }

    var url: URL {
        URL(string: APIConfig.baseURL + path)!
    }
}
