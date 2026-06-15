import Foundation

// MARK: - Unified Response Wrapper

struct CLIResponse<T: Codable>: Codable {
    let command: String
    let input: String
    let duration_ms: Double
    let results: [T]
    let error: String?
}

// MARK: - Common Geometry

struct PixelBBox: Codable {
    let x: Double
    let y: Double
    let width: Double
    let height: Double
}

struct PixelPoint: Codable {
    let x: Double
    let y: Double
}

struct JointPoint: Codable {
    let x: Double
    let y: Double
    let confidence: Double
}

// MARK: - Face

struct FaceResult: Codable {
    let bbox: PixelBBox
    let confidence: Double
    let faceAngle: Double?  // roll in degrees
}

struct LandmarkResult: Codable {
    let bbox: PixelBBox
    let confidence: Double
    let landmarks: [String: JointPoint]
}

// MARK: - Text

struct TextResult: Codable {
    let text: String
    let confidence: Double
    let bbox: PixelBBox
}

// MARK: - Barcode

struct BarcodeResult: Codable {
    let payload: String
    let format: String
    let bbox: PixelBBox
}

// MARK: - Pose

struct PoseResult: Codable {
    let joints: [String: JointPoint]
}

// MARK: - Hand

struct HandResult: Codable {
    let joints: [String: JointPoint]
}

// MARK: - Animal Pose

struct AnimalPoseResult: Codable {
    let joints: [String: JointPoint]
}

// MARK: - Classify

struct ClassifyResult: Codable {
    let label: String
    let confidence: Double
}

// MARK: - FeaturePrint

struct FeaturePrintGenerateResult: Codable {
    let fingerprint_file: String
}

struct FeaturePrintCompareResult: Codable {
    let similarity: Double
    let distance: Double
}

// MARK: - Human Rectangles

struct HumanResult: Codable {
    let bbox: PixelBBox
    let confidence: Double
}

// MARK: - Contours

struct ContourResult: Codable {
    let contour_index: Int
    let point_count: Int
    let normalized_points: [PixelPoint]
}

// MARK: - Saliency

struct SaliencyResult: Codable {
    let bbox: PixelBBox
    let confidence: Double
}

// MARK: - Optical Flow

struct OpticalFlowResult: Codable {
    let mean_dx: Double
    let mean_dy: Double
    let mean_magnitude: Double
}

// MARK: - Trajectories

struct TrajectoryPoint: Codable {
    let x: Double
    let y: Double
    let time: Double
}

struct TrajectoryResult: Codable {
    let trajectory_id: Int
    let points: [TrajectoryPoint]
}
