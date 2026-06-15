import AppleVisionCore
import Foundation

func runOutputTypesTests() throws {
    TestRunner.suite("OutputTypes")

    // Test: Encode FaceResult
    do {
        let result = FaceResult(
            bbox: PixelBBox(x: 10, y: 20, width: 100, height: 200),
            confidence: 0.95,
            faceAngle: 15.0
        )
        let data = try JSONEncoder().encode(result)
        guard let dict = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            TestRunner.assert(false, "FaceResult should produce valid JSON")
            return
        }
        TestRunner.assertNotNil(dict["confidence"], "FaceResult JSON should have confidence")
        if let confidence = dict["confidence"] as? Double {
            TestRunner.assertEqualFloat(confidence, 0.95, accuracy: 0.001, "FaceResult confidence should be 0.95")
        }
        TestRunner.assertNotNil(dict["bbox"], "FaceResult JSON should have bbox")
    }

    // Test: Encode ClassifyResult
    do {
        let result = ClassifyResult(label: "cat", confidence: 0.97)
        let data = try JSONEncoder().encode(result)
        guard let dict = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            TestRunner.assert(false, "ClassifyResult should produce valid JSON")
            return
        }
        if let label = dict["label"] as? String {
            TestRunner.assertEqual(label, "cat", "ClassifyResult label should be 'cat'")
        } else {
            TestRunner.assert(false, "ClassifyResult JSON should have label")
        }
        if let confidence = dict["confidence"] as? Double {
            TestRunner.assertEqualFloat(confidence, 0.97, accuracy: 0.001, "ClassifyResult confidence should be 0.97")
        } else {
            TestRunner.assert(false, "ClassifyResult JSON should have confidence")
        }
    }

    // Test: Encode CLIResponse
    do {
        let response = CLIResponse(
            command: "detect-faces",
            input: "/test.jpg",
            duration_ms: 42.3,
            results: [FaceResult(bbox: PixelBBox(x: 0, y: 0, width: 100, height: 100), confidence: 0.9, faceAngle: nil)],
            error: nil
        )
        let data = try JSONEncoder().encode(response)
        guard let dict = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            TestRunner.assert(false, "CLIResponse should produce valid JSON")
            return
        }
        if let command = dict["command"] as? String {
            TestRunner.assertEqual(command, "detect-faces", "CLIResponse command should be 'detect-faces'")
        } else {
            TestRunner.assert(false, "CLIResponse JSON should have command")
        }
        TestRunner.assertNotNil(dict["results"], "CLIResponse JSON should have results")
    }
}
