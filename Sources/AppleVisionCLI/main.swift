import AppleVisionCore
import Foundation
import ArgumentParser

struct AppleVisionCLI: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "apple-vision",
        abstract: "Apple Vision CLI — 15 computer vision tools for image analysis",
        discussion: """
        Wraps Apple's Vision framework as CLI commands. Each subcommand takes an image
        path and outputs JSON to stdout. Use with Claude Code for AI-powered image analysis.

        Examples:
          apple-vision recognize-text --image photo.jpg
          apple-vision detect-faces --image selfie.png --confidence 0.7
          apple-vision featureprint compare --image1 a.jpg --image2 b.jpg
        """,
        subcommands: [
            DetectFaces.self,
            DetectFaceLandmarks.self,
            RecognizeText.self,
            DetectBarcodes.self,
            DetectHumanBodyPose.self,
            DetectHumanHandPose.self,
            ClassifyImage.self,
            GenerateFeaturePrint.self,
            DetectHumanRectangles.self,
            DetectContours.self,
            DetectAnimalBodyPose.self,
            GenerateSaliency.self,
            GenerateOpticalFlow.self,
            DetectTrajectories.self,
        ]
    )
}

AppleVisionCLI.main()
