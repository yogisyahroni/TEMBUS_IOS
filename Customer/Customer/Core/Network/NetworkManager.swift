import Foundation

enum NetworkError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case httpError(statusCode: Int, message: String)
    case decodingError(Error)
    case unknown(Error)
    case unauthorized
    
    var errorDescription: String? {
        switch self {
        case .invalidURL: return "URL tidak valid."
        case .invalidResponse: return "Respons server tidak valid."
        case .httpError(let code, let msg): return "HTTP Error \(code): \(msg)"
        case .decodingError(let err): return "Gagal memproses data: \(err.localizedDescription)"
        case .unknown(let err): return "Terjadi kesalahan: \(err.localizedDescription)"
        case .unauthorized: return "Sesi telah berakhir. Silakan login kembali."
        }
    }
}

struct BaseResponse<T: Decodable>: Decodable {
    let success: Bool
    let message: String
    let data: T?
}

struct APIEndpoint {
    // Sesuaikan BASE_URL dengan IP Gateway atau Domain Production
    static let baseURL = "https://api.tembus.id/api/v1"
    
    // Auth Customer
    static let customerGoogleLogin = baseURL + "/auth/customer/google"
    static let customerOTPVerify = baseURL + "/auth/customer/otp/verify"
    
    // Orders Customer
    static let orderPrice = baseURL + "/orders/price"
    static let createOrder = baseURL + "/orders"
    static func orderPayment(id: String) -> String { baseURL + "/orders/\(id)/payment" }
    static let orderHistory = baseURL + "/orders/history"
    static func getChats(orderId: String) -> String { baseURL + "/customer/orders/\(orderId)/chats" }
    static func sendChat(orderId: String) -> String { baseURL + "/customer/orders/\(orderId)/chats" }
}

class NetworkManager {
    static let shared = NetworkManager()
    
    private let urlSession: URLSession
    
    init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30.0
        self.urlSession = URLSession(configuration: config)
    }
    
    // Helper to get token (To be replaced with Keychain wrapper later)
    private var accessToken: String? {
        UserDefaults.standard.string(forKey: "customer_access_token")
    }
    
    func request<T: Decodable>(_ urlString: String,
                               method: String = "GET",
                               body: Data? = nil,
                               requiresAuth: Bool = true,
                               headers: [String: String]? = nil) async throws -> T {
        
        guard let url = URL(string: urlString) else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        if requiresAuth, let token = accessToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        if let body = body {
            request.httpBody = body
        }
        
        if let customHeaders = headers {
            for (key, value) in customHeaders {
                request.setValue(value, forHTTPHeaderField: key)
            }
        }
        
        // --- Debug Log Request ---
        print("🚀 [\(method)] \(urlString)")
        // -------------------------
        
        let (data, response) = try await urlSession.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        
        // --- Debug Log Response ---
        print("📦 [\(httpResponse.statusCode)] \(urlString)")
        if let jsonStr = String(data: data, encoding: .utf8) {
            print("Response Data: \(jsonStr.prefix(500))...")
        }
        // --------------------------
        
        if httpResponse.statusCode == 401 || httpResponse.statusCode == 403 {
            // TODO: Handle token refresh logic here
            throw NetworkError.unauthorized
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            // Try to decode backend error message
            if let baseRes = try? JSONDecoder().decode(BaseResponse<String>.self, from: data) {
                throw NetworkError.httpError(statusCode: httpResponse.statusCode, message: baseRes.message)
            }
            throw NetworkError.httpError(statusCode: httpResponse.statusCode, message: "Terjadi kesalahan server")
        }
        
        do {
            let decoder = JSONDecoder()
            let result = try decoder.decode(BaseResponse<T>.self, from: data)
            
            if !result.success {
                throw NetworkError.httpError(statusCode: httpResponse.statusCode, message: result.message)
            }
            
            guard let payload = result.data else {
                throw NetworkError.invalidResponse // Explicitly missing payload when success=true
            }
            return payload
            
        } catch {
            print("❌ Decoding Error: \(error)")
            throw NetworkError.decodingError(error)
        }
    }
}
