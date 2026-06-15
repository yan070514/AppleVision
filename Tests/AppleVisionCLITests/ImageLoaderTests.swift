import Testing
import Foundation
@testable import AppleVisionCLI

@Test func testFileNotFound() {
    #expect {
        try ImageLoader.loadCGImage(from: "/nonexistent/path.jpg")
    } throws: { error in
        (error as? ImageLoaderError)?.errorDescription?.contains("File not found") == true
    }
}

@Test func testInvalidImage() throws {
    let path = NSTemporaryDirectory() + "test_invalid.txt"
    try? "not an image".write(toFile: path, atomically: true, encoding: .utf8)
    defer { try? FileManager.default.removeItem(atPath: path) }

    #expect {
        try ImageLoader.loadCGImage(from: path)
    } throws: { error in
        (error as? ImageLoaderError)?.errorDescription?.contains("not a valid image") == true
    }
}
