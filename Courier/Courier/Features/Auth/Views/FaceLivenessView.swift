import SwiftUI
import AVFoundation

struct FaceLivenessView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = FaceLivenessViewModel()
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            // Camera Feed Background
            if let session = viewModel.captureSession {
                FaceLivenessCameraPreview(session: session)
                    .ignoresSafeArea()
                    .mask(
                        // Dimming overlay with transparent circle
                        ZStack {
                            Rectangle().fill(Color.black.opacity(0.8))
                            Circle()
                                .frame(width: 250, height: 250)
                                .blendMode(.destinationOut)
                        }
                        .compositingGroup()
                    )
            }
            
            VStack(spacing: 32) {
                Spacer()
                
                Text("Verifikasi Wajah")
                    .font(.title2.bold())
                    .foregroundStyle(.white)
                
                Text("Harap posisikan wajah Anda di dalam lingkaran dan ikuti instruksi yang muncul.")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                
                ZStack {
                    Circle()
                        .strokeBorder(viewModel.isVerified ? Color.green : Color("Primary"), lineWidth: 4)
                        .frame(width: 250, height: 250)
                    
                    VStack {
                        Spacer()
                        Text(viewModel.statusText)
                            .font(.caption.bold())
                            .foregroundStyle(.white)
                            .padding(8)
                            .background(Color.black.opacity(0.5))
                            .clipShape(Capsule())
                            .padding(.bottom, 20)
                    }
                }
                .frame(width: 250, height: 250)
                
                Spacer()
                
                if !viewModel.isVerified {
                    Button("Mulai Verifikasi") {
                        viewModel.startVerification()
                    }
                    .font(.body.bold())
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color("Primary"))
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .padding(.horizontal, 32)
                } else {
                    Button("Lanjutkan") {
                        dismiss()
                    }
                    .font(.body.bold())
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .padding(.horizontal, 32)
                }
                
                Button("Batal") {
                    viewModel.stopCamera()
                    dismiss()
                }
                .foregroundStyle(.white)
                .padding(.bottom, 32)
            }
        }
        .onDisappear {
            viewModel.stopCamera()
        }
    }
}

// ViewModel for Liveness
@MainActor
class FaceLivenessViewModel: ObservableObject {
    @Published var statusText = "Mulai Kamera"
    @Published var isVerified = false
    @Published var captureSession: AVCaptureSession?
    
    private var analyzer: FaceAnalyzer?
    private let session = AVCaptureSession()
    
    func startVerification() {
        checkPermissions()
    }
    
    private func checkPermissions() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            setupCamera()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                if granted {
                    DispatchQueue.main.async { self?.setupCamera() }
                }
            }
        default:
            statusText = "Izin kamera ditolak."
        }
    }
    
    private func setupCamera() {
        session.beginConfiguration()
        guard let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front),
              let videoDeviceInput = try? AVCaptureDeviceInput(device: videoDevice),
              session.canAddInput(videoDeviceInput) else {
            session.commitConfiguration()
            statusText = "Kamera tidak tersedia."
            return
        }
        
        session.addInput(videoDeviceInput)
        
        let videoDataOutput = AVCaptureVideoDataOutput()
        if session.canAddOutput(videoDataOutput) {
            session.addOutput(videoDataOutput)
            
            analyzer = FaceAnalyzer()
            analyzer?.delegate = self
            
            let queue = DispatchQueue(label: "faceQueue")
            videoDataOutput.setSampleBufferDelegate(analyzer, queue: queue)
        }
        
        session.commitConfiguration()
        captureSession = session
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.session.startRunning()
        }
    }
    
    func stopCamera() {
        session.stopRunning()
    }
}

extension FaceLivenessViewModel: FaceAnalyzerDelegate {
    nonisolated func faceAnalyzer(_ analyzer: FaceAnalyzer, didUpdateLiveness status: String, isVerified: Bool) {
        DispatchQueue.main.async { [weak self] in
            self?.statusText = status
            self?.isVerified = isVerified
            if isVerified {
                self?.stopCamera()
            }
        }
    }
}

// Custom View for rendering AVCaptureSession
private struct FaceLivenessCameraPreview: UIViewRepresentable {
    class FaceLivenessVideoPreview: UIView {
        override class var layerClass: AnyClass {
            AVCaptureVideoPreviewLayer.self
        }
        var videoPreviewLayer: AVCaptureVideoPreviewLayer {
            return layer as! AVCaptureVideoPreviewLayer
        }
    }
    
    let session: AVCaptureSession
    
    func makeUIView(context: Context) -> FaceLivenessVideoPreview {
        let view = FaceLivenessVideoPreview()
        view.videoPreviewLayer.session = session
        view.videoPreviewLayer.videoGravity = .resizeAspectFill
        return view
    }
    
    func updateUIView(_ uiView: FaceLivenessVideoPreview, context: Context) {}
}
