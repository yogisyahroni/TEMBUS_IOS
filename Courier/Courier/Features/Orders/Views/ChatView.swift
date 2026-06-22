import SwiftUI

struct ChatMessage: Identifiable {
    let id = UUID()
    let text: String
    let isFromCurrentUser: Bool
    let timestamp: String
}

struct ChatView: View {
    let orderId: String
    @StateObject private var viewModel: ChatViewModel
    @State private var newMessageText: String = ""
    @Environment(\.dismiss) private var dismiss
    
    init(orderId: String) {
        self.orderId = orderId
        _viewModel = StateObject(wrappedValue: ChatViewModel(orderId: orderId))
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(viewModel.messages) { message in
                            MessageBubble(message: message)
                        }
                    }
                    .padding()
                }
                
                // Input area
                HStack(spacing: 12) {
                    TextField("Tulis pesan...", text: $newMessageText)
                        .padding(12)
                        .background(Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                    
                    Button {
                        sendMessage()
                    } label: {
                        Image(systemName: "paperplane.fill")
                            .font(.system(size: 20))
                            .foregroundStyle(.white)
                            .padding(12)
                            .background(newMessageText.isEmpty ? Color.gray : Color("Primary"))
                            .clipShape(Circle())
                    }
                    .disabled(newMessageText.isEmpty)
                }
                .padding()
                .background(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 5, y: -5)
            }
            .navigationTitle("Chat Pelanggan")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Tutup") { dismiss() }
                }
            }
            .onAppear {
                viewModel.connect()
            }
            .onDisappear {
                viewModel.disconnect()
            }
        }
    }
    
    private func sendMessage() {
        guard !newMessageText.isEmpty else { return }
        viewModel.sendMessage(text: newMessageText)
        newMessageText = ""
    }
}

struct MessageBubble: View {
    let message: ChatMessage
    
    var body: some View {
        HStack {
            if message.isFromCurrentUser { Spacer() }
            
            VStack(alignment: message.isFromCurrentUser ? .trailing : .leading, spacing: 4) {
                Text(message.text)
                    .font(.body)
                    .foregroundStyle(message.isFromCurrentUser ? .white : .primary)
                
                Text(message.timestamp)
                    .font(.caption2)
                    .foregroundStyle(message.isFromCurrentUser ? .white.opacity(0.7) : .secondary)
            }
            .padding(12)
            .background(message.isFromCurrentUser ? Color("Primary") : Color(.systemGray5))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            
            if !message.isFromCurrentUser { Spacer() }
        }
    }
}
