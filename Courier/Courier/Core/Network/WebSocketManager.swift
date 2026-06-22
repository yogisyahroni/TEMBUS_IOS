import Foundation
import Combine

/// Note: To compile this code, you MUST add `Socket.IO-Client-Swift` to the Xcode project.
/// See the README or Implementation Plan for instructions.
#if canImport(SocketIO)
import SocketIO
#endif

class WebSocketManager: ObservableObject {
    static let shared = WebSocketManager()
    
    @Published var isConnected = false
    
    let chatMessagePublisher = PassthroughSubject<ChatMessagePayload, Never>()
    let callInvitePublisher = PassthroughSubject<[String: Any], Never>()
    
    #if canImport(SocketIO)
    private var manager: SocketManager?
    private var socket: SocketIOClient?
    #endif
    
    private init() {}
    
    func connect() {
        #if canImport(SocketIO)
        // In Courier, token is stored in TokenStorage
        guard let token = TokenStorage.shared.accessToken else {
            print("Cannot connect to socket: No auth token")
            return
        }
        
        guard let url = URL(string: APIEndpoint.baseURL.replacingOccurrences(of: "/api/v1", with: "")) else { return }
        
        manager = SocketManager(socketURL: url, config: [
            .log(false),
            .compress,
            .connectParams(["token": token]),
            .extraHeaders(["cookie": "accessToken=\(token)"])
        ])
        
        socket = manager?.defaultSocket
        
        setupListeners()
        socket?.connect()
        #else
        print("SocketIO is not imported. Please add Socket.IO-Client-Swift package.")
        #endif
    }
    
    func disconnect() {
        #if canImport(SocketIO)
        socket?.disconnect()
        #endif
    }
    
    #if canImport(SocketIO)
    private func setupListeners() {
        guard let socket = socket else { return }
        
        socket.on(clientEvent: .connect) { [weak self] data, ack in
            print("Courier Socket connected!")
            DispatchQueue.main.async {
                self?.isConnected = true
            }
        }
        
        socket.on(clientEvent: .disconnect) { [weak self] data, ack in
            print("Courier Socket disconnected!")
            DispatchQueue.main.async {
                self?.isConnected = false
            }
        }
        
        socket.on("new_chat_message") { [weak self] data, ack in
            guard let dict = data.first as? [String: Any] else { return }
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: dict)
                let payload = try JSONDecoder().decode(ChatMessagePayload.self, from: jsonData)
                DispatchQueue.main.async {
                    self?.chatMessagePublisher.send(payload)
                }
            } catch {
                print("Failed to decode new_chat_message event: \(error)")
            }
        }
        
        socket.on("call_invite") { [weak self] data, ack in
            guard let dict = data.first as? [String: Any] else { return }
            DispatchQueue.main.async {
                self?.callInvitePublisher.send(dict)
            }
        }
    }
    #endif
    
    func emitCallEvent(event: String, payload: [String: Any]) {
        #if canImport(SocketIO)
        guard isConnected, let socket = socket else { return }
        socket.emit(event, payload)
        #endif
    }
    
    func joinOrderRoom(orderId: String) {
        #if canImport(SocketIO)
        guard isConnected, let socket = socket else { return }
        socket.emit("join_order_room", ["order_id": orderId])
        #endif
    }
    
    func leaveOrderRoom(orderId: String) {
        #if canImport(SocketIO)
        guard isConnected, let socket = socket else { return }
        socket.emit("leave_order_room", ["order_id": orderId])
        #endif
    }
}

// Payload Models
struct ChatMessagePayload: Decodable {
    let message_id: String
    let order_id: String
    let sender_id: String
    let text: String
    let created_at: String
}
