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
