import AppleVisionCore
import ArgumentParser
import Foundation
import Vision

struct RecognizeText: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "recognize-text",
        abstract: "Recognize text in an image (OCR)"
    )

    @Option(name: .long, help: "Path to input image")
    var image: String

    @Option(name: .long, help: "Recognition language code (e.g. zh-Hans, en, ja)")
    var lang: String = "zh-Hans"

    @Option(name: .long, help: "Recognition level: fast or accurate")
    var level: String = "accurate"

    func run() throws {
        let start = CFAbsoluteTimeGetCurrent()
        let cgImage = try ImageLoader.loadCGImage(from: image)
        let size = CGSize(width: cgImage.width, height: cgImage.height)

        var results: [TextResult] = []
        var error: String? = nil

        let request = VNRecognizeTextRequest()
        request.recognitionLanguages = [lang]
        request.recognitionLevel = level == "fast" ? .fast : .accurate
        request.usesLanguageCorrection = true

        let handler = VisionHandler(cgImage: cgImage)

        do {
            try handler.perform([request])
            if let observations = request.results {
                results = observations.compactMap { obs -> TextResult? in
                    guard let candidate = obs.topCandidates(1).first else { return nil }
                    return TextResult(
                        text: candidate.string,
                        confidence: Double(candidate.confidence),
                        bbox: VisionHandler.pixelBBox(from: obs.boundingBox, imageSize: size)
                    )
                }
            }
        } catch let e {
            error = e.localizedDescription
        }

        let elapsed = (CFAbsoluteTimeGetCurrent() - start) * 1000
        JSONOutput.printResponse(
            command: "recognize-text",
            input: image,
            durationMs: elapsed,
            results: results,
            error: error
        )
    }
}
