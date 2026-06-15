// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "AppleVisionCLI",
    platforms: [
        .macOS(.v14)
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.3.0"),
    ],
    targets: [
        .target(
            name: "AppleVisionCore",
            path: "Sources/AppleVisionCore"
        ),
        .executableTarget(
            name: "AppleVisionCLI",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                "AppleVisionCore",
            ],
            path: "Sources/AppleVisionCLI"
        ),
        .executableTarget(
            name: "AppleVisionCLITests",
            dependencies: ["AppleVisionCore"],
            path: "Tests/AppleVisionCLITests"
        ),
    ]
)
