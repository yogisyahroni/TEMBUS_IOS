import SwiftUI

struct InboxView: View {
    @StateObject private var viewModel = NotificationViewModel()

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading && viewModel.notifications.isEmpty {
                    ProgressView("Memuat notifikasi...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if viewModel.notifications.isEmpty {
                    ContentUnavailableView(
                        "Belum Ada Notifikasi",
                        systemImage: "bell.slash.fill",
                        description: Text("Notifikasi dari TEMBUS akan muncul di sini.")
                    )
                } else {
                    List {
                        ForEach(viewModel.notifications) { notification in
                            NotificationRowView(notification: notification)
                                .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                                .listRowSeparator(.hidden)
                                .listRowBackground(Color.clear)
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Kotak Masuk")
            .toolbar {
                if viewModel.unreadCount > 0 {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Tandai Dibaca") {
                            Task { await viewModel.markAllAsRead() }
                        }
                        .font(.caption.weight(.semibold))
                    }
                }
            }
            .task {
                await viewModel.fetchNotifications()
            }
            .refreshable {
                await viewModel.fetchNotifications()
            }
        }
    }
}

struct NotificationRowView: View {
    let notification: AppNotification

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Icon
            ZStack {
                Circle()
                    .fill(Color("Primary").opacity(0.12))
                    .frame(width: 44, height: 44)
                Image(systemName: "bell.fill")
                    .foregroundStyle(Color("Primary"))
                    .font(.system(size: 18))
            }

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(notification.title)
                        .font(.subheadline.weight(notification.isRead ? .regular : .bold))
                        .lineLimit(2)
                    Spacer()
                    if !notification.isRead {
                        Circle()
                            .fill(Color("Primary"))
                            .frame(width: 8, height: 8)
                    }
                }

                Text(notification.body)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(3)

                Text(notification.formattedDate)
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
        }
        .padding()
        .background(
            notification.isRead
                ? Color(.secondarySystemBackground)
                : Color("Primary").opacity(0.06)
        )
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}

// MARK: - Notification date formatting
extension AppNotification {
    var formattedDate: String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = formatter.date(from: createdAt) {
            let display = DateFormatter()
            display.locale = Locale(identifier: "id_ID")
            display.dateFormat = "dd MMM, HH:mm"
            return display.string(from: date)
        }
        return createdAt
    }
}
