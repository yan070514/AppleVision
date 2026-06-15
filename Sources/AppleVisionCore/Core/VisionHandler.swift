import Vision
import Foundation

public enum VisionHandlerError: LocalizedError {
    case visionError(String)

    public var errorDescription: String? {
        switch self {
        case .visionError(let msg):
            return "Vision error: \(msg)"
        }
    }
}

public struct VisionHandler {
    public let cgImage: CGImage

    public init(cgImage: CGImage) {
        self.cgImage = cgImage
    }

    public func perform(_ requests: [VNRequest]) throws {
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        do {
            try handler.perform(requests)
        } catch {
            throw VisionHandlerError.visionError(error.localizedDescription)
        }
    }

    /// Convert a Vision normalized rect (0-1) to pixel rect, flipping y-axis from bottom-left to top-left origin
    public static func pixelBBox(from boundingBox: CGRect, imageSize: CGSize) -> PixelBBox {
        let x = boundingBox.origin.x * imageSize.width
        let y = (1.0 - boundingBox.origin.y - boundingBox.height) * imageSize.height
        let w = boundingBox.width * imageSize.width
        let h = boundingBox.height * imageSize.height
        return PixelBBox(x: x, y: y, width: w, height: h)
    }

    /// Convert a Vision normalized point (0-1) to pixel point, flipping y-axis
    public static func pixelPoint(from point: CGPoint, imageSize: CGSize) -> PixelPoint {
        let x = point.x * imageSize.width
        let y = (1.0 - point.y) * imageSize.height
        return PixelPoint(x: x, y: y)
    }

    /// Convert VNRecognizedPoint to JointPoint (normalized 0-1 coords)
    public static func jointPoint(from point: VNRecognizedPoint) -> JointPoint {
        JointPoint(
            x: Double(point.x),
            y: Double(1.0 - point.y),
            confidence: Double(point.confidence)
        )
    }

    /// Convert VNRecognizedPoint to JointPoint in pixel coords
    public static func jointPointPixel(
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
