import AppleVisionCore
import ArgumentParser
import Foundation
import Vision

struct DetectContours: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "detect-contours",
        abstract: "Detect object contours/edges in an image"
    )

    @Option(name: .long, help: "Path to input image")
    var image: String

    @Option(name: .long, help: "Contour detection threshold (0.0-1.0)")
    var threshold: Float = 0.5

    func run() throws {
        let start = CFAbsoluteTimeGetCurrent()
        let cgImage = try ImageLoader.loadCGImage(from: image)
        let size = CGSize(width: cgImage.width, height: cgImage.height)

        var results: [ContourResult] = []
        var error: String? = nil

        let request = VNDetectContoursRequest()
        request.contrastAdjustment = 2.0

        let handler = VisionHandler(cgImage: cgImage)

        do {
            try handler.perform([request])
            if let observations = request.results {
                for (i, obs) in observations.enumerated() {
                    let normalizedPath = obs.normalizedPath
                    var points: [PixelPoint] = []
                    normalizedPath.applyWithBlock { element in
                        let pt = element.pointee.points.pointee
                        points.append(VisionHandler.pixelPoint(from: pt, imageSize: size))
                    }
                    if !points.isEmpty {
                        results.append(ContourResult(
                            contour_index: i,
                            point_count: points.count,
                            normalized_points: points
                        ))
                    }
                }
            }
        } catch let e {
            error = e.localizedDescription
        }

        let elapsed = (CFAbsoluteTimeGetCurrent() - start) * 1000
        JSONOutput.printResponse(
            command: "detect-contours",
            input: image,
            durationMs: elapsed,
            results: results,
            error: error
        )
    }
}
