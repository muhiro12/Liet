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
        BatchImageProcessingPlanner.resolvedOutputFormat(
            for: originalFormat,
            heicEncoderAvailable: heicEncoderAvailable
        )
    }

    nonisolated static func projectedPixelSize(
        originalPixelSize: CGSize,
        resizeMode: BatchResizeMode
    ) -> CGSize {
        BatchImageProcessingPlanner.projectedPixelSize(
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

    // swiftlint:disable:next function_body_length
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

        let outputDirectory = FileManager.default.temporaryDirectory.appendingPathComponent(
            "LietProcessed-\(UUID().uuidString)",
            isDirectory: true
        )

        do {
            try FileManager.default.createDirectory(
                at: outputDirectory,
                withIntermediateDirectories: true
            )
        } catch {
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
                let plan = BatchImageProcessingPlanner.makePlan(
                    for: .init(
                        originalFilename: image.originalFilename,
                        originalFormat: image.originalFormat,
                        originalPixelSize: image.pixelSize,
                        selectionIndex: image.selectionIndex
                    ),
                    settings: settings,
                    heicEncoderAvailable: heicEncoderAvailable,
                    existingFilenames: usedFilenames
                )
                if plan.usedJPEGFallback {
                    jpegFallbackCount += 1
                }

                if plan.ignoredCompressionSetting {
                    ignoredCompressionCount += 1
                }
                usedFilenames.insert(plan.outputFilename)
                let outputURL = outputDirectory.appendingPathComponent(
                    plan.outputFilename
                )

                if plan.shouldCopyOriginal {
                    try FileManager.default.copyItem(
                        at: image.sourceURL,
                        to: outputURL
                    )
                    processedImages.append(
                        .init(
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
                    )
                } else {
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
                    processedImages.append(
                        .init(
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
                    )
                }
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
