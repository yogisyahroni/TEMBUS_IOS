import SwiftUI
import SwiftData

@main
struct CourierApp: App {
    @StateObject private var authViewModel = AuthViewModel()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(authViewModel)
        }
        .modelContainer(for: [OrderEntity.self, CourierOrderPackageEntity.self])
    }
}
