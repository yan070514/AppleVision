import Foundation

// Run all test suites
runModuleImportTests()
runImageLoaderTests()
runJSONOutputTests()
do {
    try runOutputTypesTests()
} catch {
    TestRunner.assert(false, "OutputTypesTests threw unexpected error: \(error)")
}

// Print summary and exit
let allPassed = TestRunner.summary()
exit(allPassed ? 0 : 1)
