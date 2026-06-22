import Foundation
import WebRTC
import Combine

@MainActor
class CallManager: ObservableObject {
    @Published var callState: CallState = .idle
    @Published var duration: TimeInterval = 0
    
    private let webRTCClient: WebRTCClient
    private var timer: Timer?
    
    enum CallState {
        case idle
        case ringing
        case connected
        case ended
    }
    
    init(iceServers: [String] = ["stun:stun.l.google.com:19302"]) {
        self.webRTCClient = WebRTCClient(iceServers: iceServers)
        self.webRTCClient.delegate = self
        
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
        
        webRTCClient.offer { [weak self] sdp in
            let payload: [String: Any] = [
                "orderId": orderId,
                "sdp": sdp.sdp,
                "type": "offer"
            ]
            WebSocketManager.shared.emitCallEvent(event: "call_invite", payload: payload)
        }
    }
    
    func answerCall() {
        webRTCClient.answer { [weak self] sdp in
            let payload: [String: Any] = [
                "sdp": sdp.sdp,
                "type": "answer"
            ]
            WebSocketManager.shared.emitCallEvent(event: "call_accept", payload: payload)
        }
    }
    
    func endCall() {
        webRTCClient.close()
        callState = .ended
        stopTimer()
        WebSocketManager.shared.emitCallEvent(event: "call_reject", payload: [:])
    }
    
    func toggleMute(isMuted: Bool) {
        if isMuted {
            webRTCClient.muteAudio()
        } else {
            webRTCClient.unmuteAudio()
        }
    }
    
    func toggleSpeaker(isSpeaker: Bool) {
        webRTCClient.setSpeaker(isSpeaker)
    }
    
    private func handleIncomingCall(payload: [String: Any]) {
        guard let sdpString = payload["sdp"] as? String,
              let type = payload["type"] as? String else { return }
        
        let sdp = RTCSessionDescription(type: type == "offer" ? .offer : .answer, sdp: sdpString)
        
        webRTCClient.set(remoteSdp: sdp) { error in
            if let error = error {
                print("Failed to set remote SDP: \(error)")
            }
        }
        
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

extension CallManager: WebRTCClientDelegate {
    nonisolated func webRTCClient(_ client: WebRTCClient, didDiscoverLocalCandidate candidate: RTCIceCandidate) {
        let payload: [String: Any] = [
            "candidate": candidate.sdp,
            "sdpMLineIndex": candidate.sdpMLineIndex,
            "sdpMid": candidate.sdpMid ?? ""
        ]
        Task { @MainActor in
            WebSocketManager.shared.emitCallEvent(event: "ice_candidate", payload: payload)
        }
    }
    
    nonisolated func webRTCClient(_ client: WebRTCClient, didChangeConnectionState state: RTCIceConnectionState) {
        DispatchQueue.main.async { [weak self] in
            switch state {
            case .connected, .completed:
                self?.callState = .connected
                self?.startTimer()
            case .disconnected, .failed, .closed:
                self?.callState = .ended
                self?.stopTimer()
            default:
                break
            }
        }
    }
    
    nonisolated func webRTCClient(_ client: WebRTCClient, didReceiveData data: Data) {
        // Not used for audio calls
    }
}
