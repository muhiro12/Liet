import Foundation
import ImageIO
@testable import Liet
import LietLibrary
import UIKit

enum BatchImageTestFactory {
    private enum Metrics {
        static let defaultPreviewSize = CGSize(width: 100, height: 100)
        static let processedPreviewWidthMultiplier = 2
        static let processedPreviewSize = CGSize(
            width: defaultPreviewSize.width * CGFloat(processedPreviewWidthMultiplier),
            height: defaultPreviewSize.height
        )
        static let rendererScale = 1.0
        static let jpegQuality = 1.0
    }

    private enum Error: Swift.Error {
        case failedToCreateImageData
        case failedToCreateImageSource
        case failedToReadTypeIdentifier
    }

    static func makeImportedImage(
        format: ImageFileFormat,
        size: CGSize,
        originalFilename: String,
        selectionIndex: Int
    ) throws -> ImportedBatchImage {
        let image = makeUIImage(size: size)
        let sourceURL = try writeImageData(
            for: image,
            format: format == .heic ? .jpeg : format,
            filename: originalFilename
        )

        return .init(
            sourceURL: sourceURL,
            originalFilename: originalFilename,
            originalFormat: format,
            pixelSize: size,
            previewImage: image,
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
            pixelSize: Metrics.defaultPreviewSize,
            previewImage: makeUIImage(size: Metrics.defaultPreviewSize),
            selectionIndex: selectionIndex
        )
    }

    static func makeProcessedImage() throws -> ProcessedBatchImage {
        let image = makeUIImage(size: Metrics.processedPreviewSize)
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
            pixelSize: Metrics.processedPreviewSize,
            previewImage: image,
            usedJPEGFallback: false,
            ignoredCompressionSetting: false
        )
    }

    static func detectedTypeIdentifier(
        for url: URL
    ) throws -> String {
        guard let imageSource = CGImageSourceCreateWithURL(url as CFURL, nil) else {
            throw Error.failedToCreateImageSource
        }

        guard let typeIdentifier = CGImageSourceGetType(imageSource) as String? else {
            throw Error.failedToReadTypeIdentifier
        }

        return typeIdentifier
    }

    static func makeUIImage(
        size: CGSize
    ) -> UIImage {
        let format = UIGraphicsImageRendererFormat()
        format.scale = Metrics.rendererScale
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
                compressionQuality: Metrics.jpegQuality
            ) else {
                throw Error.failedToCreateImageData
            }

            data = jpegData
        case .png:
            guard let pngData = image.pngData() else {
                throw Error.failedToCreateImageData
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
