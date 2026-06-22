import Foundation
// import WebRTC // Temporarily removed to pass CI build
import Combine

@MainActor
class CallManager: ObservableObject {
    @Published var callState: CallState = .idle
    @Published var duration: TimeInterval = 0
    
    // private let webRTCClient: WebRTCClient
    private var timer: Timer?
    
    enum CallState {
        case idle
        case ringing
        case connected
        case ended
    }
    
    init(iceServers: [String] = ["stun:stun.l.google.com:19302"]) {
        // self.webRTCClient = WebRTCClient(iceServers: iceServers)
        // self.webRTCClient.delegate = self
        
        setupSocketListeners()
    }
    
    private var cancellables = Set<AnyCancellable>()
    
    private func setupSocketListeners() {
        WebSocketManager.shared.callInvitePublisher
            .sink { [weak self] payload in
                self?.handleIncomingCall(payload: payload)
            }
            .store(in: &cancellables)
    }
    
    func startCall(orderId: String) {
        callState = .ringing
        
        let payload: [String: Any] = [
            "orderId": orderId,
            "sdp": "mock_sdp",
            "type": "offer"
        ]
        WebSocketManager.shared.emitCallEvent(event: "call_invite", payload: payload)
        
        // Simulate connecting after 2 seconds for mock
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.callState = .connected
            self.startTimer()
        }
    }
    
    func answerCall() {
        let payload: [String: Any] = [
            "sdp": "mock_sdp",
            "type": "answer"
        ]
        WebSocketManager.shared.emitCallEvent(event: "call_accept", payload: payload)
        
        self.callState = .connected
        self.startTimer()
    }
    
    func endCall() {
        // webRTCClient.close()
        callState = .ended
        stopTimer()
        WebSocketManager.shared.emitCallEvent(event: "call_reject", payload: [:])
    }
    
    func toggleMute(isMuted: Bool) {
        // webRTCClient.muteAudio()
    }
    
    func toggleSpeaker(isSpeaker: Bool) {
        // webRTCClient.setSpeaker(isSpeaker)
    }
    
    private func handleIncomingCall(payload: [String: Any]) {
        guard let _ = payload["sdp"] as? String,
              let type = payload["type"] as? String else { return }
        
        if type == "offer" {
            callState = .ringing
        }
    }
    
    private func startTimer() {
        duration = 0
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            DispatchQueue.main.async {
                self?.duration += 1
            }
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
}

