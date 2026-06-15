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
