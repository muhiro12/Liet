import Foundation
import ImageIO
@testable import Liet
import LietLibrary
import UIKit

enum BatchImageTestFactory {
    private enum Metrics {
        static let transparentAlpha: UInt8 = 0
        static let dominantColorThreshold: UInt8 = 200
        static let secondaryColorThreshold: UInt8 = 80
        static let missingImageSize = CGSize(width: 100, height: 100)
        static let processedImageSize = CGSize(
            width: missingImageSize.width + missingImageSize.width,
            height: missingImageSize.height
        )
        static let rendererScale = 1.0
        static let transparentRectXFactor = 0.22
        static let transparentRectYFactor = 0.19
        static let transparentRectWidthFactor = 0.33
        static let transparentRectHeightFactor = 0.33
        static let stripeWidthFactor = 0.1
        static let jpegCompressionQuality = 1.0
    }

    struct PixelSample: Equatable {
        let red: UInt8
        let green: UInt8
        let blue: UInt8
        let alpha: UInt8

        var isTransparent: Bool {
            alpha == Metrics.transparentAlpha
        }

        var isMostlyRed: Bool {
            alpha > Metrics.dominantColorThreshold &&
                red > Metrics.dominantColorThreshold &&
                green < Metrics.secondaryColorThreshold &&
                blue < Metrics.secondaryColorThreshold
        }

        var isMostlyGreen: Bool {
            alpha > Metrics.dominantColorThreshold &&
                red < Metrics.secondaryColorThreshold &&
                green > Metrics.dominantColorThreshold &&
                blue < Metrics.secondaryColorThreshold
        }

        var isMostlyBlue: Bool {
            alpha > Metrics.dominantColorThreshold &&
                red < Metrics.secondaryColorThreshold &&
                green < Metrics.secondaryColorThreshold &&
                blue > Metrics.dominantColorThreshold
        }
    }

    enum Failure: Error {
        case failedToCreateImageData
        case failedToCreateImageSource
        case failedToReadTypeIdentifier
    }

    static func makeImportedImage(
        format: ImageFileFormat,
        size: CGSize,
        originalFilename: String,
        selectionIndex: Int,
        image: UIImage? = nil
    ) throws -> ImportedBatchImage {
        let resolvedImage = image ?? makeUIImage(size: size)
        let sourceURL = try writeImageData(
            for: resolvedImage,
            format: format == .heic ? .jpeg : format,
            filename: originalFilename
        )

        return .init(
            sourceURL: sourceURL,
            originalFilename: originalFilename,
            originalFormat: format,
            pixelSize: size,
            previewImage: resolvedImage,
            selectionIndex: selectionIndex
        )
    }

    static func makeMissingImportedImage(
        format: ImageFileFormat,
        originalFilename: String,
        selectionIndex: Int
    ) -> ImportedBatchImage {
        .init(
            sourceURL: FileManager.default.temporaryDirectory
                .appendingPathComponent(UUID().uuidString)
                .appendingPathExtension(format.filenameExtension),
            originalFilename: originalFilename,
            originalFormat: format,
            pixelSize: Metrics.missingImageSize,
            previewImage: makeUIImage(size: Metrics.missingImageSize),
            selectionIndex: selectionIndex
        )
    }

    static func makeProcessedImage() throws -> ProcessedBatchImage {
        let image = makeUIImage(size: Metrics.processedImageSize)
        let outputURL = try writeImageData(
            for: image,
            format: .jpeg,
            filename: "processed.jpg"
        )

        return .init(
            sourceID: .init(),
            outputURL: outputURL,
            outputFilename: "processed.jpg",
            outputFormat: .jpeg,
            originalFormat: .jpeg,
            pixelSize: Metrics.processedImageSize,
            previewImage: image,
            usedJPEGFallback: false,
            ignoredCompressionSetting: false
        )
    }

    static func makeUIImage(
        size: CGSize
    ) -> UIImage {
        let format = UIGraphicsImageRendererFormat()
        format.scale = Metrics.rendererScale
        format.opaque = true
        let renderer = UIGraphicsImageRenderer(
            size: size,
            format: format
        )

        return renderer.image { context in
            context.cgContext.setFillColor(UIColor.systemBlue.cgColor)
            context.cgContext.fill(
                CGRect(
                    origin: .zero,
                    size: size
                )
            )
        }
    }

    static func makeTransparentUIImage(
        size: CGSize
    ) -> UIImage {
        let format = UIGraphicsImageRendererFormat()
        format.scale = Metrics.rendererScale
        format.opaque = false
        let renderer = UIGraphicsImageRenderer(
            size: size,
            format: format
        )

        return renderer.image { context in
            context.cgContext.clear(
                CGRect(
                    origin: .zero,
                    size: size
                )
            )
            context.cgContext.setFillColor(UIColor.red.cgColor)
            context.cgContext.fill(
                CGRect(
                    x: size.width * Metrics.transparentRectXFactor,
                    y: size.height * Metrics.transparentRectYFactor,
                    width: size.width * Metrics.transparentRectWidthFactor,
                    height: size.height * Metrics.transparentRectHeightFactor
                )
            )
        }
    }

    static func makeEdgeStripedUIImage(
        size: CGSize
    ) -> UIImage {
        let format = UIGraphicsImageRendererFormat()
        format.scale = Metrics.rendererScale
        format.opaque = true
        let renderer = UIGraphicsImageRenderer(
            size: size,
            format: format
        )

        return renderer.image { context in
            let fullRect = CGRect(
                origin: .zero,
                size: size
            )
            let stripeWidth = size.width * Metrics.stripeWidthFactor

            context.cgContext.setFillColor(UIColor.green.cgColor)
            context.cgContext.fill(fullRect)

            context.cgContext.setFillColor(UIColor.red.cgColor)
            context.cgContext.fill(
                CGRect(
                    x: 0,
                    y: 0,
                    width: stripeWidth,
                    height: size.height
                )
            )

            context.cgContext.setFillColor(UIColor.blue.cgColor)
            context.cgContext.fill(
                CGRect(
                    x: size.width - stripeWidth,
                    y: 0,
                    width: stripeWidth,
                    height: size.height
                )
            )
        }
    }

    static func writeImageData(
        for image: UIImage,
        format: ImageFileFormat,
        filename: String
    ) throws -> URL {
        let directoryURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(
                "LietTests-\(UUID().uuidString)",
                isDirectory: true
            )
        try FileManager.default.createDirectory(
            at: directoryURL,
            withIntermediateDirectories: true
        )

        let outputURL = directoryURL.appendingPathComponent(filename)
        let data: Data

        switch format {
        case .jpeg, .other, .heic:
            guard let jpegData = image.jpegData(
                compressionQuality: Metrics.jpegCompressionQuality
            ) else {
                throw Failure.failedToCreateImageData
            }

            data = jpegData
        case .png:
            guard let pngData = image.pngData() else {
                throw Failure.failedToCreateImageData
            }

            data = pngData
        }

        try data.write(
            to: outputURL,
            options: .atomic
        )

        return outputURL
    }
}
