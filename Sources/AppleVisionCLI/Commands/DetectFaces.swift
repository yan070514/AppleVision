import ArgumentParser
import Foundation
import Vision

struct DetectFaces: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "detect-faces",
        abstract: "Detect faces and return bounding boxes"
    )

    @Option(name: .long, help: "Path to input image")
    var image: String

    @Option(name: .long, help: "Minimum confidence threshold (0.0-1.0)")
    var confidence: Float = 0.5

    func run() throws {
        let start = CFAbsoluteTimeGetCurrent()
        let cgImage = try ImageLoader.loadCGImage(from: image)
        let size = CGSize(width: cgImage.width, height: cgImage.height)

        var results: [FaceResult] = []
        var error: String? = nil

        let request = VNDetectFaceRectanglesRequest()
        let handler = VisionHandler(cgImage: cgImage)

        do {
            try handler.perform([request])
            if let observations = request.results {
                results = observations
                    .filter { $0.confidence >= confidence }
                    .map { obs in
                        FaceResult(
                            bbox: VisionHandler.pixelBBox(from: obs.boundingBox, imageSize: size),
                            confidence: Double(obs.confidence),
                            faceAngle: obs.roll.map { Double(truncating: $0) * 180.0 / .pi }
                        )
                    }
            }
        } catch let e {
            error = e.localizedDescription
        }

        let elapsed = (CFAbsoluteTimeGetCurrent() - start) * 1000
        JSONOutput.printResponse(
            command: "detect-faces",
            input: image,
            durationMs: elapsed,
            results: results,
            error: error
        )
    }
}
