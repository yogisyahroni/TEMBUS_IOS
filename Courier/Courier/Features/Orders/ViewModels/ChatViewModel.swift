import Foundation
import Combine

@MainActor
class ChatViewModel: ObservableObject {
    @Published var messages: [ChatMessage] = []
    @Published var isLoadingHistory = false
    
    private let orderId: String
    private var cancellables = Set<AnyCancellable>()
    
    init(orderId: String) {
        self.orderId = orderId
        
        WebSocketManager.shared.chatMessagePublisher
            .sink { [weak self] payload in
                guard payload.order_id == self?.orderId else { return }
                
                let msg = ChatMessage(
                    text: payload.text,
                    isFromCurrentUser: payload.sender_id == TokenStorage.shared.courierId, // Assuming we have courierId
                    timestamp: payload.created_at
                )
                
                DispatchQueue.main.async {
                    self?.messages.append(msg)
                }
            }
            .store(in: &cancellables)
    }
    
    func connect() {
        WebSocketManager.shared.connect()
        WebSocketManager.shared.joinOrderRoom(orderId: orderId)
        
        Task {
            await loadHistory()
        }
    }
    
    func disconnect() {
        WebSocketManager.shared.leaveOrderRoom(orderId: orderId)
        // Keep the global socket connection open for other events if needed, 
        // or let the parent view manage disconnect
    }
    
    func sendMessage(text: String) {
        // Optimistic UI
        let tempMsg = ChatMessage(text: text, isFromCurrentUser: true, timestamp: currentTimestamp())
        messages.append(tempMsg)
        
        Task {
            do {
                let body = SendChatRequest(message: text, type: "text")
                let _: ChatMessagePayload = try await APIClient.shared.request(
                    .sendChat(orderId: orderId),
                    method: .post,
                    body: body
                )
            } catch {
                print("Failed to send message: \(error)")
            }
        }
    }
    
    private func loadHistory() async {
        isLoadingHistory = true
        defer { isLoadingHistory = false }
        
        do {
            let response: GetChatsResponse = try await APIClient.shared.request(.getChats(orderId: orderId))
            self.messages = response.chats.map { chat in
                ChatMessage(
                    text: chat.text,
                    isFromCurrentUser: chat.sender_id == TokenStorage.shared.courierId, // Optional: adjust check based on actual sender_type or ID
                    timestamp: chat.created_at
                )
            }
        } catch {
            print("Failed to load chat history: \(error)")
        }
    }
    
    private func currentTimestamp() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: Date())
    }
}

// REST Payloads
struct SendChatRequest: Encodable {
    let message: String
    let type: String
}

struct GetChatsResponse: Decodable {
    let chats: [ChatMessagePayload]
}
