import Foundation
import Combine

@MainActor
class CustomerChatViewModel: ObservableObject {
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
                    isFromCurrentUser: payload.sender_id == "mock_customer_id", // Temporarily mocked
                    timestamp: payload.created_at
                )
                
                DispatchQueue.main.async {
                    self?.messages.append(msg)
                }
            }
            .store(in: &cancellables)
    }
    
    func connect() {
        // Assume global socket is already connected via Tracking view
        Task {
            await loadHistory()
        }
    }
    
    func sendMessage(text: String) {
        let tempMsg = ChatMessage(text: text, isFromCurrentUser: true, timestamp: currentTimestamp())
        messages.append(tempMsg)
        
        Task {
            do {
                let body = SendChatRequest(message: text, type: "text")
                let bodyData = try JSONEncoder().encode(body)
                let bodyDict = try JSONSerialization.jsonObject(with: bodyData) as? [String: Any]
                
                let _: BaseResponse<ChatMessagePayload> = try await NetworkManager.shared.request(
                    APIEndpoint.sendChat(orderId: orderId),
                    method: "POST",
                    body: bodyData // Send the encoded Data directly instead of Dictionary
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
            let response: BaseResponse<GetChatsResponse> = try await NetworkManager.shared.request(
                APIEndpoint.getChats(orderId: orderId),
                method: "GET"
            )
            
            if let chats = response.data?.chats {
                self.messages = chats.map { chat in
                    ChatMessage(
                        text: chat.text,
                        isFromCurrentUser: chat.sender_id == "mock_customer_id", // Temporarily mocked
                        timestamp: chat.created_at
                    )
                }
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

// Chat models
struct ChatMessage: Identifiable {
    let id = UUID()
    let text: String
    let isFromCurrentUser: Bool
    let timestamp: String
}

struct SendChatRequest: Encodable {
    let message: String
    let type: String
}

struct GetChatsResponse: Decodable {
    let chats: [ChatMessagePayload]
}
