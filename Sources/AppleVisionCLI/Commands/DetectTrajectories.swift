import ArgumentParser
import Foundation
import Vision

struct DetectTrajectories: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "detect-trajectories",
        abstract: "Detect object trajectories from video frame sequence"
    )

    @Option(name: .long, help: "Directory containing video frames (named in time order)")
    var frames: String

    func run() throws {
        let start = CFAbsoluteTimeGetCurrent()
        let fileManager = FileManager.default

        var results: [TrajectoryResult] = []
        var error: String? = nil

        let frameFiles: [String]
        do {
            let contents = try fileManager.contentsOfDirectory(atPath: frames)
            frameFiles = contents
                .filter { $0.hasSuffix(".png") || $0.hasSuffix(".jpg") || $0.hasSuffix(".jpeg") }
                .sorted()
                .map { frames + "/" + $0 }
        } catch {
            let elapsed = (CFAbsoluteTimeGetCurrent() - start) * 1000
            JSONOutput.printResponse(
                command: "detect-trajectories",
                input: frames,
                durationMs: elapsed,
                results: results,
                error: "Cannot read directory: \(error.localizedDescription)"
            )
            return
        }

        guard frameFiles.count >= 2 else {
            let elapsed = (CFAbsoluteTimeGetCurrent() - start) * 1000
            JSONOutput.printResponse(
                command: "detect-trajectories",
                input: frames,
                durationMs: elapsed,
                results: results,
                error: "Need at least 2 frames, found \(frameFiles.count)"
            )
            return
        }

        do {
            let cgFrames: [CGImage] = try frameFiles.map { try ImageLoader.loadCGImage(from: $0) }
            let sequenceHandler = VNSequenceRequestHandler()

            for (index, cgImage) in cgFrames.enumerated() {
                let trajectoryRequest = VNDetectTrajectoriesRequest(
                    frameAnalysisSpacing: CMTime(value: 1, timescale: 30),
                    trajectoryLength: 5,
                    completionHandler: nil
                )
                trajectoryRequest.objectMinimumNormalizedRadius = 0.01
                try sequenceHandler.perform([trajectoryRequest], on: cgImage)

                if let observations = trajectoryRequest.results {
                    for (ti, obs) in observations.enumerated() {
                        let pt = TrajectoryPoint(
                            x: Double(obs.detectedPoints.last?.x ?? 0),
                            y: Double(obs.detectedPoints.last?.y ?? 0),
                            time: Double(index) / 30.0
                        )

                        if ti < results.count {
                            results[ti].points.append(pt)
                        } else {
                            results.append(TrajectoryResult(
                                trajectory_id: ti,
                                points: [pt]
                            ))
                        }
                    }
                }
            }
        } catch let e {
            error = e.localizedDescription
        }

        let elapsed = (CFAbsoluteTimeGetCurrent() - start) * 1000
        JSONOutput.printResponse(
            command: "detect-trajectories",
            input: frames,
            durationMs: elapsed,
            results: results,
            error: error
        )
    }
}
