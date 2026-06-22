import Foundation
import AVFoundation
// import MLKitFaceDetection // Temporarily mocked
// import MLKitVision // Temporarily mocked

protocol FaceAnalyzerDelegate: AnyObject {
    func faceAnalyzer(_ analyzer: FaceAnalyzer, didUpdateLiveness status: String, isVerified: Bool)
}

class FaceAnalyzer: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    weak var delegate: FaceAnalyzerDelegate?
    
    private var isVerified = false
    private var verificationFramesCount = 0
    private let requiredFramesForVerification = 5
    
    override init() {
        super.init()
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard !isVerified else { return }
        
        // Mock processing for now since MLKit is disabled
        verificationFramesCount += 1
        if verificationFramesCount >= requiredFramesForVerification {
            isVerified = true
            updateStatus("Wajah terverifikasi (Mock)!", isVerified: true)
        } else {
            updateStatus("Tahan posisi ini...", isVerified: false)
        }
    }
    
    private func updateStatus(_ status: String, isVerified: Bool) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.delegate?.faceAnalyzer(self, didUpdateLiveness: status, isVerified: isVerified)
        }
    }
    
    private func imageOrientation(from videoOrientation: AVCaptureVideoOrientation) -> UIImage.Orientation {
        switch videoOrientation {
        case .portrait: return .up
        case .portraitUpsideDown: return .down
        case .landscapeLeft: return .left
        case .landscapeRight: return .right
        @unknown default: return .up
        }
    }
}
