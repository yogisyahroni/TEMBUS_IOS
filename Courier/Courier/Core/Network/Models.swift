import Foundation

// MARK: - Auth Models
struct LoginRequest: Encodable {
    let phone: String
    let password: String
}

struct LoginResponse: Decodable {
    let accessToken: String
    let refreshToken: String
    let courier: CourierProfile

    enum CodingKeys: String, CodingKey {
        case accessToken  = "access_token"
        case refreshToken = "refresh_token"
        case courier
    }
}

struct CourierProfile: Decodable, Identifiable {
    let id: String
    let name: String
    let phone: String
    let email: String?
    let profilePhotoUrl: String?
    let applicationChannel: String?
    let isActive: Bool?

    enum CodingKeys: String, CodingKey {
        case id, name, phone, email
        case profilePhotoUrl    = "profile_photo_url"
        case applicationChannel = "application_channel"
        case isActive           = "is_active"
    }
}

// MARK: - Order Models
struct Order: Decodable, Identifiable {
    let id: String
    let orderId: String
    let status: String
    let recipientName: String?
    let recipientPhone: String?
    let recipientAddress: String?
    let notes: String?
    let payoutIdr: Double?
    let createdAt: String?

    enum CodingKeys: String, CodingKey {
        case id, status, notes
        case orderId        = "order_id"
        case recipientName  = "recipient_name"
        case recipientPhone = "recipient_phone"
        case recipientAddress = "recipient_address"
        case payoutIdr      = "payout_idr"
        case createdAt      = "created_at"
    }
}

// MARK: - Notification Models
struct AppNotification: Decodable, Identifiable {
    let id: String
    let title: String
    let body: String
    let isRead: Bool
    let category: String?
    let createdAt: String

    enum CodingKeys: String, CodingKey {
        case id, title, body, category
        case isRead    = "is_read"
        case createdAt = "created_at"
    }
}

struct UnreadCountData: Decodable {
    let total: Int
    let byCategory: [String: Int]?

    enum CodingKeys: String, CodingKey {
        case total
        case byCategory = "by_category"
    }
}

// MARK: - Duty
struct DutyStatusResponse: Decodable {
    let isOnline: Bool

    enum CodingKeys: String, CodingKey {
        case isOnline = "is_online"
    }
}
