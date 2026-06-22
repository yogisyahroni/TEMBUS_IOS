import SwiftUI

struct MainTabView: View {
    @EnvironmentObject private var authViewModel: AuthViewModel
    @State private var selectedTab: Int = 0
    @StateObject private var notificationViewModel = NotificationViewModel()

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Label("Beranda", systemImage: "house.fill")
                }
                .tag(0)

            OrderListView()
                .tabItem {
                    Label("Order", systemImage: "shippingbox.fill")
                }
                .tag(1)

            InboxView()
                .badge(notificationViewModel.unreadCount > 0 ? notificationViewModel.unreadCount : 0)
                .tabItem {
                    Label("Notifikasi", systemImage: "bell.fill")
                }
                .tag(2)

            ProfileView()
                .tabItem {
                    Label("Profil", systemImage: "person.fill")
                }
                .tag(3)
        }
        .tint(Color("Primary"))
        .environmentObject(notificationViewModel)
    }
}
