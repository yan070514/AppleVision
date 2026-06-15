# Apple Vision CLI Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a Swift CLI binary `apple-vision` with 15 subcommands wrapping Apple Vision framework, plus a Claude Code Skill file.

**Architecture:** Single SPM package → one binary. Shared Core layer (image loading, JSON output, Vision handler) used by all 15 Commands. Swift ArgumentParser for CLI routing. Each command is one file, each Vision task type maps to one subcommand.

**Tech Stack:** Swift 5.9+, swift-argument-parser, Vision framework, macOS 14+

---

### Task 1: Project Scaffold & Package.swift

**Files:**
- Create: `Package.swift`

- [ ] **Step 1: Initialize SPM project**

```bash
cd /Users/qiuqi/Documents/QiuqiProject/AppleVision
swift package init --name AppleVisionCLI --type executable
```

- [ ] **Step 2: Verify the generated Package.swift exists**

```bash
ls Package.swift
```

Expected: `Package.swift` exists.

- [ ] **Step 3: Replace Package.swift with full dependencies**

```swift
// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "AppleVisionCLI",
    platforms: [
        .macOS(.v14)
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.3.0"),
    ],
    targets: [
        .executableTarget(
            name: "AppleVisionCLI",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
            ],
            path: "Sources/AppleVisionCLI"
        ),
        .testTarget(
            name: "AppleVisionCLITests",
            dependencies: ["AppleVisionCLI"],
            path: "Tests/AppleVisionCLITests"
        ),
    ]
)
```

- [ ] **Step 4: Create directory structure**

```bash
mkdir -p Sources/AppleVisionCLI/{Core,Models,Commands}
mkdir -p Tests/AppleVisionCLITests
mkdir -p Tests/fixtures
mkdir -p Skills
```

- [ ] **Step 5: Build empty project to verify**

```bash
swift build
```

Expected: Build succeeds (may have warning about unused main.swift). Exit code 0.

- [ ] **Step 6: Commit**

```bash
git init
git add Package.swift Sources/ Tests/
git commit -m "feat: scaffold SPM project with ArgumentParser dependency

Co-Authored-By: Claude <noreply@anthropic.com>"
```

---

### Task 2: Core — OutputTypes & Codable Models

**Files:**
- Create: `Sources/AppleVisionCLI/Models/OutputTypes.swift`

- [ ] **Step 1: Write OutputTypes.swift**

```swift
import Foundation

// MARK: - Unified Response Wrapper

struct CLIResponse<T: Codable>: Codable {
    let command: String
    let input: String
    let duration_ms: Double
    let results: [T]
    let error: String?
}

// MARK: - Common Geometry

struct PixelBBox: Codable {
    let x: Double
    let y: Double
    let width: Double
    let height: Double
}

struct PixelPoint: Codable {
    let x: Double
    let y: Double
}

struct JointPoint: Codable {
    let x: Double
    let y: Double
    let confidence: Double
}

// MARK: - Face

struct FaceResult: Codable {
    let bbox: PixelBBox
    let confidence: Double
    let faceAngle: Double?  // roll in degrees
}

struct LandmarkResult: Codable {
    let bbox: PixelBBox
    let confidence: Double
    let landmarks: [String: JointPoint]
}

// MARK: - Text

struct TextResult: Codable {
    let text: String
    let confidence: Double
    let bbox: PixelBBox
}

// MARK: - Barcode

struct BarcodeResult: Codable {
    let payload: String
    let format: String
    let bbox: PixelBBox
}

// MARK: - Pose

struct PoseResult: Codable {
    let joints: [String: JointPoint]
}

// MARK: - Hand

struct HandResult: Codable {
    let joints: [String: JointPoint]
}

// MARK: - Animal Pose

struct AnimalPoseResult: Codable {
    let joints: [String: JointPoint]
}

// MARK: - Classify

struct ClassifyResult: Codable {
    let label: String
    let confidence: Double
}

// MARK: - FeaturePrint

struct FeaturePrintGenerateResult: Codable {
    let fingerprint_file: String
}

struct FeaturePrintCompareResult: Codable {
    let similarity: Double
    let distance: Double
}

// MARK: - Human Rectangles

struct HumanResult: Codable {
    let bbox: PixelBBox
    let confidence: Double
}

// MARK: - Contours

struct ContourResult: Codable {
    let contour_index: Int
    let point_count: Int
    let normalized_points: [PixelPoint]
}

// MARK: - Saliency

struct SaliencyResult: Codable {
    let bbox: PixelBBox
    let confidence: Double
}

// MARK: - Optical Flow

struct OpticalFlowResult: Codable {
    let mean_dx: Double
    let mean_dy: Double
    let mean_magnitude: Double
}

// MARK: - Trajectories

struct TrajectoryPoint: Codable {
    let x: Double
    let y: Double
    let time: Double
}

struct TrajectoryResult: Codable {
    let trajectory_id: Int
    let points: [TrajectoryPoint]
}
```

- [ ] **Step 2: Build to verify compilation**

```bash
swift build
```

Expected: Build succeeds. Exit code 0.

- [ ] **Step 3: Commit**

```bash
git add Sources/AppleVisionCLI/Models/OutputTypes.swift
git commit -m "feat: add Codable output types for all 15 Vision tasks

Co-Authored-By: Claude <noreply@anthropic.com>"
```

---

### Task 3: Core — ImageLoader

**Files:**
- Create: `Sources/AppleVisionCLI/Core/ImageLoader.swift`

- [ ] **Step 1: Write ImageLoader.swift**

