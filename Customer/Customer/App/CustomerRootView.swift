import SwiftUI

struct CustomerRootView: View {
    @EnvironmentObject private var authViewModel: CustomerAuthViewModel

    var body: some View {
        Group {
            if authViewModel.isAuthenticated {
                CustomerMainTabView()
            } else {
                CustomerLoginView()
            }
        }
        .animation(.easeInOut, value: authViewModel.isAuthenticated)
    }
}
