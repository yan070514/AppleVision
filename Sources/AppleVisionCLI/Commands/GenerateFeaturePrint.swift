import AppleVisionCore
import ArgumentParser
import Foundation
import Vision

struct GenerateFeaturePrint: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "featureprint",
        abstract: "Generate image feature print fingerprint",
        subcommands: [Generate.self, CompareFeaturePrint.self],
        defaultSubcommand: Generate.self
    )
}

struct Generate: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "generate",
        abstract: "Generate a feature print fingerprint from an image"
    )

    @Option(name: .long, help: "Path to input image")
    var image: String

    @Option(name: .long, help: "Path to save the fingerprint file")
    var output: String

    func run() throws {
        let start = CFAbsoluteTimeGetCurrent()
        let cgImage = try ImageLoader.loadCGImage(from: image)

        var results: [FeaturePrintGenerateResult] = []
        var error: String? = nil

        let request = VNGenerateImageFeaturePrintRequest()
        let handler = VisionHandler(cgImage: cgImage)

        do {
            try handler.perform([request])
            if let observation = request.results?.first as? VNFeaturePrintObservation {
                let data = observation.data
                let url = URL(fileURLWithPath: output)
                try data.write(to: url)
                results = [FeaturePrintGenerateResult(fingerprint_file: output)]
            }
        } catch let e {
            error = e.localizedDescription
        }

        let elapsed = (CFAbsoluteTimeGetCurrent() - start) * 1000
        JSONOutput.printResponse(
            command: "featureprint-generate",
            input: image,
            durationMs: elapsed,
            results: results,
            error: error
        )
    }
}

struct CompareFeaturePrint: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "compare",
        abstract: "Compare two images by feature print similarity"
    )

    @Option(name: .long, help: "Path to first image")
    var image1: String

    @Option(name: .long, help: "Path to second image")
    var image2: String

    func run() throws {
        let start = CFAbsoluteTimeGetCurrent()
        let cgImage1 = try ImageLoader.loadCGImage(from: image1)
        let cgImage2 = try ImageLoader.loadCGImage(from: image2)

        var results: [FeaturePrintCompareResult] = []
        var error: String? = nil

        let request1 = VNGenerateImageFeaturePrintRequest()
        let request2 = VNGenerateImageFeaturePrintRequest()

        let handler1 = VisionHandler(cgImage: cgImage1)
        let handler2 = VisionHandler(cgImage: cgImage2)

        do {
            try handler1.perform([request1])
            try handler2.perform([request2])

            if let obs1 = request1.results?.first as? VNFeaturePrintObservation,
               let obs2 = request2.results?.first as? VNFeaturePrintObservation {
                var distance: Float = 0
                try obs1.computeDistance(&distance, to: obs2)
                let similarity = Double(1.0 / (1.0 + distance))
                results = [FeaturePrintCompareResult(
                    similarity: similarity,
                    distance: Double(distance)
                )]
            }
        } catch let e {
            error = e.localizedDescription
        }

        let elapsed = (CFAbsoluteTimeGetCurrent() - start) * 1000
        JSONOutput.printResponse(
            command: "featureprint-compare",
            input: "\(image1),\(image2)",
            durationMs: elapsed,
            results: results,
            error: error
        )
    }
}