```swift
import AppKit
import Foundation

enum ImageLoaderError: LocalizedError {
    case fileNotFound(String)
    case invalidImage(String)

    var errorDescription: String? {
        switch self {
        case .fileNotFound(let path):
            return "File not found: \(path)"
        case .invalidImage(let path):
            return "File is not a valid image: \(path)"
        }
    }
}

struct ImageLoader {
    static func loadCGImage(from path: String) throws -> CGImage {
        guard FileManager.default.fileExists(atPath: path) else {
            throw ImageLoaderError.fileNotFound(path)
        }

        let url = URL(fileURLWithPath: path)
        guard let source = CGImageSourceCreateWithURL(url as CFURL, nil),
              let cgImage = CGImageSourceCreateImageAtIndex(source, 0, nil) else {
            throw ImageLoaderError.invalidImage(path)
        }

        return cgImage
    }
}
```

- [ ] **Step 2: Build to verify compilation**

```bash
swift build
```

Expected: Build succeeds. Exit code 0.

- [ ] **Step 3: Commit**

```bash
git add Sources/AppleVisionCLI/Core/ImageLoader.swift
git commit -m "feat: add ImageLoader for CGImage loading from file paths

Co-Authored-By: Claude <noreply@anthropic.com>"
```

---

### Task 4: Core — JSONOutput

**Files:**
- Create: `Sources/AppleVisionCLI/Core/JSONOutput.swift`

- [ ] **Step 1: Write JSONOutput.swift**

```swift
import Foundation

enum JSONOutput {
    static let encoder: JSONEncoder = {
        let e = JSONEncoder()
        e.outputFormatting = [.prettyPrinted, .sortedKeys]
        return e
    }()

    static func printResponse<T: Codable>(
        command: String,
        input: String,
        durationMs: Double,
        results: [T],
        error: String?
    ) {
        let response = CLIResponse(
            command: command,
            input: input,
            duration_ms: durationMs,
            results: results,
            error: error
        )

        do {
            let data = try encoder.encode(response)
            if let json = String(data: data, encoding: .utf8) {
                print(json)
            }
        } catch {
            // Fallback: output minimal error JSON
            print(#"{"command":"\#(command)","input":"","duration_ms":0,"results":[],"error":"JSON encoding failed: \#(error.localizedDescription)"}"#)
            fflush(stdout)
            Foundation.exit(4)
        }

        fflush(stdout)
    }
}
```

- [ ] **Step 2: Build to verify compilation**

```bash
swift build
```

Expected: Build succeeds. Exit code 0.

- [ ] **Step 3: Commit**

```bash
git add Sources/AppleVisionCLI/Core/JSONOutput.swift
git commit -m "feat: add JSONOutput helper for unified CLI response format

Co-Authored-By: Claude <noreply@anthropic.com>"
```

---

### Task 5: Core — VisionHandler

**Files:**
- Create: `Sources/AppleVisionCLI/Core/VisionHandler.swift`

- [ ] **Step 1: Write VisionHandler.swift**

```swift
import Vision
import Foundation

enum VisionHandlerError: LocalizedError {
    case visionError(String)

    var errorDescription: String? {
        switch self {
        case .visionError(let msg):
            return "Vision error: \(msg)"
        }
    }
}

struct VisionHandler {
    let cgImage: CGImage

    init(cgImage: CGImage) {
        self.cgImage = cgImage
    }

    func perform(_ requests: [VNRequest]) throws {
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        do {
            try handler.perform(requests)
        } catch {
            throw VisionHandlerError.visionError(error.localizedDescription)
        }
    }

    /// Convert a Vision normalized rect (0-1) to pixel rect
    static func pixelBBox(from boundingBox: CGRect, imageSize: CGSize) -> PixelBBox {
        // Vision uses bottom-left origin; flip to top-left
        let x = boundingBox.origin.x * imageSize.width
        let y = (1.0 - boundingBox.origin.y - boundingBox.height) * imageSize.height
        let w = boundingBox.width * imageSize.width
        let h = boundingBox.height * imageSize.height
        return PixelBBox(x: x, y: y, width: w, height: h)
    }

    /// Convert a Vision normalized point (0-1) to pixel point
    static func pixelPoint(from point: CGPoint, imageSize: CGSize) -> PixelPoint {
        let x = point.x * imageSize.width
        let y = (1.0 - point.y) * imageSize.height
        return PixelPoint(x: x, y: y)
    }

    static func jointPoint(from point: VNRecognizedPoint) -> JointPoint {
        JointPoint(
            x: Double(point.x),
            y: Double(1.0 - point.y),
            confidence: Double(point.confidence)
        )
    }

    /// Pixel-precision joint point (multiplied by image dimensions)
    static func jointPointPixel(
        from point: VNRecognizedPoint,
        imageSize: CGSize
    ) -> JointPoint {
        JointPoint(
            x: Double(point.x * imageSize.width),
            y: Double((1.0 - point.y) * imageSize.height),
            confidence: Double(point.confidence)
        )
    }
}
```

- [ ] **Step 2: Build to verify compilation**

```bash
swift build
```

Expected: Build succeeds. Exit code 0.

- [ ] **Step 3: Commit**

```bash
git add Sources/AppleVisionCLI/Core/VisionHandler.swift
git commit -m "feat: add VisionHandler for VNImageRequestHandler and coordinate conversion

Co-Authored-By: Claude <noreply@anthropic.com>"
```

---

### Task 6: Commands — Face Detection (detect-faces, detect-landmarks)

**Files:**
- Create: `Sources/AppleVisionCLI/Commands/DetectFaces.swift`
- Create: `Sources/AppleVisionCLI/Commands/DetectFaceLandmarks.swift`

- [ ] **Step 1: Write DetectFaces.swift**

