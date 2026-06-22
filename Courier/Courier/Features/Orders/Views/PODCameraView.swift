import SwiftUI
import AVFoundation

struct PODCameraView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var cameraManager = CameraManager()
    
    var onCapture: ((UIImage) -> Void)?
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            if cameraManager.isAuthorized {
                CameraPreviewView(session: cameraManager.session)
                    .ignoresSafeArea()
                
                // Watermark overlay
                VStack {
                    Spacer()
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(currentTimestamp())
                            Text(currentLocation())
                        }
                        .font(.caption)
                        .foregroundStyle(.white)
                        .padding(8)
                        .background(.black.opacity(0.5))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        
                        Spacer()
                    }
                    .padding()
                    .padding(.bottom, 100)
                }
                
                // Camera controls
                VStack {
                    Spacer()
                    HStack {
                        Button("Batal") {
                            dismiss()
                        }
                        .foregroundStyle(.white)
                        .padding()
                        
                        Spacer()
                        
                        Button {
                            cameraManager.capturePhoto { image in
                                if let image = image {
                                    // Add watermark logic here before passing it back
                                    onCapture?(image)
                                    dismiss()
                                }
                            }
                        } label: {
                            Circle()
                                .strokeBorder(.white, lineWidth: 3)
                                .frame(width: 70, height: 70)
                                .background(Circle().fill(.white).frame(width: 55, height: 55))
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            cameraManager.switchCamera()
                        }) {
                            Image(systemName: "arrow.triangle.2.circlepath.camera")
                                .font(.title2)
                                .foregroundStyle(.white)
                                .padding()
                        }
                    }
                    .padding(.bottom, 30)
                    .padding(.horizontal)
                }
            } else {
                VStack {
                    Text("Akses Kamera Ditolak")
                        .foregroundStyle(.white)
                    Button("Buka Pengaturan") {
                        if let url = URL(string: UIApplication.openSettingsURLString) {
                            UIApplication.shared.open(url)
                        }
                    }
                }
            }
        }
        .onAppear {
            cameraManager.checkPermissionsAndStart()
        }
        .onDisappear {
            cameraManager.stop()
        }
    }
    
    private func currentTimestamp() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter.string(from: Date())
    }
    
    private func currentLocation() -> String {
        // Placeholder for CoreLocation coords
        return "Lat: -6.200000, Lng: 106.816666"
    }
}

// MARK: - Camera Preview
private struct CameraPreviewView: UIViewRepresentable {
    let session: AVCaptureSession
    
    func makeUIView(context: Context) -> VideoPreviewView {
        let view = VideoPreviewView()
        view.videoPreviewLayer.session = session
        view.videoPreviewLayer.videoGravity = .resizeAspectFill
        return view
    }
    
    func updateUIView(_ uiView: VideoPreviewView, context: Context) {}
}

private class VideoPreviewView: UIView {
    override class var layerClass: AnyClass {
        return AVCaptureVideoPreviewLayer.self
    }
    
    var videoPreviewLayer: AVCaptureVideoPreviewLayer {
        return layer as! AVCaptureVideoPreviewLayer
    }
}

// MARK: - Camera Manager
class CameraManager: NSObject, ObservableObject {
    @Published var isAuthorized = false
    let session = AVCaptureSession()
    private let output = AVCapturePhotoOutput()
    private var completion: ((UIImage?) -> Void)?
    private var currentPosition: AVCaptureDevice.Position = .back
    
    func checkPermissionsAndStart() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            self.isAuthorized = true
            self.setupCamera()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    self.isAuthorized = granted
                    if granted { self.setupCamera() }
                }
            }
        default:
            self.isAuthorized = false
        }
    }
    
    private func setupCamera() {
        session.beginConfiguration()
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: currentPosition),
              let input = try? AVCaptureDeviceInput(device: device) else {
            return
        }
        
        session.inputs.forEach { session.removeInput($0) }
        
        if session.canAddInput(input) {
            session.addInput(input)
        }
        
        if !session.outputs.contains(output) && session.canAddOutput(output) {
            session.addOutput(output)
        }
        
        session.commitConfiguration()
        
        DispatchQueue.global(qos: .userInitiated).async {
            self.session.startRunning()
        }
    }
    
    func stop() {
        session.stopRunning()
    }
    
    func capturePhoto(completion: @escaping (UIImage?) -> Void) {
        self.completion = completion
        let settings = AVCapturePhotoSettings()
        output.capturePhoto(with: settings, delegate: self)
    }
    
    func switchCamera() {
        currentPosition = currentPosition == .back ? .front : .back
        setupCamera()
    }
}

extension CameraManager: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let data = photo.fileDataRepresentation(), let image = UIImage(data: data) else {
            completion?(nil)
            return
        }
        completion?(image)
    }
}
