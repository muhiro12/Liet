import Foundation
import ImageIO
import LietLibrary
import UIKit

extension BatchImageProcessor {
    struct RenderedImage {
        let cgImage: CGImage
        let pixelSize: CGSize
    }

    nonisolated static func renderedImage(
        from sourceURL: URL,
        settings: BatchImageSettings,
        outputFormat: ImageFileFormat
    ) throws -> RenderedImage {
        let imageSource = try ImageIOImageSupport.imageSource(url: sourceURL)
        let originalPixelSize = try ImageIOImageSupport.pixelSize(from: imageSource)

        switch settings.resizeMode {
        case let .fitWithin(
            referenceDimension,
            pixels
        ):
            return try resizedImage(
                from: imageSource,
                targetPixelSize: fitWithinPixelSize(
                    originalPixelSize: originalPixelSize,
                    referenceDimension: referenceDimension,
                    referencePixels: pixels
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
        referenceDimension: BatchResizeReferenceDimension,
        referencePixels: Int
    ) -> CGSize {
        BatchImageProcessingPlanner.fitWithinPixelSize(
            originalPixelSize: originalPixelSize,
            referenceDimension: referenceDimension,
            referencePixels: referencePixels
        )
    }

    nonisolated static func exactCanvasPixelSize(
        widthPixels: Int,
        heightPixels: Int
    ) -> CGSize {
        BatchImageProcessingPlanner.exactCanvasPixelSize(
            widthPixels: widthPixels,
            heightPixels: heightPixels
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
        BatchImageProcessingPlanner.shouldCopyOriginal(
            originalFormat: image.originalFormat,
            originalPixelSize: image.pixelSize,
            settings: settings,
            outputFormat: outputFormat,
            targetPixelSize: projectedPixelSize(
                originalPixelSize: image.pixelSize,
                resizeMode: settings.resizeMode
            )
        )
    }
}