```swift
import ArgumentParser
import Foundation
import Vision

struct DetectFaces: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "detect-faces",
        abstract: "Detect faces and return bounding boxes"
    )

    @Option(name: .long, help: "Path to input image")
    var image: String

    @Option(name: .long, help: "Minimum confidence threshold (0.0-1.0)")
    var confidence: Float = 0.5

    func run() throws {
        let start = CFAbsoluteTimeGetCurrent()
        let cgImage = try ImageLoader.loadCGImage(from: image)
        let size = CGSize(width: cgImage.width, height: cgImage.height)

        var results: [FaceResult] = []
        var error: String? = nil

        let request = VNDetectFaceRectanglesRequest()
        let handler = VisionHandler(cgImage: cgImage)

        do {
            try handler.perform([request])
            if let observations = request.results {
                results = observations
                    .filter { $0.confidence >= confidence }
                    .map { obs in
                        FaceResult(
                            bbox: VisionHandler.pixelBBox(from: obs.boundingBox, imageSize: size),
                            confidence: Double(obs.confidence),
                            faceAngle: obs.roll.map { Double(truncating: $0) * 180.0 / .pi }
                        )
                    }
            }
        } catch let e {
            error = e.localizedDescription
        }

        let elapsed = (CFAbsoluteTimeGetCurrent() - start) * 1000
        JSONOutput.printResponse(
            command: "detect-faces",
            input: image,
            durationMs: elapsed,
            results: results,
            error: error
        )
    }
}
```

- [ ] **Step 2: Write DetectFaceLandmarks.swift**

```swift
import ArgumentParser
import Foundation
import Vision

struct DetectFaceLandmarks: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "detect-landmarks",
        abstract: "Detect face landmarks (eyes, nose, mouth, etc.)"
    )

    @Option(name: .long, help: "Path to input image")
    var image: String

    @Option(name: .long, help: "Minimum confidence threshold (0.0-1.0)")
    var confidence: Float = 0.5

    func run() throws {
        let start = CFAbsoluteTimeGetCurrent()
        let cgImage = try ImageLoader.loadCGImage(from: image)
        let size = CGSize(width: cgImage.width, height: cgImage.height)

        var results: [LandmarkResult] = []
        var error: String? = nil

        let request = VNDetectFaceLandmarksRequest()
        let handler = VisionHandler(cgImage: cgImage)

        do {
            try handler.perform([request])
            if let observations = request.results {
                results = observations
                    .filter { $0.confidence >= confidence }
                    .map { obs in
                        LandmarkResult(
                            bbox: VisionHandler.pixelBBox(from: obs.boundingBox, imageSize: size),
                            confidence: Double(obs.confidence),
                            landmarks: extractLandmarks(from: obs, imageSize: size)
                        )
                    }
            }
        } catch let e {
            error = e.localizedDescription
        }

        let elapsed = (CFAbsoluteTimeGetCurrent() - start) * 1000
        JSONOutput.printResponse(
            command: "detect-landmarks",
            input: image,
            durationMs: elapsed,
            results: results,
            error: error
        )
    }

    private func extractLandmarks(
        from observation: VNFaceObservation,
        imageSize: CGSize
    ) -> [String: JointPoint] {
        var dict: [String: JointPoint] = [:]
        let regions: [(String, VNFaceLandmarkRegion2D?)] = [
            ("face_contour", observation.landmarks?.faceContour),
            ("left_eyebrow", observation.landmarks?.leftEyebrow),
            ("right_eyebrow", observation.landmarks?.rightEyebrow),
            ("left_eye", observation.landmarks?.leftEye),
            ("right_eye", observation.landmarks?.rightEye),
            ("nose", observation.landmarks?.nose),
            ("nose_crest", observation.landmarks?.noseCrest),
            ("median_line", observation.landmarks?.medianLine),
            ("outer_lips", observation.landmarks?.outerLips),
            ("inner_lips", observation.landmarks?.innerLips),
            ("left_pupil", observation.landmarks?.leftPupil),
            ("right_pupil", observation.landmarks?.rightPupil),
        ]

        for (name, region) in regions {
            guard let points = region?.normalizedPoints else { continue }
            for (i, point) in points.enumerated() {
                let key = points.count > 1 ? "\(name)_\(i)" : name
                dict[key] = JointPoint(
                    x: Double(point.x * imageSize.width),
                    y: Double((1.0 - point.y) * imageSize.height),
                    confidence: 1.0 // landmark points don't have per-point confidence
                )
            }
        }

        return dict
    }
}
```

- [ ] **Step 3: Build to verify compilation**

```bash
swift build
```

Expected: Build succeeds. Exit code 0.

- [ ] **Step 4: Commit**

```bash
git add Sources/AppleVisionCLI/Commands/DetectFaces.swift Sources/AppleVisionCLI/Commands/DetectFaceLandmarks.swift
git commit -m "feat: add detect-faces and detect-landmarks commands

Co-Authored-By: Claude <noreply@anthropic.com>"
```

---

### Task 7: Commands — Text Recognition

**Files:**
- Create: `Sources/AppleVisionCLI/Commands/RecognizeText.swift`

- [ ] **Step 1: Write RecognizeText.swift**

```swift
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
```

- [ ] **Step 2: Build to verify compilation**

```bash
swift build
```

Expected: Build succeeds. Exit code 0.

- [ ] **Step 3: Commit**

```bash
git add Sources/AppleVisionCLI/Commands/RecognizeText.swift
git commit -m "feat: add recognize-text command (OCR)

Co-Authored-By: Claude <noreply@anthropic.com>"
```

---

### Task 8: Commands — Barcode Detection

**Files:**
- Create: `Sources/AppleVisionCLI/Commands/DetectBarcodes.swift`

- [ ] **Step 1: Write DetectBarcodes.swift**

