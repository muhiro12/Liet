import Foundation
import ImageIO
import LietLibrary
import UIKit
import UniformTypeIdentifiers

enum ImageIOImageSupport {
    nonisolated static let previewMaxPixelSize = 320
    nonisolated static let fullScreenPreviewMaxPixelSize = 4_096
    nonisolated static let heicContentType = UTType(importedAs: "public.heic")
    nonisolated static let minimumPixelDimension = CGFloat(1)
    nonisolated static let minimumPixelSize = 1
    nonisolated static let bitsPerComponent = 8
    nonisolated static let centeringDivisor = minimumPixelDimension + minimumPixelDimension
}

extension ImageIOImageSupport {
    nonisolated static func imageSource(
        data: Data
    ) throws -> CGImageSource {
        guard let imageSource = CGImageSourceCreateWithData(
            data as CFData,
            nil
        ) else {
            throw BatchImageServiceError.failedToCreateImageSource
        }

        return imageSource
    }

    nonisolated static func imageSource(
        url: URL
    ) throws -> CGImageSource {
        guard let imageSource = CGImageSourceCreateWithURL(
            url as CFURL,
            nil
        ) else {
            throw BatchImageServiceError.failedToCreateImageSource
        }

        return imageSource
    }

    nonisolated static func pixelSize(
        from imageSource: CGImageSource
    ) throws -> CGSize {
        guard let properties = CGImageSourceCopyPropertiesAtIndex(
            imageSource,
            0,
            nil
        ) as? [CFString: Any],
        let pixelWidth = properties[kCGImagePropertyPixelWidth] as? CGFloat,
        let pixelHeight = properties[kCGImagePropertyPixelHeight] as? CGFloat else {
            throw BatchImageServiceError.failedToReadImageProperties
        }

        return .init(
            width: pixelWidth,
            height: pixelHeight
        )
    }

    nonisolated static func detectedFormat(
        for imageSource: CGImageSource,
        supportedTypeIdentifiers: [String]
    ) -> ImageFileFormat {
        if let sourceType = CGImageSourceGetType(imageSource) as String? {
            return .init(typeIdentifier: sourceType)
        }

        if let supportedTypeIdentifier = supportedTypeIdentifiers.first {
            return .init(typeIdentifier: supportedTypeIdentifier)
        }

        return .other
    }

    nonisolated static func previewImage(
        from url: URL,
        maxPixelSize: Int = previewMaxPixelSize
    ) throws -> UIImage {
        let imageSource = try imageSource(url: url)
        let cgImage = try thumbnailCGImage(
            from: imageSource,
            maxPixelSize: maxPixelSize
        )

        return .init(cgImage: cgImage)
    }

    nonisolated static func fullScreenPreviewImage(
        from url: URL,
        originalPixelSize: CGSize,
        maxPixelSizeLimit: Int = fullScreenPreviewMaxPixelSize
    ) throws -> UIImage {
        let cgImage = try cgImage(
            from: url,
            maxPixelSize: boundedMaxPixelSize(
                for: originalPixelSize,
                limit: maxPixelSizeLimit
            )
        )

        return .init(cgImage: cgImage)
    }

    nonisolated static func cgImage(
        from imageSource: CGImageSource,
        maxPixelSize: Int
    ) throws -> CGImage {
        try thumbnailCGImage(
            from: imageSource,
            maxPixelSize: maxPixelSize
        )
    }

    nonisolated static func cgImage(
        from url: URL,
        maxPixelSize: Int
    ) throws -> CGImage {
        let imageSource = try imageSource(url: url)
        return try thumbnailCGImage(
            from: imageSource,
            maxPixelSize: maxPixelSize
        )
    }

    nonisolated static func contentType(
        for format: ImageFileFormat
    ) -> UTType {
        switch format {
        case .jpeg, .other:
            .jpeg
        case .png:
            .png
        case .heic:
            heicContentType
        }
    }

