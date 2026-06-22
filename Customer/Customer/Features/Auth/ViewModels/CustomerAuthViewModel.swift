import Foundation

@MainActor
final class CustomerAuthViewModel: ObservableObject {
    @Published var isAuthenticated: Bool = false
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    @Published var customerProfile: CustomerProfile? = nil

    private let tokenStorage = CustomerTokenStorage.shared

    init() {
        isAuthenticated = tokenStorage.accessToken != nil
    }

    func login(email: String, password: String) async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        guard let url = URL(string: CustomerAPIConfig.baseURL + CustomerAPIEndpoint.login.path) else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            request.httpBody = try JSONEncoder().encode(CustomerLoginRequest(email: email, password: password))
            let (data, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else { return }

            if httpResponse.statusCode == 200 || httpResponse.statusCode == 201 {
                let decoded = try JSONDecoder().decode(CustomerAuthResponse.self, from: data)
                tokenStorage.accessToken  = decoded.accessToken
                tokenStorage.refreshToken = decoded.refreshToken
                customerProfile = decoded.customer
                isAuthenticated = true
            } else {
                errorMessage = "Email atau password salah."
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func logout() {
        tokenStorage.clearAll()
        customerProfile = nil
        isAuthenticated = false
    }
}