```swift
import ArgumentParser
import Foundation
import Vision

struct DetectBarcodes: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "detect-barcodes",
        abstract: "Detect and decode barcodes/QR codes"
    )

    @Option(name: .long, help: "Path to input image")
    var image: String

    @Option(name: .long, help: "Comma-separated barcode formats (qr,code128,ean8,ean13,upce,aztec,pdf417,itf14,datamatrix,codabar,gs1databar). Default: all")
    var formats: String = ""

    func run() throws {
        let start = CFAbsoluteTimeGetCurrent()
        let cgImage = try ImageLoader.loadCGImage(from: image)
        let size = CGSize(width: cgImage.width, height: cgImage.height)

        var results: [BarcodeResult] = []
        var error: String? = nil

        let request = VNDetectBarcodesRequest()
        let handler = VisionHandler(cgImage: cgImage)

        do {
            try handler.perform([request])
            if let observations = request.results {
                results = observations.compactMap { obs in
                    guard let payload = obs.payloadStringValue else { return nil }
                    let format = barcodeFormatName(obs.symbology)
                    return BarcodeResult(
                        payload: payload,
                        format: format,
                        bbox: VisionHandler.pixelBBox(from: obs.boundingBox, imageSize: size)
                    )
                }
            }
        } catch let e {
            error = e.localizedDescription
        }

        let elapsed = (CFAbsoluteTimeGetCurrent() - start) * 1000
        JSONOutput.printResponse(
            command: "detect-barcodes",
            input: image,
            durationMs: elapsed,
            results: results,
            error: error
        )
    }

    private func barcodeFormatName(_ symbology: VNBarcodeSymbology) -> String {
        switch symbology {
        case .qr: return "QR"
        case .code128: return "Code128"
        case .ean8: return "EAN-8"
        case .ean13: return "EAN-13"
        case .upce: return "UPC-E"
        case .aztec: return "Aztec"
        case .pdf417: return "PDF417"
        case .itf14: return "ITF14"
        case .dataMatrix: return "DataMatrix"
        case .codabar: return "Codabar"
        case .gs1DataBar: return "GS1 DataBar"
        case .gs1DataBarExpanded: return "GS1 DataBar Expanded"
        case .gs1DataBarLimited: return "GS1 DataBar Limited"
        default: return "Unknown"
        }
    }
}
```

- [ ] **Step 2: Build to verify compilation**

```bash
swift build
```

Expected: Build succeeds. Exit code 0.

- [ ] **Step 3: Commit**

```bash
git add Sources/AppleVisionCLI/Commands/DetectBarcodes.swift
git commit -m "feat: add detect-barcodes command

Co-Authored-By: Claude <noreply@anthropic.com>"
```

---

### Task 9: Commands — Body Pose (detect-pose, detect-hand, detect-humans, detect-animals)

**Files:**
- Create: `Sources/AppleVisionCLI/Commands/DetectHumanBodyPose.swift`
- Create: `Sources/AppleVisionCLI/Commands/DetectHumanHandPose.swift`
- Create: `Sources/AppleVisionCLI/Commands/DetectHumanRectangles.swift`
- Create: `Sources/AppleVisionCLI/Commands/DetectAnimalBodyPose.swift`

- [ ] **Step 1: Write DetectHumanBodyPose.swift**

```swift
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
                    let group: VNHumanBodyPoseObservation.JointsGroupName = {
                        switch joints {
                        case "upper": return .upperBody
                        case "lower": return .lowerBody
                        default: return .all
                        }
                    }()
                    guard let points = try? obs.recognizedPoints(group) else { return nil }
                    let filtered = points.filter { $0.value.confidence > 0.3 }
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
        default: return name.rawValue
        }
    }
}
```

- [ ] **Step 2: Write DetectHumanHandPose.swift**

```swift
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
        default: return name.rawValue
        }
    }
}
```

- [ ] **Step 3: Write DetectHumanRectangles.swift**

```swift
import ArgumentParser
import Foundation
import Vision

struct DetectHumanRectangles: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "detect-humans",
        abstract: "Detect human bodies (bounding boxes, fast)"
    )

    @Option(name: .long, help: "Path to input image")
    var image: String

    @Option(name: .long, help: "Minimum confidence threshold (0.0-1.0)")
    var confidence: Float = 0.5

    func run() throws {
        let start = CFAbsoluteTimeGetCurrent()
        let cgImage = try ImageLoader.loadCGImage(from: image)
        let size = CGSize(width: cgImage.width, height: cgImage.height)

        var results: [HumanResult] = []
        var error: String? = nil

        let request = VNDetectHumanRectanglesRequest()
        let handler = VisionHandler(cgImage: cgImage)

        do {
            try handler.perform([request])
            if let observations = request.results {
                results = observations
                    .filter { $0.confidence >= confidence }
                    .map { HumanResult(
                        bbox: VisionHandler.pixelBBox(from: $0.boundingBox, imageSize: size),
                        confidence: Double($0.confidence)
                    )}
            }
        } catch let e {
            error = e.localizedDescription
        }

        let elapsed = (CFAbsoluteTimeGetCurrent() - start) * 1000
        JSONOutput.printResponse(
            command: "detect-humans",
            input: image,
            durationMs: elapsed,
            results: results,
            error: error
        )
    }
}
```

- [ ] **Step 4: Write DetectAnimalBodyPose.swift**

```swift
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
```

- [ ] **Step 5: Build to verify compilation**

```bash
swift build
```

Expected: Build succeeds. Exit code 0.

- [ ] **Step 6: Commit**

```bash
git add Sources/AppleVisionCLI/Commands/DetectHumanBodyPose.swift Sources/AppleVisionCLI/Commands/DetectHumanHandPose.swift Sources/AppleVisionCLI/Commands/DetectHumanRectangles.swift Sources/AppleVisionCLI/Commands/DetectAnimalBodyPose.swift
git commit -m "feat: add body pose commands (detect-pose, detect-hand, detect-humans, detect-animals)

Co-Authored-By: Claude <noreply@anthropic.com>"
```

