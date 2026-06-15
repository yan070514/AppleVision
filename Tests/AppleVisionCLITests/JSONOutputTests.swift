import AppleVisionCore
import Foundation
import Darwin

struct TestResult: Codable {
    let value: String
}

func runJSONOutputTests() {
    TestRunner.suite("JSONOutput")

    // Test: printResponse with success
    do {
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

        TestRunner.assert(output.contains("\"command\""), "Output should contain 'command' key")
        TestRunner.assert(output.contains("\"test-cmd\""), "Output should contain command value")
        let hasNullError = output.contains("\"error\" : null")
        let hasNoError = !output.contains("\"error\"")
        TestRunner.assert(hasNullError || hasNoError,
                          "Output should not contain a non-null error key")
        TestRunner.assert(output.contains("\"hello\""), "Output should contain result value")
    }

    // Test: printResponse with error
    do {
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

        TestRunner.assert(output.contains("Something went wrong"),
                           "Output should contain error message")
    }
}
