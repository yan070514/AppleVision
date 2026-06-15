import AppleVisionCore
import ArgumentParser
import Foundation
import Vision

struct GenerateSaliency: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "saliency",
        abstract: "Generate saliency heatmap (attention or objectness)"
    )

    @Option(name: .long, help: "Path to input image")
    var image: String

    @Option(name: .long, help: "Type: attention or objectness")
    var type: String = "attention"

    func run() throws {
        let start = CFAbsoluteTimeGetCurrent()
        let cgImage = try ImageLoader.loadCGImage(from: image)
        let size = CGSize(width: cgImage.width, height: cgImage.height)

        var results: [SaliencyResult] = []
        var error: String? = nil

        let request: VNImageBasedRequest = type == "objectness"
            ? VNGenerateObjectnessBasedSaliencyImageRequest()
            : VNGenerateAttentionBasedSaliencyImageRequest()

        let handler = VisionHandler(cgImage: cgImage)

        do {
            try handler.perform([request])
            if let saliencyObs = request.results?.first as? VNSaliencyImageObservation,
               let objects = saliencyObs.salientObjects {
                results = objects.map { SaliencyResult(
                    bbox: VisionHandler.pixelBBox(from: $0.boundingBox, imageSize: size),
                    confidence: Double($0.confidence)
                )}
            }
        } catch let e {
            error = e.localizedDescription
        }

        let elapsed = (CFAbsoluteTimeGetCurrent() - start) * 1000
        JSONOutput.printResponse(
            command: "saliency",
            input: image,
            durationMs: elapsed,
            results: results,
            error: error
        )
    }
}
