import AppleVisionCore
import ArgumentParser
import Foundation
import Vision

struct DetectAnimalBodyPose: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "detect-animals",
        abstract: "Detect animal body pose (cats and dogs)"
    )

    @Option(name: .long, help: "Path to input image")
    var image: String

    func run() throws {
        let start = CFAbsoluteTimeGetCurrent()
        let cgImage = try ImageLoader.loadCGImage(from: image)
        let size = CGSize(width: cgImage.width, height: cgImage.height)

        var results: [AnimalPoseResult] = []
        var error: String? = nil

        let request = VNDetectAnimalBodyPoseRequest()
        let handler = VisionHandler(cgImage: cgImage)

        do {
            try handler.perform([request])
            if let observations = request.results {
                results = observations.compactMap { obs -> AnimalPoseResult? in
                    guard let points = try? obs.recognizedPoints(.all) else { return nil }
                    let filtered = points.filter { $0.value.confidence > 0.3 }
                    let jointDict = Dictionary(
                        uniqueKeysWithValues: filtered.map { (name, point) in
                            (name.rawValue.rawValue, VisionHandler.jointPointPixel(from: point, imageSize: size))
                        }
                    )
                    return AnimalPoseResult(joints: jointDict)
                }
            }
        } catch let e {
            error = e.localizedDescription
        }

        let elapsed = (CFAbsoluteTimeGetCurrent() - start) * 1000
        JSONOutput.printResponse(
            command: "detect-animals",
            input: image,
            durationMs: elapsed,
            results: results,
            error: error
        )
    }
}
