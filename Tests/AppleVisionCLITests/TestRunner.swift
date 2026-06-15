import Foundation

enum TestRunner {

    nonisolated(unsafe) private static var passed = 0
    nonisolated(unsafe) private static var failed = 0
    nonisolated(unsafe) private static var currentSuite = ""

    static func suite(_ name: String) {
        currentSuite = name
        fputs("Suite: \(name)\n", stderr)
    }

    static func assert(_ condition: Bool, _ message: String, file: String = #file, line: Int = #line) {
        if condition {
            passed += 1
        } else {
            failed += 1
            fputs("  [FAIL] \(message) (\(file):\(line))\n", stderr)
        }
    }

    static func assertEqual<T: Equatable>(_ a: T, _ b: T, _ message: String, file: String = #file, line: Int = #line) {
        if a == b {
            passed += 1
        } else {
            failed += 1
            fputs("  [FAIL] \(message) - expected '\(b)', got '\(a)' (\(file):\(line))\n", stderr)
        }
    }

    static func assertNil(_ value: Any?, _ message: String, file: String = #file, line: Int = #line) {
        if value == nil {
            passed += 1
        } else {
            failed += 1
            fputs("  [FAIL] \(message) - expected nil (\(file):\(line))\n", stderr)
        }
    }

    static func assertThrows<T>(_ expression: @autoclosure () throws -> T, _ message: String, file: String = #file, line: Int = #line) -> Bool {
        do {
            _ = try expression()
            failed += 1
            fputs("  [FAIL] \(message) - expected error to be thrown (\(file):\(line))\n", stderr)
            return false
        } catch {
            passed += 1
            return true
        }
    }

    static func assertNotNil(_ value: Any?, _ message: String, file: String = #file, line: Int = #line) {
        if value != nil {
            passed += 1
        } else {
            failed += 1
            fputs("  [FAIL] \(message) - expected non-nil (\(file):\(line))\n", stderr)
        }
    }

    static func assertEqualFloat(_ a: Double, _ b: Double, accuracy: Double, _ message: String, file: String = #file, line: Int = #line) {
        if abs(a - b) < accuracy {
            passed += 1
        } else {
            failed += 1
            fputs("  [FAIL] \(message) - expected \(b) +-\(accuracy), got \(a) (\(file):\(line))\n", stderr)
        }
    }

    /// Returns `true` if all tests passed.
    static func summary() -> Bool {
        fputs("Results: \(passed) passed, \(failed) failed\n", stderr)
        return failed == 0
    }
}
