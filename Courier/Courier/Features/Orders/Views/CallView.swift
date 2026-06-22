import SwiftUI

struct CallView: View {
    let orderId: String
    @StateObject private var callManager = CallManager()
    @State private var isMuted: Bool = false
    @State private var isSpeaker: Bool = false
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            Color("PrimaryDark")
                .ignoresSafeArea()
            
            VStack(spacing: 40) {
                Spacer()
                
                // Caller Info
                VStack(spacing: 16) {
                    Image(systemName: "person.circle.fill")
                        .font(.system(size: 100))
                        .foregroundStyle(.white.opacity(0.8))
                    
                    Text("Pelanggan (Order #\(orderId.prefix(6)))")
                        .font(.title2.bold())
                        .foregroundStyle(.white)
                    
                    Text(callStatusText())
                        .font(.title3)
                        .foregroundStyle(.white.opacity(0.8))
                }
                
                Spacer()
                
                // Call Controls
                HStack(spacing: 40) {
                    // Mute
                    Button {
                        isMuted.toggle()
                        callManager.toggleMute(isMuted: isMuted)
                    } label: {
                        VStack(spacing: 8) {
                            Image(systemName: isMuted ? "mic.slash.fill" : "mic.fill")
                                .font(.title)
                                .foregroundStyle(isMuted ? .black : .white)
                                .frame(width: 70, height: 70)
                                .background(isMuted ? Color.white : Color.white.opacity(0.2))
                                .clipShape(Circle())
                            
                            Text(isMuted ? "Unmute" : "Mute")
                                .font(.caption)
                                .foregroundStyle(.white)
                        }
                    }
                    
                    // Speaker
                    Button {
                        isSpeaker.toggle()
                        callManager.toggleSpeaker(isSpeaker: isSpeaker)
                    } label: {
                        VStack(spacing: 8) {
                            Image(systemName: isSpeaker ? "speaker.wave.3.fill" : "speaker.1.fill")
                                .font(.title)
                                .foregroundStyle(isSpeaker ? .black : .white)
                                .frame(width: 70, height: 70)
                                .background(isSpeaker ? Color.white : Color.white.opacity(0.2))
                                .clipShape(Circle())
                            
                            Text("Speaker")
                                .font(.caption)
                                .foregroundStyle(.white)
                        }
                    }
                }
                
                // End Call
                Button {
                    endCall()
                } label: {
                    Image(systemName: "phone.down.fill")
                        .font(.largeTitle)
                        .foregroundStyle(.white)
                        .frame(width: 80, height: 80)
                        .background(Color.red)
                        .clipShape(Circle())
                }
                .padding(.top, 20)
                .padding(.bottom, 60)
            }
        }
        .onAppear {
            startCall()
        }
        .onDisappear {
            endCall()
        }
    }
    
    private func startCall() {
        callManager.startCall(orderId: orderId)
    }
    
    private func endCall() {
        callManager.endCall()
        dismiss()
    }
    
    private func callStatusText() -> String {
        switch callManager.callState {
        case .idle:
            return "Menyiapkan panggilan..."
        case .ringing:
            return "Memanggil..."
        case .connected:
            return timeString(from: callManager.duration)
        case .ended:
            return "Panggilan Berakhir"
        }
    }
    
    private func timeString(from interval: TimeInterval) -> String {
        let minutes = Int(interval) / 60
        let seconds = Int(interval) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