---

### Task 10: Commands — Image Analysis (classify, featureprint, contours, saliency)

**Files:**
- Create: `Sources/AppleVisionCLI/Commands/ClassifyImage.swift`
- Create: `Sources/AppleVisionCLI/Commands/GenerateFeaturePrint.swift`
- Create: `Sources/AppleVisionCLI/Commands/CompareFeaturePrint.swift`
- Create: `Sources/AppleVisionCLI/Commands/DetectContours.swift`
- Create: `Sources/AppleVisionCLI/Commands/GenerateSaliency.swift`

- [ ] **Step 1: Write ClassifyImage.swift**

```swift
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
```

- [ ] **Step 2: Write GenerateFeaturePrint.swift**

```swift
import ArgumentParser
import Foundation
import Vision

struct GenerateFeaturePrint: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "featureprint",
        abstract: "Generate image feature print fingerprint",
        subcommands: [Generate.self, Compare.self],
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

struct Compare: ParsableCommand {
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
```

- [ ] **Step 3: Write DetectContours.swift**

```swift
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
                    // Sample points from the path for JSON output
                    var points: [PixelPoint] = []
                    normalizedPath?.forEach { element in
                        switch element.type {
                        case .moveToPoint, .addLineToPoint:
                            let pt = element.points.pointee
                            points.append(VisionHandler.pixelPoint(from: pt, imageSize: size))
                        default: break
                        }
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
```

- [ ] **Step 4: Write GenerateSaliency.swift**

```swift
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
```

- [ ] **Step 5: Build to verify compilation**

```bash
swift build
```

Expected: Build succeeds. Exit code 0.

- [ ] **Step 6: Commit**

```bash
git add Sources/AppleVisionCLI/Commands/ClassifyImage.swift Sources/AppleVisionCLI/Commands/GenerateFeaturePrint.swift Sources/AppleVisionCLI/Commands/DetectContours.swift Sources/AppleVisionCLI/Commands/GenerateSaliency.swift
git commit -m "feat: add image analysis commands (classify, featureprint, contours, saliency)

Co-Authored-By: Claude <noreply@anthropic.com>"
```

---

### Task 11: Commands — Video Analysis (optical-flow, detect-trajectories)

**Files:**
- Create: `Sources/AppleVisionCLI/Commands/GenerateOpticalFlow.swift`
- Create: `Sources/AppleVisionCLI/Commands/DetectTrajectories.swift`

- [ ] **Step 1: Write GenerateOpticalFlow.swift**

```swift
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
                // Compute mean displacement from the flow field
                let pixelBuffer = observation.pixelBuffer
                CVPixelBufferLockBaseAddress(pixelBuffer, .readOnly)
                defer { CVPixelBufferUnlockBaseAddress(pixelBuffer, .readOnly) }

                let width = CVPixelBufferGetWidth(pixelBuffer)
                let height = CVPixelBufferGetHeight(pixelBuffer)
                let bytesPerRow = CVPixelBufferGetBytesPerRow(pixelBuffer)

                guard let baseAddress = CVPixelBufferGetBaseAddress(pixelBuffer) else {
                    error = "Failed to access optical flow pixel buffer"
                    throw VisionHandlerError.visionError("Failed to access pixel buffer")
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
```

- [ ] **Step 2: Write DetectTrajectories.swift**

```swift
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

        // Collect sorted frame paths
        let frameFiles = try fileManager.contentsOfDirectory(atPath: frames)
            .filter { $0.hasSuffix(".png") || $0.hasSuffix(".jpg") || $0.hasSuffix(".jpeg") }
            .sorted()
            .map { frames + "/" + $0 }

        guard frameFiles.count >= 2 else {
            error = "Need at least 2 frames, found \(frameFiles.count)"
            JSONOutput.printResponse(
                command: "detect-trajectories",
                input: frames,
                durationMs: 0,
                results: results,
                error: error
            )
            return
        }

        // Load all frames as CGImages
        let cgFrames: [CGImage] = try frameFiles.map { try ImageLoader.loadCGImage(from: $0) }

        // Create a VNVideoProcessor request
        // Since VNVideoProcessor needs a URL, write frames to temp URLs and process
        // For simplicity: use frame-by-frame VNDetectTrajectoriesRequest

        let trajectoryRequest = VNDetectTrajectoriesRequest()
        trajectoryRequest.minimumObjectSize = 0.01

        do {
            // Process each frame sequentially via VNSequenceRequestHandler
            let sequenceHandler = VNSequenceRequestHandler()
            var lastObs: VNTrajectoryObservation?

            for (index, cgImage) in cgFrames.enumerated() {
                trajectoryRequest.results = nil
                try sequenceHandler.perform([trajectoryRequest], on: cgImage)

                if let observations = trajectoryRequest.results {
                    for (ti, obs) in observations.enumerated() {
                        let pt = TrajectoryPoint(
                            x: Double(obs.detectedPoints.last?.x ?? 0),
                            y: Double(obs.detectedPoints.last?.y ?? 0),
                            time: Double(index) / 30.0  // assume 30fps
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
```

- [ ] **Step 3: Build to verify compilation**

```bash
swift build
```

Expected: Build succeeds. Exit code 0.

- [ ] **Step 4: Commit**

```bash
git add Sources/AppleVisionCLI/Commands/GenerateOpticalFlow.swift Sources/AppleVisionCLI/Commands/DetectTrajectories.swift
git commit -m "feat: add video analysis commands (optical-flow, detect-trajectories)

Co-Authored-By: Claude <noreply@anthropic.com>"
```

---

### Task 12: main.swift — Entry Point & Routing

