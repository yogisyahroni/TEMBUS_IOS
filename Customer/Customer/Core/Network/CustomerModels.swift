import Foundation

// MARK: - Customer API Config
enum CustomerAPIConfig {
    static let baseURL = "https://api.tembus.id/api/v1"
}

enum CustomerAPIEndpoint {
    case login
    case logout
    case register
    case customerProfile
    case orders
    case orderDetail(id: String)
    case createOrder
    case trackOrder(id: String)
    case paymentLinks

    var path: String {
        switch self {
        case .login:                        return "/customer/auth/login"
        case .logout:                       return "/customer/auth/logout"
        case .register:                     return "/customer/auth/register"
        case .customerProfile:              return "/customer/profile"
        case .orders:                       return "/customer/orders"
        case .orderDetail(let id):          return "/customer/orders/\(id)"
        case .createOrder:                  return "/customer/orders"
        case .trackOrder(let id):           return "/customer/orders/\(id)/track"
        case .paymentLinks:                 return "/customer/payment-links"
        }
    }

    var url: URL { URL(string: CustomerAPIConfig.baseURL + path)! }
}

// MARK: - Customer Models
struct CustomerLoginRequest: Encodable {
    let email: String
    let password: String
}

struct CustomerAuthResponse: Decodable {
    let accessToken: String
    let refreshToken: String
    let customer: CustomerProfile

    enum CodingKeys: String, CodingKey {
        case accessToken  = "access_token"
        case refreshToken = "refresh_token"
        case customer
    }
}

struct CustomerProfile: Decodable, Identifiable {
    let id: String
    let name: String
    let email: String
    let phone: String?
    let profilePhotoUrl: String?

    enum CodingKeys: String, CodingKey {
        case id, name, email, phone
        case profilePhotoUrl = "profile_photo_url"
    }
}

struct CustomerOrder: Decodable, Identifiable {
    let id: String
    let orderId: String
    let status: String
    let recipientName: String?
    let recipientAddress: String?
    let totalCost: Double?
    let createdAt: String?

    enum CodingKeys: String, CodingKey {
        case id, status
        case orderId        = "order_id"
        case recipientName  = "recipient_name"
        case recipientAddress = "recipient_address"
        case totalCost      = "total_cost"
        case createdAt      = "created_at"
    }
}

struct TrackingInfo: Decodable {
    let status: String
    let courierName: String?
    let courierPhone: String?
    let estimatedArrival: String?
    let lastUpdated: String?

    enum CodingKeys: String, CodingKey {
        case status
        case courierName  = "courier_name"
        case courierPhone = "courier_phone"
        case estimatedArrival = "estimated_arrival"
        case lastUpdated  = "last_updated"
    }
}
