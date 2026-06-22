import Foundation
import MLKitFaceDetection
import AVFoundation
import UIKit

protocol FaceAnalyzerDelegate: AnyObject {
    func faceAnalyzer(_ analyzer: FaceAnalyzer, didUpdateLiveness status: String, isVerified: Bool)
}

class FaceAnalyzer: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    weak var delegate: FaceAnalyzerDelegate?
    
    private let faceDetector: FaceDetector
    private var isVerified = false
    private var verificationFramesCount = 0
    private let requiredFramesForVerification = 5
    
    override init() {
        let options = FaceDetectorOptions()
        options.performanceMode = .accurate
        options.landmarkMode = .all
        options.classificationMode = .all
        
        self.faceDetector = FaceDetector.faceDetector(options: options)
        super.init()
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard !isVerified else { return }
        
        let visionImage = VisionImage(buffer: sampleBuffer)
        visionImage.orientation = imageOrientation(from: connection.videoOrientation)
        
        do {
            let faces = try faceDetector.results(in: visionImage)
            processFaces(faces)
        } catch {
            print("Failed to detect faces: \(error)")
        }
    }
    
    private func processFaces(_ faces: [Face]) {
        if faces.isEmpty {
            updateStatus("Arahkan wajah ke dalam area lingkaran.", isVerified: false)
            verificationFramesCount = 0
            return
        }
        
        if faces.count > 1 {
            updateStatus("Terdeteksi lebih dari satu wajah.", isVerified: false)
            verificationFramesCount = 0
            return
        }
        
        guard let face = faces.first else { return }
        
        // 1. Check head rotation (Euler angles) to ensure facing straight
        if abs(face.headEulerAngleY) > 10 || abs(face.headEulerAngleZ) > 10 {
            updateStatus("Tatap lurus ke kamera.", isVerified: false)
            verificationFramesCount = 0
            return
        }
        
        // 2. Liveness checks (smiling, eyes open)
        let smilingProbability = face.hasSmilingProbability ? face.smilingProbability : 0
        let leftEyeOpenProbability = face.hasLeftEyeOpenProbability ? face.leftEyeOpenProbability : 0
        let rightEyeOpenProbability = face.hasRightEyeOpenProbability ? face.rightEyeOpenProbability : 0
        
        let isBlinking = leftEyeOpenProbability < 0.4 || rightEyeOpenProbability < 0.4
        let isSmiling = smilingProbability > 0.6
        
        if isBlinking || isSmiling {
            verificationFramesCount += 1
            if verificationFramesCount >= requiredFramesForVerification {
                isVerified = true
                updateStatus("Wajah terverifikasi!", isVerified: true)
            } else {
                updateStatus("Tahan posisi ini...", isVerified: false)
            }
        } else {
            updateStatus("Tersenyum atau kedipkan mata untuk verifikasi.", isVerified: false)
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
