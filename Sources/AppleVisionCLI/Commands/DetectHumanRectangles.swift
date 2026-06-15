import AppleVisionCore
import ArgumentParser
import Foundation
import Vision

struct DetectHumanRectangles: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "detect-humans",
        abstract: "Detect human bodies (bounding boxes, fast)"
    )

    @Option(name: .long, help: "Path to input image")
    var image: String

    @Option(name: .long, help: "Minimum confidence threshold (0.0-1.0)")
    var confidence: Float = 0.5

    func run() throws {
        let start = CFAbsoluteTimeGetCurrent()
        let cgImage = try ImageLoader.loadCGImage(from: image)
        let size = CGSize(width: cgImage.width, height: cgImage.height)

        var results: [HumanResult] = []
        var error: String? = nil

        let request = VNDetectHumanRectanglesRequest()
        let handler = VisionHandler(cgImage: cgImage)

        do {
            try handler.perform([request])
            if let observations = request.results {
                results = observations
                    .filter { $0.confidence >= confidence }
                    .map { HumanResult(
                        bbox: VisionHandler.pixelBBox(from: $0.boundingBox, imageSize: size),
                        confidence: Double($0.confidence)
                    )}
            }
        } catch let e {
            error = e.localizedDescription
        }

        let elapsed = (CFAbsoluteTimeGetCurrent() - start) * 1000
        JSONOutput.printResponse(
            command: "detect-humans",
            input: image,
            durationMs: elapsed,
            results: results,
            error: error
        )
    }
}
