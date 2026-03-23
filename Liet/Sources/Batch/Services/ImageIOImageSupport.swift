import Foundation
import ImageIO
import LietLibrary
import UIKit
import UniformTypeIdentifiers

enum ImageIOImageSupport {
    nonisolated static let previewMaxPixelSize = 320
    nonisolated static let heicContentType = UTType(importedAs: "public.heic")
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
}

private extension ImageIOImageSupport {
    nonisolated static func thumbnailCGImage(
        from imageSource: CGImageSource,
        maxPixelSize: Int
    ) throws -> CGImage {
        let options: [CFString: Any] = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceShouldCacheImmediately: true,
            kCGImageSourceThumbnailMaxPixelSize: max(1, maxPixelSize)
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
