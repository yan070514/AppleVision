import Testing
import Foundation
import Darwin
@testable import AppleVisionCLI

@Suite(.serialized) struct JSONOutputTests {

    @Test func testPrintResponseSuccess() {
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

        #expect(output.contains("\"command\""))
        #expect(output.contains("\"test-cmd\""))
        // On some Foundation versions, nil optionals are encoded as null;
        // on others they may be omitted entirely. Either is acceptable.
        let hasNullError = output.contains("\"error\" : null")
        let hasNoError = !output.contains("\"error\"")
        #expect(hasNullError || hasNoError)
        #expect(output.contains("\"hello\""))
    }

    @Test func testPrintResponseError() {
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

        #expect(output.contains("Something went wrong"))
    }
}

struct TestResult: Codable {
    let value: String
}
