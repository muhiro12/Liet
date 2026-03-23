import Foundation
import ImageIO
import LietLibrary
import UniformTypeIdentifiers
import UIKit

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
        let preferredOutputFormat = originalFormat.preferredOutputFormat

        if preferredOutputFormat == .heic,
           !heicEncoderAvailable {
            return .jpeg
        }

        return preferredOutputFormat
    }

    nonisolated static func process(
        images: [ImportedBatchImage],
        settings: BatchImageSettings,
        heicEncoderAvailable: Bool = Self.heicEncoderAvailable
    ) async -> Outcome {
        guard !images.isEmpty else {
            return .init(
                processedImages: [],
                failureCount: 0,
                jpegFallbackCount: 0,
                ignoredCompressionCount: 0
            )
        }

        let outputDirectory = FileManager.default.temporaryDirectory
            .appendingPathComponent(
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
                let outputFormat = resolvedOutputFormat(
                    for: image.originalFormat,
                    heicEncoderAvailable: heicEncoderAvailable
                )
                let usedJPEGFallback = image.originalFormat.requiresOutputFallback ||
                (image.originalFormat == .heic && outputFormat == .jpeg)
                let ignoredCompressionSetting = outputFormat == .png

                if usedJPEGFallback {
                    jpegFallbackCount += 1
                }

                if ignoredCompressionSetting {
                    ignoredCompressionCount += 1
                }

                let renderedImage = try renderedImage(
                    from: image.sourceURL,
                    targetLongEdgePixels: settings.longEdgePixels
                )
                let outputFilename = ProcessedImageNaming.makeFilename(
                    originalFilename: image.originalFilename,
                    fallbackIndex: image.selectionIndex,
                    outputFormat: outputFormat,
                    existingFilenames: usedFilenames
                )
                usedFilenames.insert(outputFilename)
                let outputURL = outputDirectory.appendingPathComponent(outputFilename)
                try writeImage(
                    renderedImage.cgImage,
                    format: outputFormat,
                    compression: settings.compression,
                    outputURL: outputURL
                )
                let previewImage = try ImageIOImageSupport.previewImage(from: outputURL)
                processedImages.append(
                    .init(
                        sourceID: image.id,
                        outputURL: outputURL,
                        outputFilename: outputFilename,
                        outputFormat: outputFormat,
                        originalFormat: image.originalFormat,
                        pixelSize: renderedImage.pixelSize,
                        previewImage: previewImage,
                        usedJPEGFallback: usedJPEGFallback,
                        ignoredCompressionSetting: ignoredCompressionSetting
                    )
                )
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
    struct RenderedImage {
        let cgImage: CGImage
        let pixelSize: CGSize
    }

    nonisolated static func renderedImage(
        from sourceURL: URL,
        targetLongEdgePixels: Int
    ) throws -> RenderedImage {
        let imageSource = try ImageIOImageSupport.imageSource(url: sourceURL)
        let originalPixelSize = try ImageIOImageSupport.pixelSize(from: imageSource)
        let originalLongEdgePixels = Int(
            max(
                originalPixelSize.width,
                originalPixelSize.height
            )
        )
        let maxPixelSize = min(
            originalLongEdgePixels,
            targetLongEdgePixels
        )
        let cgImage = try ImageIOImageSupport.cgImage(
            from: sourceURL,
            maxPixelSize: maxPixelSize
        )
        let renderedPixelSize = CGSize(
            width: cgImage.width,
            height: cgImage.height
        )

        return .init(
            cgImage: cgImage,
            pixelSize: renderedPixelSize
        )
    }

    nonisolated static func writeImage(
        _ image: CGImage,
        format: ImageFileFormat,
        compression: BatchImageCompression,
        outputURL: URL
    ) throws {
        let data = NSMutableData()
        let typeIdentifier = format.sourceTypeIdentifier as CFString

        guard let destination = CGImageDestinationCreateWithData(
            data,
            typeIdentifier,
            1,
            nil
        ) else {
            throw BatchImageServiceError.failedToEncodeImage
        }

        var properties: [CFString: Any] = [:]

        if format.supportsLossyCompressionQuality {
            properties[kCGImageDestinationLossyCompressionQuality] = compression.quality
        }

        CGImageDestinationAddImage(
            destination,
            image,
            properties as CFDictionary
        )

        guard CGImageDestinationFinalize(destination) else {
            throw BatchImageServiceError.failedToEncodeImage
        }

        try (data as Data).write(
            to: outputURL,
            options: .atomic
        )
    }
}