    nonisolated static func projectedContentPixelSize(
        sourcePixelSize: CGSize,
        canvasPixelSize: CGSize,
        strategy: BatchExactResizeStrategy
    ) -> CGSize {
        if strategy == .stretch {
            return canvasPixelSize
        }

        let scale = resizeScale(
            sourcePixelSize: sourcePixelSize,
            canvasPixelSize: canvasPixelSize,
            strategy: strategy
        )

        return .init(
            width: max(minimumPixelDimension, sourcePixelSize.width * scale),
            height: max(minimumPixelDimension, sourcePixelSize.height * scale)
        )
    }

    nonisolated static func drawingRect(
        sourcePixelSize: CGSize,
        canvasPixelSize: CGSize,
        strategy: BatchExactResizeStrategy
    ) -> CGRect {
        if strategy == .stretch {
            return CGRect(
                origin: .zero,
                size: canvasPixelSize
            )
        }

        let scale = resizeScale(
            sourcePixelSize: sourcePixelSize,
            canvasPixelSize: canvasPixelSize,
            strategy: strategy
        )
        let scaledWidth = sourcePixelSize.width * scale
        let scaledHeight = sourcePixelSize.height * scale

        return .init(
            x: (canvasPixelSize.width - scaledWidth) / centeringDivisor,
            y: (canvasPixelSize.height - scaledHeight) / centeringDivisor,
            width: scaledWidth,
            height: scaledHeight
        )
    }

    nonisolated static func maxPixelSize(
        for pixelSize: CGSize
    ) -> Int {
        max(
            minimumPixelSize,
            Int(
                ceil(
                    max(
                        pixelSize.width,
                        pixelSize.height
                    )
                )
            )
        )
    }

    nonisolated static func boundedMaxPixelSize(
        for pixelSize: CGSize,
        limit: Int
    ) -> Int {
        min(
            maxPixelSize(for: pixelSize),
            max(minimumPixelSize, limit)
        )
    }

    nonisolated static func renderedCanvasImage(
        sourceImage: CGImage,
        canvasPixelSize: CGSize,
        drawingRect: CGRect,
        backgroundColor: UIColor?
    ) throws -> CGImage {
        let width = max(
            minimumPixelSize,
            Int(
                ceil(canvasPixelSize.width)
            )
        )
        let height = max(
            minimumPixelSize,
            Int(
                ceil(canvasPixelSize.height)
            )
        )
        guard let context = CGContext(
            data: nil,
            width: width,
            height: height,
            bitsPerComponent: bitsPerComponent,
            bytesPerRow: 0,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ) else {
            throw BatchImageServiceError.failedToEncodeImage
        }

        let bounds = CGRect(
            x: 0,
            y: 0,
            width: width,
            height: height
        )
        context.interpolationQuality = .high

        if let backgroundColor {
            context.setFillColor(backgroundColor.cgColor)
            context.fill(bounds)
        } else {
            context.clear(bounds)
        }

        context.draw(
            sourceImage,
            in: drawingRect
        )

        guard let renderedImage = context.makeImage() else {
            throw BatchImageServiceError.failedToEncodeImage
        }

        return renderedImage
    }
}

private extension ImageIOImageSupport {
    nonisolated static func resizeScale(
        sourcePixelSize: CGSize,
        canvasPixelSize: CGSize,
        strategy: BatchExactResizeStrategy
    ) -> CGFloat {
        let widthScale = canvasPixelSize.width / max(minimumPixelDimension, sourcePixelSize.width)
        let heightScale = canvasPixelSize.height / max(minimumPixelDimension, sourcePixelSize.height)

        switch strategy {
        case .stretch:
            return minimumPixelDimension
        case .contain:
            return min(widthScale, heightScale)
        case .coverCrop:
            return max(widthScale, heightScale)
        }
    }

    nonisolated static func thumbnailCGImage(
        from imageSource: CGImageSource,
        maxPixelSize: Int
    ) throws -> CGImage {
        let options: [CFString: Any] = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceShouldCacheImmediately: true,
            kCGImageSourceThumbnailMaxPixelSize: max(minimumPixelSize, maxPixelSize)
        ]

        guard let cgImage = CGImageSourceCreateThumbnailAtIndex(
            imageSource,
            0,
            options as CFDictionary
        ) else {
            throw BatchImageServiceError.failedToCreateThumbnail
        }

        return cgImage
    }
}
