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
