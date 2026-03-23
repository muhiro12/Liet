import Foundation
import ImageIO
@testable import Liet
import LietLibrary
import UIKit

// swiftlint:disable no_magic_numbers
enum BatchImageTestFactory {
    struct PixelSample: Equatable {
        let red: UInt8
        let green: UInt8
        let blue: UInt8
        let alpha: UInt8

        var isTransparent: Bool {
            alpha == 0
        }

        var isMostlyRed: Bool {
            alpha > 200 &&
                red > 200 &&
                green < 80 &&
                blue < 80
        }

        var isMostlyGreen: Bool {
            alpha > 200 &&
                red < 80 &&
                green > 200 &&
                blue < 80
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
            pixelSize: .init(width: 100, height: 100),
            previewImage: makeUIImage(size: .init(width: 100, height: 100)),
            selectionIndex: selectionIndex
        )
    }

    static func makeProcessedImage() throws -> ProcessedBatchImage {
        let image = makeUIImage(size: .init(width: 200, height: 100))
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
            pixelSize: .init(width: 200, height: 100),
            previewImage: image,
            usedJPEGFallback: false,
            ignoredCompressionSetting: false
        )
    }

    static func detectedTypeIdentifier(
        for url: URL
    ) throws -> String {
        guard let imageSource = CGImageSourceCreateWithURL(url as CFURL, nil) else {
            throw Failure.failedToCreateImageSource
        }

        guard let typeIdentifier = CGImageSourceGetType(imageSource) as String? else {
            throw Failure.failedToReadTypeIdentifier
        }

        return typeIdentifier
    }

    static func pixelSample(
        from url: URL,
        sampleX: Int,
        sampleY: Int
    ) throws -> PixelSample {
        guard let imageSource = CGImageSourceCreateWithURL(url as CFURL, nil),
              let image = CGImageSourceCreateImageAtIndex(imageSource, 0, nil) else {
            throw Failure.failedToCreateImageSource
        }

        let width = image.width
        let height = image.height
        var bytes = [UInt8](
            repeating: 0,
            count: width * height * 4
        )
        guard let context = CGContext(
            data: &bytes,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: width * 4,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ) else {
            throw Failure.failedToCreateImageData
        }

        context.draw(
            image,
            in: CGRect(
                x: 0,
                y: 0,
                width: width,
                height: height
            )
        )

        let clampedX = min(
            max(sampleX, 0),
            width - 1
        )
        let clampedY = min(
            max(sampleY, 0),
            height - 1
        )
        let index = (clampedY * width + clampedX) * 4

        return .init(
            red: bytes[index],
            green: bytes[index + 1],
            blue: bytes[index + 2],
            alpha: bytes[index + 3]
        )
    }

    static func makeUIImage(
        size: CGSize
    ) -> UIImage {
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
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
        format.scale = 1
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
                    x: size.width * 0.22,
                    y: size.height * 0.19,
                    width: size.width * 0.33,
                    height: size.height * 0.33
                )
            )
        }
    }

    static func makeEdgeStripedUIImage(
        size: CGSize
    ) -> UIImage {
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
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
            let stripeWidth = size.width * 0.1

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
            guard let jpegData = image.jpegData(compressionQuality: 1.0) else {
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
// swiftlint:enable no_magic_numbers
