import SwiftUI

struct CustomerMainTabView: View {
    @State private var selectedTab: Int = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            CustomerHomeView()
                .tabItem { Label("Beranda", systemImage: "house.fill") }
                .tag(0)

            CustomerOrderHistoryView()
                .tabItem { Label("Riwayat", systemImage: "list.bullet.rectangle") }
                .tag(1)

            CustomerTrackingView()
                .tabItem { Label("Lacak", systemImage: "location.fill") }
                .tag(2)

            CustomerProfileView()
                .tabItem { Label("Profil", systemImage: "person.fill") }
                .tag(3)
        }
        .tint(Color("CustomerPrimary"))
    }
}
