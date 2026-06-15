import ArgumentParser
import Foundation
import Vision

struct DetectFaceLandmarks: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "detect-landmarks",
        abstract: "Detect face landmarks (eyes, nose, mouth, etc.)"
    )

    @Option(name: .long, help: "Path to input image")
    var image: String

    @Option(name: .long, help: "Minimum confidence threshold (0.0-1.0)")
    var confidence: Float = 0.5

    func run() throws {
        let start = CFAbsoluteTimeGetCurrent()
        let cgImage = try ImageLoader.loadCGImage(from: image)
        let size = CGSize(width: cgImage.width, height: cgImage.height)

        var results: [LandmarkResult] = []
        var error: String? = nil

        let request = VNDetectFaceLandmarksRequest()
        let handler = VisionHandler(cgImage: cgImage)

        do {
            try handler.perform([request])
            if let observations = request.results {
                results = observations
                    .filter { $0.confidence >= confidence }
                    .map { obs in
                        LandmarkResult(
                            bbox: VisionHandler.pixelBBox(from: obs.boundingBox, imageSize: size),
                            confidence: Double(obs.confidence),
                            landmarks: extractLandmarks(from: obs, imageSize: size)
                        )
                    }
            }
        } catch let e {
            error = e.localizedDescription
        }

        let elapsed = (CFAbsoluteTimeGetCurrent() - start) * 1000
        JSONOutput.printResponse(
            command: "detect-landmarks",
            input: image,
            durationMs: elapsed,
            results: results,
            error: error
        )
    }

    private func extractLandmarks(
        from observation: VNFaceObservation,
        imageSize: CGSize
    ) -> [String: JointPoint] {
        var dict: [String: JointPoint] = [:]
        let regions: [(String, VNFaceLandmarkRegion2D?)] = [
            ("face_contour", observation.landmarks?.faceContour),
            ("left_eyebrow", observation.landmarks?.leftEyebrow),
            ("right_eyebrow", observation.landmarks?.rightEyebrow),
            ("left_eye", observation.landmarks?.leftEye),
            ("right_eye", observation.landmarks?.rightEye),
            ("nose", observation.landmarks?.nose),
            ("nose_crest", observation.landmarks?.noseCrest),
            ("median_line", observation.landmarks?.medianLine),
            ("outer_lips", observation.landmarks?.outerLips),
            ("inner_lips", observation.landmarks?.innerLips),
            ("left_pupil", observation.landmarks?.leftPupil),
            ("right_pupil", observation.landmarks?.rightPupil),
        ]

        for (name, region) in regions {
            guard let points = region?.normalizedPoints else { continue }
            for (i, point) in points.enumerated() {
                let key = points.count > 1 ? "\(name)_\(i)" : name
                dict[key] = JointPoint(
                    x: Double(point.x * imageSize.width),
                    y: Double((1.0 - point.y) * imageSize.height),
                    confidence: 1.0
                )
            }
        }

        return dict
    }
}
