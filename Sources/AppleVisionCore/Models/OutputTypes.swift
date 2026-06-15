import Foundation

// MARK: - Unified Response Wrapper

public struct CLIResponse<T: Codable>: Codable {
    public let command: String
    public let input: String
    public let duration_ms: Double
    public let results: [T]
    public let error: String?

    public init(command: String, input: String, duration_ms: Double, results: [T], error: String?) {
        self.command = command
        self.input = input
        self.duration_ms = duration_ms
        self.results = results
        self.error = error
    }
}

// MARK: - Common Geometry

public struct PixelBBox: Codable {
    public let x: Double
    public let y: Double
    public let width: Double
    public let height: Double

    public init(x: Double, y: Double, width: Double, height: Double) {
        self.x = x
        self.y = y
        self.width = width
        self.height = height
    }
}

public struct PixelPoint: Codable {
    public let x: Double
    public let y: Double

    public init(x: Double, y: Double) {
        self.x = x
        self.y = y
    }
}

public struct JointPoint: Codable {
    public let x: Double
    public let y: Double
    public let confidence: Double

    public init(x: Double, y: Double, confidence: Double) {
        self.x = x
        self.y = y
        self.confidence = confidence
    }
}

// MARK: - Face

public struct FaceResult: Codable {
    public let bbox: PixelBBox
    public let confidence: Double
    public let faceAngle: Double?  // roll in degrees

    public init(bbox: PixelBBox, confidence: Double, faceAngle: Double?) {
        self.bbox = bbox
        self.confidence = confidence
        self.faceAngle = faceAngle
    }
}

public struct LandmarkResult: Codable {
    public let bbox: PixelBBox
    public let confidence: Double
    public let landmarks: [String: JointPoint]

    public init(bbox: PixelBBox, confidence: Double, landmarks: [String: JointPoint]) {
        self.bbox = bbox
        self.confidence = confidence
        self.landmarks = landmarks
    }
}

// MARK: - Text

public struct TextResult: Codable {
    public let text: String
    public let confidence: Double
    public let bbox: PixelBBox

    public init(text: String, confidence: Double, bbox: PixelBBox) {
        self.text = text
        self.confidence = confidence
        self.bbox = bbox
    }
}

// MARK: - Barcode

public struct BarcodeResult: Codable {
    public let payload: String
    public let format: String
    public let bbox: PixelBBox

    public init(payload: String, format: String, bbox: PixelBBox) {
        self.payload = payload
        self.format = format
        self.bbox = bbox
    }
}

// MARK: - Pose

public struct PoseResult: Codable {
    public let joints: [String: JointPoint]

    public init(joints: [String: JointPoint]) {
        self.joints = joints
    }
}

// MARK: - Hand

public struct HandResult: Codable {
    public let joints: [String: JointPoint]

    public init(joints: [String: JointPoint]) {
        self.joints = joints
    }
}

// MARK: - Animal Pose

public struct AnimalPoseResult: Codable {
    public let joints: [String: JointPoint]

    public init(joints: [String: JointPoint]) {
        self.joints = joints
    }
}

// MARK: - Classify

public struct ClassifyResult: Codable {
    public let label: String
    public let confidence: Double

    public init(label: String, confidence: Double) {
        self.label = label
        self.confidence = confidence
    }
}

// MARK: - FeaturePrint

public struct FeaturePrintGenerateResult: Codable {
    public let fingerprint_file: String

    public init(fingerprint_file: String) {
        self.fingerprint_file = fingerprint_file
    }
}

public struct FeaturePrintCompareResult: Codable {
    public let similarity: Double
    public let distance: Double

    public init(similarity: Double, distance: Double) {
        self.similarity = similarity
        self.distance = distance
    }
}

// MARK: - Human Rectangles

public struct HumanResult: Codable {
    public let bbox: PixelBBox
    public let confidence: Double

    public init(bbox: PixelBBox, confidence: Double) {
        self.bbox = bbox
        self.confidence = confidence
    }
}

// MARK: - Contours

public struct ContourResult: Codable {
    public let contour_index: Int
    public let point_count: Int
    public let normalized_points: [PixelPoint]

    public init(contour_index: Int, point_count: Int, normalized_points: [PixelPoint]) {
        self.contour_index = contour_index
        self.point_count = point_count
        self.normalized_points = normalized_points
    }
}

// MARK: - Saliency

public struct SaliencyResult: Codable {
    public let bbox: PixelBBox
    public let confidence: Double

    public init(bbox: PixelBBox, confidence: Double) {
        self.bbox = bbox
        self.confidence = confidence
    }
}

// MARK: - Optical Flow

public struct OpticalFlowResult: Codable {
    public let mean_dx: Double
    public let mean_dy: Double
    public let mean_magnitude: Double

    public init(mean_dx: Double, mean_dy: Double, mean_magnitude: Double) {
        self.mean_dx = mean_dx
        self.mean_dy = mean_dy
        self.mean_magnitude = mean_magnitude
    }
}

// MARK: - Trajectories

public struct TrajectoryPoint: Codable {
    public let x: Double
    public let y: Double
    public let time: Double

    public init(x: Double, y: Double, time: Double) {
        self.x = x
        self.y = y
        self.time = time
    }
}

public struct TrajectoryResult: Codable {
    public let trajectory_id: Int
    public var points: [TrajectoryPoint]

    public init(trajectory_id: Int, points: [TrajectoryPoint]) {
        self.trajectory_id = trajectory_id
        self.points = points
    }
}
