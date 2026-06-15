import AppleVisionCore
import Foundation

func runImageLoaderTests() {
    TestRunner.suite("ImageLoader")

    // Test: FileNotFound
    TestRunner.assertThrows(
        try ImageLoader.loadCGImage(from: "/nonexistent/path.jpg"),
        "loadCGImage with nonexistent path should throw"
    )

    // Test: Invalid image
    let path = NSTemporaryDirectory() + "test_invalid.txt"
    try? "not an image".write(toFile: path, atomically: true, encoding: .utf8)
    defer { try? FileManager.default.removeItem(atPath: path) }

    TestRunner.assertThrows(
        try ImageLoader.loadCGImage(from: path),
        "loadCGImage with invalid file should throw"
    )
}
