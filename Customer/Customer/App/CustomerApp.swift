import SwiftUI

@main
struct CustomerApp: App {
    @StateObject private var authViewModel = CustomerAuthViewModel()

    var body: some Scene {
        WindowGroup {
            CustomerRootView()
                .environmentObject(authViewModel)
        }
    }
}
