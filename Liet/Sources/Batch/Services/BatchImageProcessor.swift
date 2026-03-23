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
        let preferredOutputFormat = originalFormat.preferredOutputFormat

        if preferredOutputFormat == .heic,
           !heicEncoderAvailable {
            return .jpeg
        }

        return preferredOutputFormat
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

                let outputFilename = ProcessedImageNaming.makeFilename(
                    originalFilename: image.originalFilename,
                    fallbackIndex: image.selectionIndex,
                    outputFormat: outputFormat,
                    existingFilenames: usedFilenames
                )
                usedFilenames.insert(outputFilename)
                let outputURL = outputDirectory.appendingPathComponent(outputFilename)

                if shouldCopyOriginalImage(
                    image: image,
                    settings: settings,
                    outputFormat: outputFormat
                ) {
                    try FileManager.default.copyItem(
                        at: image.sourceURL,
                        to: outputURL
                    )
                    processedImages.append(
                        .init(
                            sourceID: image.id,
                            outputURL: outputURL,
                            outputFilename: outputFilename,
                            outputFormat: outputFormat,
                            originalFormat: image.originalFormat,
                            pixelSize: image.pixelSize,
                            previewImage: image.previewImage,
                            usedJPEGFallback: usedJPEGFallback,
                            ignoredCompressionSetting: ignoredCompressionSetting
                        )
                    )
                } else {
                    let renderedImage = try renderedImage(
                        from: image.sourceURL,
                        resizeMode: settings.resizeMode,
                        outputFormat: outputFormat
                    )
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

private extension BatchImageProcessor {
    struct RenderedImage {
        let cgImage: CGImage
        let pixelSize: CGSize
    }

    nonisolated static func renderedImage(
        from sourceURL: URL,
        resizeMode: BatchResizeMode,
        outputFormat: ImageFileFormat
    ) throws -> RenderedImage {
        let imageSource = try ImageIOImageSupport.imageSource(url: sourceURL)
        let originalPixelSize = try ImageIOImageSupport.pixelSize(from: imageSource)

        switch resizeMode {
        case let .fitWithin(
            widthPixels,
            heightPixels
        ):
            return try resizedImage(
                from: imageSource,
                targetPixelSize: fitWithinPixelSize(
                    originalPixelSize: originalPixelSize,
                    targetWidthPixels: widthPixels,
                    targetHeightPixels: heightPixels
                )
            )
        case let .exactSize(
            widthPixels,
            heightPixels,
            strategy
        ):
            return try exactSizeImage(
                from: imageSource,
                originalPixelSize: originalPixelSize,
                outputFormat: outputFormat,
                widthPixels: widthPixels,
                heightPixels: heightPixels,
                strategy: strategy
            )
        }
    }

    nonisolated static func resizedImage(
        from imageSource: CGImageSource,
        targetPixelSize: CGSize
    ) throws -> RenderedImage {
        let cgImage = try ImageIOImageSupport.cgImage(
            from: imageSource,
            maxPixelSize: ImageIOImageSupport.maxPixelSize(
                for: targetPixelSize
            )
        )

        return .init(
            cgImage: cgImage,
            pixelSize: .init(
                width: cgImage.width,
                height: cgImage.height
            )
        )
    }

    // swiftlint:disable:next function_parameter_count
    nonisolated static func exactSizeImage(
        from imageSource: CGImageSource,
        originalPixelSize: CGSize,
        outputFormat: ImageFileFormat,
        widthPixels: Int,
        heightPixels: Int,
        strategy: BatchExactResizeStrategy
    ) throws -> RenderedImage {
        let canvasPixelSize = exactCanvasPixelSize(
            widthPixels: widthPixels,
            heightPixels: heightPixels
        )
        let projectedContentPixelSize = ImageIOImageSupport.projectedContentPixelSize(
            sourcePixelSize: originalPixelSize,
            canvasPixelSize: canvasPixelSize,
            strategy: strategy
        )
        let sourceImage = try ImageIOImageSupport.cgImage(
            from: imageSource,
            maxPixelSize: ImageIOImageSupport.maxPixelSize(
                for: projectedContentPixelSize
            )
        )
        let sourcePixelSize = CGSize(
            width: sourceImage.width,
            height: sourceImage.height
        )
        let drawingRect = ImageIOImageSupport.drawingRect(
            sourcePixelSize: sourcePixelSize,
            canvasPixelSize: canvasPixelSize,
            strategy: strategy
        )
        let backgroundColor: UIColor? = if outputFormat == .png {
            nil
        } else {
            .white
        }
        let renderedCGImage = try ImageIOImageSupport.renderedCanvasImage(
            sourceImage: sourceImage,
            canvasPixelSize: canvasPixelSize,
            drawingRect: drawingRect,
            backgroundColor: backgroundColor
        )

        return .init(
            cgImage: renderedCGImage,
            pixelSize: canvasPixelSize
        )
    }

    nonisolated static func fitWithinPixelSize(
        originalPixelSize: CGSize,
        targetWidthPixels: Int,
        targetHeightPixels: Int
    ) -> CGSize {
        let targetPixelSize = CGSize(
            width: max(1, targetWidthPixels),
            height: max(1, targetHeightPixels)
        )
        let widthScale = targetPixelSize.width /
            max(ImageIOImageSupport.minimumPixelDimension, originalPixelSize.width)
        let heightScale = targetPixelSize.height /
            max(ImageIOImageSupport.minimumPixelDimension, originalPixelSize.height)
        let scale = min(
            1,
            min(widthScale, heightScale)
        )

        return CGSize(
            width: max(
                ImageIOImageSupport.minimumPixelDimension,
                ceil(originalPixelSize.width * scale)
            ),
            height: max(
                ImageIOImageSupport.minimumPixelDimension,
                ceil(originalPixelSize.height * scale)
            )
        )
    }

    nonisolated static func exactCanvasPixelSize(
        widthPixels: Int,
        heightPixels: Int
    ) -> CGSize {
        .init(
            width: CGFloat(max(1, widthPixels)),
            height: CGFloat(max(1, heightPixels))
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

    nonisolated static func shouldCopyOriginalImage(
        image: ImportedBatchImage,
        settings: BatchImageSettings,
        outputFormat: ImageFileFormat
    ) -> Bool {
        guard case let .fitWithin(
            widthPixels,
            heightPixels
        ) = settings.resizeMode else {
            return false
        }

        guard outputFormat == image.originalFormat else {
            return false
        }

        let preservesSourceData = settings.compression == .off ||
            !outputFormat.supportsLossyCompressionQuality

        guard preservesSourceData else {
            return false
        }

        let targetPixelSize = fitWithinPixelSize(
            originalPixelSize: image.pixelSize,
            targetWidthPixels: widthPixels,
            targetHeightPixels: heightPixels
        )

        return Int(targetPixelSize.width) == Int(image.pixelSize.width) &&
            Int(targetPixelSize.height) == Int(image.pixelSize.height)
    }
}
