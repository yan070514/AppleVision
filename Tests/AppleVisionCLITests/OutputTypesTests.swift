import Testing
import Foundation
@testable import AppleVisionCLI

@Test func testEncodeFaceResult() throws {
    let result = FaceResult(
        bbox: PixelBBox(x: 10, y: 20, width: 100, height: 200),
        confidence: 0.95,
        faceAngle: 15.0
    )
    let data = try JSONEncoder().encode(result)
    let dict = try #require(JSONSerialization.jsonObject(with: data) as? [String: Any])
    let confidence = try #require(dict["confidence"] as? Double)
    #expect(abs(confidence - 0.95) < 0.001)
    #expect(dict["bbox"] != nil)
}

@Test func testEncodeClassifyResult() throws {
    let result = ClassifyResult(label: "cat", confidence: 0.97)
    let data = try JSONEncoder().encode(result)
    let dict = try #require(JSONSerialization.jsonObject(with: data) as? [String: Any])
    let label = try #require(dict["label"] as? String)
    #expect(label == "cat")
    let confidence = try #require(dict["confidence"] as? Double)
    #expect(abs(confidence - 0.97) < 0.001)
}

@Test func testEncodeCLIResponse() throws {
    let response = CLIResponse(
        command: "detect-faces",
        input: "/test.jpg",
        duration_ms: 42.3,
        results: [FaceResult(bbox: PixelBBox(x: 0, y: 0, width: 100, height: 100), confidence: 0.9, faceAngle: nil)],
        error: nil
    )
    let data = try JSONEncoder().encode(response)
    let dict = try #require(JSONSerialization.jsonObject(with: data) as? [String: Any])
    let command = try #require(dict["command"] as? String)
    #expect(command == "detect-faces")
    #expect(dict["results"] != nil)
}
