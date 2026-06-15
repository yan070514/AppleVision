import ArgumentParser
import Foundation
import Vision

struct DetectHumanBodyPose: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "detect-pose",
        abstract: "Detect human body pose (19 joints)"
    )

    @Option(name: .long, help: "Path to input image")
    var image: String

    @Option(name: .long, help: "Which joints to return: all, upper, lower")
    var joints: String = "all"

    func run() throws {
        let start = CFAbsoluteTimeGetCurrent()
        let cgImage = try ImageLoader.loadCGImage(from: image)
        let size = CGSize(width: cgImage.width, height: cgImage.height)

        var results: [PoseResult] = []
        var error: String? = nil

        let request = VNDetectHumanBodyPoseRequest()
        let handler = VisionHandler(cgImage: cgImage)

        do {
            try handler.perform([request])
            if let observations = request.results {
                results = observations.compactMap { obs -> PoseResult? in
                    var allPoints: [VNHumanBodyPoseObservation.JointName: VNRecognizedPoint] = [:]
                    let groups: [VNHumanBodyPoseObservation.JointsGroupName] = {
                        switch joints {
                        case "upper": return [.face, .torso, .leftArm, .rightArm]
                        case "lower": return [.leftLeg, .rightLeg]
                        default: return [.all]
                        }
                    }()
                    for g in groups {
                        if let pts = try? obs.recognizedPoints(g) {
                            allPoints.merge(pts) { $1 }
                        }
                    }
                    guard !allPoints.isEmpty else { return nil }
                    let filtered = allPoints.filter { $0.value.confidence > 0.3 }
                    let jointDict = Dictionary(
                        uniqueKeysWithValues: filtered.map { (name, point) in
                            (jointName(name), VisionHandler.jointPointPixel(from: point, imageSize: size))
                        }
                    )
                    return PoseResult(joints: jointDict)
                }
            }
        } catch let e {
            error = e.localizedDescription
        }

        let elapsed = (CFAbsoluteTimeGetCurrent() - start) * 1000
        JSONOutput.printResponse(
            command: "detect-pose",
            input: image,
            durationMs: elapsed,
            results: results,
            error: error
        )
    }

    private func jointName(_ name: VNHumanBodyPoseObservation.JointName) -> String {
        switch name {
        case .nose: return "nose"
        case .leftEye: return "left_eye"
        case .rightEye: return "right_eye"
        case .leftEar: return "left_ear"
        case .rightEar: return "right_ear"
        case .leftShoulder: return "left_shoulder"
        case .rightShoulder: return "right_shoulder"
        case .leftElbow: return "left_elbow"
        case .rightElbow: return "right_elbow"
        case .leftWrist: return "left_wrist"
        case .rightWrist: return "right_wrist"
        case .leftHip: return "left_hip"
        case .rightHip: return "right_hip"
        case .leftKnee: return "left_knee"
        case .rightKnee: return "right_knee"
        case .leftAnkle: return "left_ankle"
        case .rightAnkle: return "right_ankle"
        case .root: return "root"
        case .neck: return "neck"
        default: return name.rawValue.rawValue
        }
    }
}