**Files:**
- Replace existing: `Sources/AppleVisionCLI/main.swift`

- [ ] **Step 1: Write main.swift**

```swift
import Foundation
import ArgumentParser

struct AppleVisionCLI: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "apple-vision",
        abstract: "Apple Vision CLI — 15 computer vision tools for image analysis",
        discussion: """
        Wraps Apple's Vision framework as CLI commands. Each subcommand takes an image
        path and outputs JSON to stdout. Use with Claude Code for AI-powered image analysis.

        Examples:
          apple-vision recognize-text --image photo.jpg
          apple-vision detect-faces --image selfie.png --confidence 0.7
          apple-vision featureprint compare --image1 a.jpg --image2 b.jpg
        """,
        subcommands: [
            DetectFaces.self,
            DetectFaceLandmarks.self,
            RecognizeText.self,
            DetectBarcodes.self,
            DetectHumanBodyPose.self,
            DetectHumanHandPose.self,
            ClassifyImage.self,
            GenerateFeaturePrint.self,
            DetectHumanRectangles.self,
            DetectContours.self,
            DetectAnimalBodyPose.self,
            GenerateSaliency.self,
            GenerateOpticalFlow.self,
            DetectTrajectories.self,
        ]
    )
}

AppleVisionCLI.main()
```

- [ ] **Step 2: Build release binary**

```bash
swift build -c release
```

Expected: Build succeeds. Exit code 0.

- [ ] **Step 3: Verify --help works**

```bash
.build/release/AppleVisionCLI --help
```

Expected: Output shows 15 subcommands.

- [ ] **Step 4: Commit**

```bash
git add Sources/AppleVisionCLI/main.swift
git commit -m "feat: add main entry point with all 15 subcommands

Co-Authored-By: Claude <noreply@anthropic.com>"
```

---

### Task 13: Create Symbolic Link for Easy CLI Access

**Files:**
- Create: symlink at a convenient location

- [ ] **Step 1: Create symlink in PATH**

```bash
ln -sf "$(pwd)/.build/release/AppleVisionCLI" /usr/local/bin/apple-vision
```

- [ ] **Step 2: Verify symlink works**

```bash
apple-vision --help
```

Expected: Same output as Step 3 in Task 12.

---

### Task 14: Skill File

**Files:**
- Create: `Skills/apple-vision.md`

- [ ] **Step 1: Write applevision.md**

Prepare to write the Skill file to `Skills/apple-vision.md`. Write the following content to that file:

```markdown
---
name: apple-vision
description: Apple Vision 图像分析——通过 CLI 调用 macOS Vision 框架的 15 个计算机视觉工具
---

# Apple Vision CLI Skill

## 什么时候用这个 Skill

当用户给你一张图片并要求你做以下事情时：

- 提取图片中的文字
- 检测人脸、五官
- 扫描/解码二维码或条码
- 分析人体姿态、手势
- 识别动物姿态
- 分类图片内容
- 比较两张图片的相似度
- 检测物体轮廓
- 生成显著性热力图*
- 分析视频帧之间的运动（光流/轨迹）

> 注意：带 * 的功能是 Vision 框架的"注意力区域"输出，是人眼可能关注的位置估计，不是物体的语义轮廓。不要误解为语义分割。

## 15 个命令速查

### 文字
| 命令 | 用途 | 示例 |
|------|------|------|
| `recognize-text` | OCR 文字识别 | `apple-vision recognize-text --image screenshot.png --lang zh-Hans` |

### 人脸
| 命令 | 用途 | 示例 |
|------|------|------|
| `detect-faces` | 检测人脸位置 | `apple-vision detect-faces --image photo.jpg` |
| `detect-landmarks` | 检测五官关键点 | `apple-vision detect-landmarks --image face.jpg` |

### 条码
| 命令 | 用途 | 示例 |
|------|------|------|
| `detect-barcodes` | 扫码/解码 | `apple-vision detect-barcodes --image qrcode.png` |

### 人体 & 动物
| 命令 | 用途 | 示例 |
|------|------|------|
| `detect-pose` | 人体姿态 19 关节 | `apple-vision detect-pose --image yoga.jpg --joints all` |
| `detect-hand` | 手部 21 关键点 | `apple-vision detect-hand --image gesture.jpg` |
| `detect-humans` | 人体边框（快） | `apple-vision detect-humans --image crowd.jpg` |
| `detect-animals` | 猫狗姿态 | `apple-vision detect-animals --image pet.jpg` |

### 图像分析
| 命令 | 用途 | 示例 |
|------|------|------|
| `classify` | 图像分类 | `apple-vision classify --image scene.jpg` |
| `featureprint generate` | 生成图像指纹 | `apple-vision featureprint generate --image a.jpg --output a.fp` |
| `featureprint compare` | 比较两张图 | `apple-vision featureprint compare --image1 a.jpg --image2 b.jpg` |
| `detect-contours` | 检测物体轮廓 | `apple-vision detect-contours --image object.jpg` |
| `saliency` | 显著性区域 | `apple-vision saliency --image design.jpg --type attention` |

### 视频/帧序列
| 命令 | 用途 | 示例 |
|------|------|------|
| `optical-flow` | 两帧之间运动 | `apple-vision optical-flow --from frame1.jpg --to frame2.jpg` |
| `detect-trajectories` | 多帧物体轨迹 | `apple-vision detect-trajectories --frames ./frame_dir/` |

## 调用规范

**全部通过 Bash tool 调用：**

```bash
apple-vision <子命令> --image <图片路径> [选项...]
```

**输出格式**：所有命令输出统一 JSON 到 stdout：

```json
{
  "command": "<子命令名>",
  "input": "<输入路径>",
  "duration_ms": 42.3,
  "results": [...],
  "error": null
}
```

## 关键约束

1. **必须指定 `--image`（或等效参数）**，不支持 stdin 管道输入
2. **坐标全部是像素绝对值**，原点在左上角。和 Vision 默认归一化坐标 (0-1) 不同
3. **`recognize-text` 默认 `.accurate` 模式**（精确但慢），大量文本可切 `--level fast`
4. **先 `featureprint generate` 再 `featureprint compare`**，指纹文件是二进制 `.fp` 格式
5. **`optical-flow` 和 `detect-trajectories` 需要多帧**，单张图片无法分析运动
6. **`detect-trajectories --frames` 需要目录**，帧按文件名排序，需预先从视频拆帧
7. **`similarity` 值 0~1**，1.0 = 完全相同；`distance` 是 L2 欧氏距离，越小越相似

## 常见组合模式

### 场景 1：分析截图中的报错
```
1. apple-vision recognize-text --image error_screenshot.png
2. 从返回的 TextResult 中提取错误信息文本
```

### 场景 2：分析瑜伽体式是否标准
```
1. apple-vision detect-pose --image user_pose.jpg
2. apple-vision detect-pose --image reference_pose.jpg
3. 对比两组 JointPoint 的坐标
```

### 场景 3：检查两张 UI 截图是否一致（视觉回归）
```
1. apple-vision featureprint generate --image ui_before.png --output before.fp
2. apple-vision featureprint generate --image ui_after.png --output after.fp
3. （或者直接用 compare 模式）
   apple-vision featureprint compare --image1 ui_before.png --image2 ui_after.png
