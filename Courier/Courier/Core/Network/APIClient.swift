import Foundation
import Combine

// MARK: - API Error
enum APIError: Error, LocalizedError {
    case invalidURL
    case unauthorized
    case serverError(Int, String)
    case decodingError(Error)
    case networkError(Error)
    case unknown

    var errorDescription: String? {
        switch self {
        case .invalidURL:                       return "URL tidak valid."
        case .unauthorized:                     return "Sesi kadaluarsa. Silakan login ulang."
        case .serverError(let code, let msg):   return "Error \(code): \(msg)"
        case .decodingError(let err):           return "Gagal memproses data: \(err.localizedDescription)"
        case .networkError(let err):            return err.localizedDescription
        case .unknown:                          return "Terjadi kesalahan yang tidak diketahui."
        }
    }
}

// MARK: - Generic API Response
struct APIResponse<T: Decodable>: Decodable {
    let success: Bool
    let message: String?
    let data: T?
}

// MARK: - API Client
final class APIClient {
    static let shared = APIClient()
    private let session: URLSession
    private let tokenStorage = TokenStorage.shared
    private var cancellables = Set<AnyCancellable>()

    private init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 60
        self.session = URLSession(configuration: config)
    }

    // MARK: - Core Request
    func request<T: Decodable>(
        _ endpoint: APIEndpoint,
        method: HTTPMethod = .get,
        body: Encodable? = nil
    ) async throws -> T {
        var urlRequest = URLRequest(url: endpoint.url)
        urlRequest.httpMethod = method.rawValue
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if let token = tokenStorage.accessToken {
            urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        if let body = body {
            urlRequest.httpBody = try JSONEncoder().encode(body)
        }

        let (data, response) = try await session.data(for: urlRequest)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.unknown
        }

        switch httpResponse.statusCode {
        case 200...299:
            do {
                let decoded = try JSONDecoder().decode(APIResponse<T>.self, from: data)
                guard let result = decoded.data else {
                    throw APIError.unknown
                }
                return result
            } catch {
                throw APIError.decodingError(error)
            }
        case 401:
            throw APIError.unauthorized
        default:
            let message = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw APIError.serverError(httpResponse.statusCode, message)
        }
    }
}

// MARK: - HTTP Method
enum HTTPMethod: String {
    case get    = "GET"
    case post   = "POST"
    case put    = "PUT"
    case patch  = "PATCH"
    case delete = "DELETE"
}
