import AppleVisionCore
import ArgumentParser
import Foundation
import Vision

struct ClassifyImage: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "classify",
        abstract: "Classify the dominant subject in an image"
    )

    @Option(name: .long, help: "Path to input image")
    var image: String

    @Option(name: .long, help: "Maximum number of classification results")
    var maxResults: Int = 5

    func run() throws {
        let start = CFAbsoluteTimeGetCurrent()
        let cgImage = try ImageLoader.loadCGImage(from: image)

        var results: [ClassifyResult] = []
        var error: String? = nil

        let request = VNClassifyImageRequest()
        let handler = VisionHandler(cgImage: cgImage)

        do {
            try handler.perform([request])
            if let observations = request.results {
                results = observations
                    .prefix(maxResults)
                    .map { ClassifyResult(
                        label: $0.identifier,
                        confidence: Double($0.confidence)
                    )}
            }
        } catch let e {
            error = e.localizedDescription
        }

        let elapsed = (CFAbsoluteTimeGetCurrent() - start) * 1000
        JSONOutput.printResponse(
            command: "classify",
            input: image,
            durationMs: elapsed,
            results: results,
            error: error
        )
    }
}
