import AppleVisionCore
import ArgumentParser
import Foundation
import Vision

struct DetectHumanHandPose: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "detect-hand",
        abstract: "Detect hand pose (21 keypoints per hand)"
    )

    @Option(name: .long, help: "Path to input image")
    var image: String

    @Option(name: .long, help: "Maximum number of hands to detect")
    var maxHands: Int = 2

    func run() throws {
        let start = CFAbsoluteTimeGetCurrent()
        let cgImage = try ImageLoader.loadCGImage(from: image)
        let size = CGSize(width: cgImage.width, height: cgImage.height)

        var results: [HandResult] = []
        var error: String? = nil

        let request = VNDetectHumanHandPoseRequest()
        request.maximumHandCount = maxHands

        let handler = VisionHandler(cgImage: cgImage)

        do {
            try handler.perform([request])
            if let observations = request.results {
                results = observations.compactMap { obs -> HandResult? in
                    guard let points = try? obs.recognizedPoints(.all) else { return nil }
                    let filtered = points.filter { $0.value.confidence > 0.3 }
                    let jointDict = Dictionary(
                        uniqueKeysWithValues: filtered.map { (name, point) in
                            (handJointName(name), VisionHandler.jointPointPixel(from: point, imageSize: size))
                        }
                    )
                    return HandResult(joints: jointDict)
                }
            }
        } catch let e {
            error = e.localizedDescription
        }

        let elapsed = (CFAbsoluteTimeGetCurrent() - start) * 1000
        JSONOutput.printResponse(
            command: "detect-hand",
            input: image,
            durationMs: elapsed,
            results: results,
            error: error
        )
    }

    private func handJointName(_ name: VNHumanHandPoseObservation.JointName) -> String {
        switch name {
        case .thumbTip: return "thumb_tip"
        case .thumbIP: return "thumb_ip"
        case .thumbMP: return "thumb_mp"
        case .thumbCMC: return "thumb_cmc"
        case .indexTip: return "index_tip"
        case .indexDIP: return "index_dip"
        case .indexPIP: return "index_pip"
        case .indexMCP: return "index_mcp"
        case .middleTip: return "middle_tip"
        case .middleDIP: return "middle_dip"
        case .middlePIP: return "middle_pip"
        case .middleMCP: return "middle_mcp"
        case .ringTip: return "ring_tip"
        case .ringDIP: return "ring_dip"
        case .ringPIP: return "ring_pip"
        case .ringMCP: return "ring_mcp"
        case .littleTip: return "little_tip"
        case .littleDIP: return "little_dip"
        case .littlePIP: return "little_pip"
        case .littleMCP: return "little_mcp"
        case .wrist: return "wrist"
        default: return name.rawValue.rawValue
        }
    }
}
