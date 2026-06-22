import Foundation
import SwiftData

@Model
final class OrderEntity {
    @Attribute(.unique) var orderId: String
    
    var localId: Int = 0
    var pickupAddress: String = ""
    var pickupLatitude: Double? = nil
    var pickupLongitude: Double? = nil
    var pickupTime: String = ""
    var dropAddress: String = ""
    var dropLatitude: Double? = nil
    var dropLongitude: Double? = nil
    var distance: String = ""
    var fee: String = ""
    var courierPayoutEstimateIdr: Int = 0
    var customerPriceIdr: Int = 0
    var platformCommissionIdr: Int = 0
    
    var serviceCode: String?
    var serviceName: String?
    var serviceCategory: String?
    var serviceFamily: String?
    var serviceRouteModel: String?
    var serviceMaxEtaMinutes: Int = 0
    
    var packageCount: Int = 1
    // Packages will be a relationship
    @Relationship(deleteRule: .cascade) var packages: [CourierOrderPackageEntity] = []
    
    var serviceMaxPackagesPerOrder: Int = 1
    var serviceMaxActiveOrdersOnDemand: Int = 1
    var serviceFaceVerificationRequired: Bool = true
    var serviceProofGeofenceRadiusM: Int = 10
    var serviceProofMinAccuracyM: Int = 50
    var serviceFailedDeliveryPolicy: String = "must_deliver"
    
    var itemDescription: String?
    var itemImageUrl: String?
    var modelType: String = "P2P"
    var legNumber: Int = 1
    var workflowRole: String = "on_demand"
    var dispatchId: String?
    
    var offerExpiresAt: Int64?
    var offerTtlSeconds: Int?
    var customerName: String = ""
    var status: String = "pending"
    var createdAt: Int64 = 0
    var updatedAt: Int64 = 0
    
    // Sync Flags
    var needsSync: Bool = true
    var needsScanSync: Bool = false
    var needsPodSync: Bool = false
    
    // Scan & PoD Data
    var scanLatitude: Double?
    var scanLongitude: Double?
    var scanType: String?
    
    var podImageUri: String?
    var podProofType: String?
    var proofSyncedAt: Int64?
    var pickupEvidenceUpdatedAt: Int64?
    
    var signatureData: String?
    var deliveryNotes: String?
    var customerPhone: String?
    
    var pickupScanVerified: Bool = false
    var pickupPhotoVerified: Bool = false
    
    var length: Double?
    var width: Double?
    var height: Double?
    var weight: Double?
    
    init(orderId: String) {
        self.orderId = orderId
    }
}

@Model
final class CourierOrderPackageEntity {
    @Attribute(.unique) var packageId: String?
    var id: String?
    var packageCode: String?
    var packageDescription: String?
    var sizeTier: String?
    var weightKg: Double?
    var status: String = "pending"
    var pickupScanVerifiedAt: String?
    var pickupPhotoVerifiedAt: String?
    var deliveryPodVerifiedAt: String?
    
    init() {}
}
