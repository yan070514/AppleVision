import AppleVisionCore
import Foundation

func runModuleImportTests() {
    TestRunner.suite("Module Import")

    // Just verify the module can be imported by accessing a known type
    TestRunner.assert("FaceResult" == String(describing: FaceResult.self),
                       "AppleVisionCore module imports successfully")
}
