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
    case getChats(orderId: String)
    case sendChat(orderId: String)

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
        case .login:                        return "/auth/courier/login"
        case .logout:                       return "/auth/courier/logout"
        case .refreshToken:                 return "/auth/courier/refresh"
        case .courierProfile:               return "/courier/profile"
        case .orders:                       return "/courier/orders"
        case .orderDetail(let id):          return "/courier/orders/\(id)"
        case .updateOrderStatus(let id):    return "/orders/status"
        case .getChats(let orderId):        return "/courier/orders/\(orderId)/chats"
        case .sendChat(let orderId):        return "/courier/orders/\(orderId)/chats"
        case .notifications:                return "/mobile/notifications"
        case .notificationsUnreadCount:     return "/mobile/notifications/unread-count"
        case .markAllRead:                  return "/mobile/notifications/read-all"
        case .markRead(let id):             return "/mobile/notifications/\(id)/read"
        case .dutyStatus:                   return "/courier/duty"
        case .toggleDuty:                   return "/courier/duty"
        }
    }

    var url: URL {
        URL(string: APIConfig.baseURL + path)!
    }
}
