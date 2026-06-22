import Foundation
import Combine

@MainActor
final class AuthViewModel: ObservableObject {
    @Published var isAuthenticated: Bool = false
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    @Published var courierProfile: CourierProfile? = nil

    private let tokenStorage = TokenStorage.shared
    private let apiClient = APIClient.shared

    init() {
        isAuthenticated = tokenStorage.accessToken != nil
    }

    func login(phone: String, password: String) async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let response: LoginResponse = try await apiClient.request(
                .login,
                method: .post,
                body: LoginRequest(phone: phone, password: password)
            )
            tokenStorage.accessToken  = response.accessToken
            tokenStorage.refreshToken = response.refreshToken
            courierProfile = response.courier
            isAuthenticated = true
        } catch let error as APIError {
            errorMessage = error.errorDescription
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func logout() {
        tokenStorage.clearAll()
        courierProfile = nil
        isAuthenticated = false
    }
}