4. similarity < 0.95 表示变化显著
```

### 场景 4：扫描产品条码并分类
```
1. apple-vision detect-barcodes --image product.jpg
2. 用 payload 值（如 EAN-13）查询商品 API
3. apple-vision classify --image product.jpg
4. 交叉验证条码和视觉分类是否一致
```

### 场景 5：分析视频中物体的运动
```
1. ffmpeg -i video.mp4 -vf fps=30 frames/%04d.jpg   # 预先拆帧
2. apple-vision optical-flow --from frames/0001.jpg --to frames/0002.jpg
3. 对多帧重复，得出运动模式
```

## 错误处理

| 退出码 | 含义 | Claude 应该怎么处理 |
|--------|------|-------------------|
| 0 | 成功 | 解析 results JSON |
| 1 | 图片不存在 | 检查路径是否正确 |
| 2 | 不是有效图片 | 确认文件格式（支持 JPG/PNG/HEIC） |
| 3 | 格式不支持 | 转换图片格式 |
| 4 | Vision 框架内部错误 | 重试一次，仍失败则告知用户图片可能损坏 |
| 5 | 缺少参数 | 补充必需参数 |

## 系统要求

- macOS 14+（Vision 框架完整 API 覆盖）
- 编译后的二进制位于 `/usr/local/bin/apple-vision`
```

- [ ] **Step 2: Verify the file exists**

```bash
wc -l Skills/apple-vision.md
```

Expected: File has content.

- [ ] **Step 3: Commit**

```bash
git add Skills/apple-vision.md
git commit -m "feat: add Claude Code skill file for apple-vision

Co-Authored-By: Claude <noreply@anthropic.com>"
```

---

### Task 15: README

**Files:**
- Create: `README.md`

- [ ] **Step 1: Write README.md**

```markdown
# Apple Vision CLI

15 个计算机视觉 CLI 工具，封装 Apple Vision 框架。配合 Claude Code 使用，让 AI 能"看懂"图片。

## 安装

```bash
cd AppleVision
swift build -c release
sudo ln -sf "$(pwd)/.build/release/AppleVisionCLI" /usr/local/bin/apple-vision
```

## 依赖

- macOS 14+
- Swift 5.9+
- Xcode 15+

## 使用

```bash
apple-vision recognize-text --image photo.jpg
apple-vision detect-faces --image selfie.png
apple-vision detect-barcodes --image qrcode.png
apple-vision detect-pose --image yoga.jpg
apple-vision classify --image scene.jpg
apple-vision featureprint compare --image1 a.jpg --image2 b.jpg
```

## 全部命令

| 命令 | 功能 |
|------|------|
| `recognize-text` | OCR 文字识别 |
| `detect-faces` | 人脸检测 |
| `detect-landmarks` | 五官关键点 |
| `detect-barcodes` | 条码/二维码 |
| `detect-pose` | 人体姿态 |
| `detect-hand` | 手部姿态 |
| `detect-humans` | 人体检测 |
| `detect-animals` | 动物姿态 |
| `classify` | 图像分类 |
| `featureprint generate` | 图像指纹 |
| `featureprint compare` | 相似度比较 |
| `detect-contours` | 轮廓检测 |
| `saliency` | 显著性区域 |
| `optical-flow` | 光流 |
| `detect-trajectories` | 轨迹检测 |

## 输出格式

所有命令输出 JSON 到 stdout，坐标均为像素绝对值：

```json
{
  "command": "recognize-text",
  "input": "/path/to/image.jpg",
  "duration_ms": 42.3,
  "results": [...],
  "error": null
}
```
```

- [ ] **Step 2: Commit**

```bash
git add README.md
git commit -m "docs: add README with usage and full command list

Co-Authored-By: Claude <noreply@anthropic.com>"
```

---

### Task 16: Unit Tests — Core Layer

**Files:**
- Create: `Tests/AppleVisionCLITests/ImageLoaderTests.swift`
- Create: `Tests/AppleVisionCLITests/JSONOutputTests.swift`
- Create: `Tests/AppleVisionCLITests/OutputTypesTests.swift`

- [ ] **Step 1: Write ImageLoaderTests.swift**

