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
    
    // Publishers for specific events
    let trackingUpdatePublisher = PassthroughSubject<TrackingUpdatePayload, Never>()
    let chatMessagePublisher = PassthroughSubject<ChatMessagePayload, Never>()
    
    #if canImport(SocketIO)
    private var manager: SocketManager?
    private var socket: SocketIOClient?
    #endif
    
    private init() {}
    
    func connect() {
        #if canImport(SocketIO)
        // Ensure we only connect if there's a token
        guard let token = CustomerTokenStorage.shared.accessToken else {
            print("Cannot connect to socket: No auth token")
            return
        }
        
        guard let url = URL(string: APIEndpoint.baseURL.replacingOccurrences(of: "/api/v1", with: "")) else { return }
        
        manager = SocketManager(socketURL: url, config: [
            .log(false),
            .compress,
            .connectParams(["token": token]),
            .extraHeaders(["cookie": "accessToken=\(token)"]) // Some backends prefer cookie extraction
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
            print("Socket connected!")
            DispatchQueue.main.async {
                self?.isConnected = true
            }
        }
        
        socket.on(clientEvent: .disconnect) { [weak self] data, ack in
            print("Socket disconnected!")
            DispatchQueue.main.async {
                self?.isConnected = false
            }
        }
        
        // Listen to tracking updates
        socket.on("tracking:update") { [weak self] data, ack in
            guard let dict = data.first as? [String: Any] else { return }
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: dict)
                let payload = try JSONDecoder().decode(TrackingUpdatePayload.self, from: jsonData)
                DispatchQueue.main.async {
                    self?.trackingUpdatePublisher.send(payload)
                }
            } catch {
                print("Failed to decode tracking:update event: \(error)")
            }
        }
        
        // Listen to new chat messages
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
    }
    #endif
    
    // Commands
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
struct TrackingUpdatePayload: Decodable {
    let order_id: String
    let location: LocationPayload?
    
    struct LocationPayload: Decodable {
        let latitude: Double
        let longitude: Double
    }
}

struct ChatMessagePayload: Decodable {
    let message_id: String
    let order_id: String
    let sender_id: String
    let text: String
    let created_at: String
}
