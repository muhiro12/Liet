import Foundation
import ImageIO
import LietLibrary
import UIKit
import UniformTypeIdentifiers

enum BatchImageProcessor {
    struct Outcome {
        let processedImages: [ProcessedBatchImage]
        let failureCount: Int
        let jpegFallbackCount: Int
        let ignoredCompressionCount: Int
    }
}

extension BatchImageProcessor {
    nonisolated static var exportContentTypes: [UTType] {
        [
            .jpeg,
            .png,
            ImageIOImageSupport.heicContentType
        ]
    }

    nonisolated static var heicEncoderAvailable: Bool {
        let typeIdentifiers = CGImageDestinationCopyTypeIdentifiers() as? [String] ?? []
        return typeIdentifiers.contains(ImageFileFormat.heic.sourceTypeIdentifier)
    }

    nonisolated static func resolvedOutputFormat(
        for originalFormat: ImageFileFormat,
        heicEncoderAvailable: Bool = Self.heicEncoderAvailable
    ) -> ImageFileFormat {
        BatchImageProcessingOperations.resolvedOutputFormat(
            for: originalFormat,
            heicEncoderAvailable: heicEncoderAvailable
        )
    }

    nonisolated static func projectedPixelSize(
        originalPixelSize: CGSize,
        resizeMode: BatchResizeMode
    ) -> CGSize {
        BatchImageProcessingOperations.projectedPixelSize(
            originalPixelSize: originalPixelSize,
            resizeMode: resizeMode
        )
    }

    nonisolated static func projectedPixelSize(
        for image: ImportedBatchImage,
        settings: BatchImageSettings
    ) -> CGSize {
        projectedPixelSize(
            originalPixelSize: image.pixelSize,
            resizeMode: settings.resizeMode
        )
    }

    nonisolated static func process(
        images: [ImportedBatchImage],
        settings: BatchImageSettings,
        heicEncoderAvailable: Bool = Self.heicEncoderAvailable
    ) -> Outcome {
        guard !images.isEmpty else {
            return .init(
                processedImages: [],
                failureCount: 0,
                jpegFallbackCount: 0,
                ignoredCompressionCount: 0
            )
        }

        guard let outputDirectory = try? makeOutputDirectory(
            prefix: "LietProcessed"
        ) else {
            return .init(
                processedImages: [],
                failureCount: images.count,
                jpegFallbackCount: 0,
                ignoredCompressionCount: 0
            )
        }

        var processedImages: [ProcessedBatchImage] = []
        var usedFilenames: Set<String> = []
        var failureCount = 0
        var jpegFallbackCount = 0
        var ignoredCompressionCount = 0

        for image in images {
            do {
                let processedImage = try processedImage(
                    for: image,
                    settings: settings,
                    heicEncoderAvailable: heicEncoderAvailable,
                    outputDirectory: outputDirectory,
                    usedFilenames: &usedFilenames
                )
                if processedImage.usedJPEGFallback {
                    jpegFallbackCount += 1
                }

                if processedImage.ignoredCompressionSetting {
                    ignoredCompressionCount += 1
                }

                processedImages.append(processedImage)
            } catch {
                failureCount += 1
            }
        }

        return .init(
            processedImages: processedImages,
            failureCount: failureCount,
            jpegFallbackCount: jpegFallbackCount,
            ignoredCompressionCount: ignoredCompressionCount
        )
    }
}

private extension BatchImageProcessor {
    nonisolated static func makeOutputDirectory(
        prefix: String
    ) throws -> URL {
        let outputDirectory = FileManager.default.temporaryDirectory.appendingPathComponent(
            "\(prefix)-\(UUID().uuidString)",
            isDirectory: true
        )
        try FileManager.default.createDirectory(
            at: outputDirectory,
            withIntermediateDirectories: true
        )
        return outputDirectory
    }

    nonisolated static func processedImage(
        for image: ImportedBatchImage,
        settings: BatchImageSettings,
        heicEncoderAvailable: Bool,
        outputDirectory: URL,
        usedFilenames: inout Set<String>
    ) throws -> ProcessedBatchImage {
        let plan = BatchImageProcessingOperations.makePlan(
            for: .init(
                originalFormat: image.originalFormat,
                originalPixelSize: image.pixelSize,
                selectionIndex: image.selectionIndex
            ),
            settings: settings,
            heicEncoderAvailable: heicEncoderAvailable,
            existingFilenames: usedFilenames
        )
        usedFilenames.insert(plan.outputFilename)
        let outputURL = outputDirectory.appendingPathComponent(
            plan.outputFilename
        )

        if plan.shouldCopyOriginal {
            return try copiedProcessedImage(
                for: image,
                plan: plan,
                outputURL: outputURL
            )
        }

        return try renderedProcessedImage(
            for: image,
            settings: settings,
            plan: plan,
            outputURL: outputURL
        )
    }

    nonisolated static func copiedProcessedImage(
        for image: ImportedBatchImage,
        plan: BatchImageProcessingOperations.Plan,
        outputURL: URL
    ) throws -> ProcessedBatchImage {
        try FileManager.default.copyItem(
            at: image.sourceURL,
            to: outputURL
        )
        return .init(
            sourceID: image.id,
            outputURL: outputURL,
            outputFilename: plan.outputFilename,
            outputFormat: plan.outputFormat,
            originalFormat: image.originalFormat,
            pixelSize: image.pixelSize,
            previewImage: image.previewImage,
            usedJPEGFallback: plan.usedJPEGFallback,
            ignoredCompressionSetting: plan.ignoredCompressionSetting
        )
    }

    nonisolated static func renderedProcessedImage(
        for image: ImportedBatchImage,
        settings: BatchImageSettings,
        plan: BatchImageProcessingOperations.Plan,
        outputURL: URL
    ) throws -> ProcessedBatchImage {
        let renderedOutput = try renderedImage(
            from: image.sourceURL,
            settings: settings,
            outputFormat: plan.outputFormat
        )
        try writeImage(
            renderedOutput.cgImage,
            format: plan.outputFormat,
            compression: settings.compression,
            outputURL: outputURL
        )
        let previewImage = try ImageIOImageSupport.previewImage(from: outputURL)

        return .init(
            sourceID: image.id,
            outputURL: outputURL,
            outputFilename: plan.outputFilename,
            outputFormat: plan.outputFormat,
            originalFormat: image.originalFormat,
            pixelSize: renderedOutput.pixelSize,
            previewImage: previewImage,
            usedJPEGFallback: plan.usedJPEGFallback,
            ignoredCompressionSetting: plan.ignoredCompressionSetting
        )
    }
}
