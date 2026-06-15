import ArgumentParser
import Foundation
import Vision

struct GenerateOpticalFlow: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "optical-flow",
        abstract: "Compute optical flow between two images"
    )

    @Option(name: .long, help: "Path to first (from) image")
    var from: String

    @Option(name: .long, help: "Path to second (to) image")
    var to: String

    func run() throws {
        let start = CFAbsoluteTimeGetCurrent()
        let cgImage1 = try ImageLoader.loadCGImage(from: from)
        let cgImage2 = try ImageLoader.loadCGImage(from: to)

        var results: [OpticalFlowResult] = []
        var error: String? = nil

        let request = VNGenerateOpticalFlowRequest(targetedCGImage: cgImage2, options: [:])

        let handler = VisionHandler(cgImage: cgImage1)

        do {
            try handler.perform([request])
            if let observation = request.results?.first as? VNPixelBufferObservation {
                let pixelBuffer = observation.pixelBuffer
                CVPixelBufferLockBaseAddress(pixelBuffer, .readOnly)
                defer { CVPixelBufferUnlockBaseAddress(pixelBuffer, .readOnly) }

                let width = CVPixelBufferGetWidth(pixelBuffer)
                let height = CVPixelBufferGetHeight(pixelBuffer)
                let bytesPerRow = CVPixelBufferGetBytesPerRow(pixelBuffer)

                guard let baseAddress = CVPixelBufferGetBaseAddress(pixelBuffer) else {
                    error = "Failed to access optical flow pixel buffer"
                    let elapsed = (CFAbsoluteTimeGetCurrent() - start) * 1000
                    JSONOutput.printResponse(
                        command: "optical-flow",
                        input: "\(from),\(to)",
                        durationMs: elapsed,
                        results: results,
                        error: error
                    )
                    return
                }

                var totalDx: Float = 0
                var totalDy: Float = 0
                var totalMag: Float = 0
                let count = Float(width * height)

                for y in 0..<height {
                    let rowPtr = baseAddress.advanced(by: y * bytesPerRow)
                        .assumingMemoryBound(to: Float.self)
                    for x in 0..<width {
                        let dx = rowPtr[x * 2]
                        let dy = rowPtr[x * 2 + 1]
                        totalDx += dx
                        totalDy += dy
                        totalMag += sqrt(dx * dx + dy * dy)
                    }
                }

                results = [OpticalFlowResult(
                    mean_dx: Double(totalDx / count),
                    mean_dy: Double(totalDy / count),
                    mean_magnitude: Double(totalMag / count)
                )]
            }
        } catch let e {
            error = e.localizedDescription
        }

        let elapsed = (CFAbsoluteTimeGetCurrent() - start) * 1000
        JSONOutput.printResponse(
            command: "optical-flow",
            input: "\(from),\(to)",
            durationMs: elapsed,
            results: results,
            error: error
        )
    }
}