```swift
import XCTest
@testable import AppleVisionCLI

final class ImageLoaderTests: XCTestCase {
    func testFileNotFound() {
        XCTAssertThrowsError(try ImageLoader.loadCGImage(from: "/nonexistent/path.jpg")) { error in
            XCTAssertTrue(error.localizedDescription.contains("File not found"))
        }
    }

    func testInvalidImage() {
        let path = NSTemporaryDirectory() + "test_invalid.txt"
        try? "not an image".write(toFile: path, atomically: true, encoding: .utf8)
        defer { try? FileManager.default.removeItem(atPath: path) }

        XCTAssertThrowsError(try ImageLoader.loadCGImage(from: path)) { error in
            XCTAssertTrue(error.localizedDescription.contains("not a valid image"))
        }
    }
}
```

- [ ] **Step 2: Write JSONOutputTests.swift**

```swift
import XCTest
@testable import AppleVisionCLI

final class JSONOutputTests: XCTestCase {
    func testPrintResponseSuccess() {
        // Capture stdout
        let pipe = Pipe()
        let originalStdout = dup(STDOUT_FILENO)
        dup2(pipe.fileHandleForWriting.fileDescriptor, STDOUT_FILENO)

        JSONOutput.printResponse(
            command: "test-cmd",
            input: "/test.jpg",
            durationMs: 10.5,
            results: [TestResult(value: "hello")],
            error: nil
        )

        fflush(stdout)
        dup2(originalStdout, STDOUT_FILENO)
        pipe.fileHandleForWriting.closeFile()

        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8)!

        XCTAssertTrue(output.contains("\"command\""))
        XCTAssertTrue(output.contains("\"test-cmd\""))
        XCTAssertTrue(output.contains("\"error\" : null"))
        XCTAssertTrue(output.contains("\"hello\""))
    }

    func testPrintResponseError() {
        let pipe = Pipe()
        let originalStdout = dup(STDOUT_FILENO)
        dup2(pipe.fileHandleForWriting.fileDescriptor, STDOUT_FILENO)

        JSONOutput.printResponse(
            command: "test",
            input: "/x.jpg",
            durationMs: 0,
            results: [TestResult(value: "")],
            error: "Something went wrong"
        )

        fflush(stdout)
        dup2(originalStdout, STDOUT_FILENO)
        pipe.fileHandleForWriting.closeFile()

        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8)!

        XCTAssertTrue(output.contains("Something went wrong"))
    }
}

struct TestResult: Codable {
    let value: String
}
```

- [ ] **Step 3: Write OutputTypesTests.swift**

```swift
import XCTest
@testable import AppleVisionCLI

final class OutputTypesTests: XCTestCase {
    func testEncodeFaceResult() throws {
        let result = FaceResult(
            bbox: PixelBBox(x: 10, y: 20, width: 100, height: 200),
            confidence: 0.95,
            faceAngle: 15.0
        )
        let data = try JSONEncoder().encode(result)
        let dict = try JSONSerialization.jsonObject(with: data) as! [String: Any]
        XCTAssertEqual(dict["confidence"] as! Double, 0.95, accuracy: 0.001)
        XCTAssertNotNil(dict["bbox"])
    }

    func testEncodeClassifyResult() throws {
        let result = ClassifyResult(label: "cat", confidence: 0.97)
        let data = try JSONEncoder().encode(result)
        let dict = try JSONSerialization.jsonObject(with: data) as! [String: Any]
        XCTAssertEqual(dict["label"] as! String, "cat")
        XCTAssertEqual(dict["confidence"] as! Double, 0.97, accuracy: 0.001)
    }

    func testEncodeCLIResponse() throws {
        let response = CLIResponse(
            command: "detect-faces",
            input: "/test.jpg",
            duration_ms: 42.3,
            results: [FaceResult(bbox: PixelBBox(x: 0, y: 0, width: 100, height: 100), confidence: 0.9, faceAngle: nil)],
            error: nil
        )
        let data = try JSONEncoder().encode(response)
        let dict = try JSONSerialization.jsonObject(with: data) as! [String: Any]
        XCTAssertEqual(dict["command"] as! String, "detect-faces")
        XCTAssertNotNil(dict["results"])
    }
}
```

- [ ] **Step 4: Run unit tests**

```bash
swift test
```

Expected: All 5 tests pass. Exit code 0.

- [ ] **Step 5: Commit**

```bash
git add Tests/AppleVisionCLITests/
git commit -m "test: add unit tests for Core layer and OutputTypes

Co-Authored-By: Claude <noreply@anthropic.com>"
```

---

### Task 17: End-to-End Smoke Test

- [ ] **Step 1: Build release binary**

```bash
cd /Users/qiuqi/Documents/QiuqiProject/AppleVision
swift build -c release
```

Expected: Build succeeds. Exit code 0.

- [ ] **Step 2: Verify all subcommands appear in help**

```bash
.build/release/AppleVisionCLI --help | grep -c "detect-\|recognize\|classify\|featureprint\|saliency\|optical"
```

Expected: Output >= 14 (count of unique subcommands).

- [ ] **Step 3: Test error handling with missing image**

```bash
.build/release/AppleVisionCLI detect-faces --image /nonexistent.jpg 2>&1
```

Expected: JSON output with `"error": "File not found: /nonexistent.jpg"` and exit code 1.

- [ ] **Step 4: Test error handling with invalid image**

```bash
echo "not an image" > /tmp/test.txt
.build/release/AppleVisionCLI recognize-text --image /tmp/test.txt 2>&1
rm /tmp/test.txt
```

Expected: JSON output with error about invalid image, exit code 2.

- [ ] **Step 5: Commit any final fixes**

```bash
git status
```

If changes exist:

```bash
git add -A
git commit -m "chore: final fixes from smoke testing

Co-Authored-By: Claude <noreply@anthropic.com>"
```
