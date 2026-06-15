// swift-tools-version: 5.9
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
        .executableTarget(
            name: "AppleVisionCLI",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
            ],
            path: "Sources/AppleVisionCLI"
        ),
        .testTarget(
            name: "AppleVisionCLITests",
            dependencies: ["AppleVisionCLI"],
            path: "Tests/AppleVisionCLITests"
        ),
    ]
)
