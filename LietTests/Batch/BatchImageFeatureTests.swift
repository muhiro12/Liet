import Foundation
import ImageIO
@testable import Liet
import LietLibrary
import Testing
import UIKit

struct BatchImageProcessorTests {
    @Test
    func jpeg_input_stays_jpeg_and_resizes_with_aspect_ratio() async throws {
        let importedImage = try BatchImageTestFactory.makeImportedImage(
            format: .jpeg,
            size: .init(width: 2_000, height: 1_000),
            originalFilename: "sample.jpg",
            selectionIndex: 1
        )

        let outcome = await BatchImageProcessor.process(
            images: [importedImage],
            settings: .init(
                resizeMode: .longEdgePixels(500),
                compression: .high
            ),
            heicEncoderAvailable: false
        )

        let processedImage = try #require(outcome.processedImages.first)

        #expect(outcome.failureCount == 0)
        #expect(processedImage.outputFormat == .jpeg)
        #expect(Int(processedImage.pixelSize.width) == 500)
        #expect(Int(processedImage.pixelSize.height) == 250)
        #expect(try BatchImageTestFactory.detectedTypeIdentifier(for: processedImage.outputURL) == ImageFileFormat.jpeg.sourceTypeIdentifier)
    }

    @Test
    func png_input_preserves_png_and_ignores_quality_setting() async throws {
        let importedImage = try BatchImageTestFactory.makeImportedImage(
            format: .png,
            size: .init(width: 1_200, height: 800),
            originalFilename: "diagram.png",
            selectionIndex: 1
        )

        let outcome = await BatchImageProcessor.process(
            images: [importedImage],
            settings: .init(
                resizeMode: .longEdgePixels(300),
                compression: .low
            ),
            heicEncoderAvailable: false
        )

        let processedImage = try #require(outcome.processedImages.first)

        #expect(outcome.failureCount == 0)
        #expect(outcome.ignoredCompressionCount == 1)
        #expect(processedImage.outputFormat == .png)
        #expect(processedImage.ignoredCompressionSetting)
        #expect(Int(processedImage.pixelSize.width) == 300)
        #expect(Int(processedImage.pixelSize.height) == 200)
        #expect(try BatchImageTestFactory.detectedTypeIdentifier(for: processedImage.outputURL) == ImageFileFormat.png.sourceTypeIdentifier)
    }

    @Test
    func small_images_are_not_upscaled() async throws {
        let importedImage = try BatchImageTestFactory.makeImportedImage(
            format: .jpeg,
            size: .init(width: 200, height: 100),
            originalFilename: "tiny.jpg",
            selectionIndex: 1
        )

        let outcome = await BatchImageProcessor.process(
            images: [importedImage],
            settings: .init(
                resizeMode: .longEdgePixels(1_920),
                compression: .medium
            ),
            heicEncoderAvailable: false
        )

        let processedImage = try #require(outcome.processedImages.first)

        #expect(outcome.failureCount == 0)
        #expect(Int(processedImage.pixelSize.width) == 200)
        #expect(Int(processedImage.pixelSize.height) == 100)
    }

    @Test
    func heic_format_falls_back_to_jpeg_when_encoder_is_unavailable() async throws {
        let importedImage = try BatchImageTestFactory.makeImportedImage(
            format: .heic,
            size: .init(width: 1_600, height: 900),
            originalFilename: "capture.heic",
            selectionIndex: 1
        )

        let outcome = await BatchImageProcessor.process(
            images: [importedImage],
            settings: .init(
                resizeMode: .longEdgePixels(800),
                compression: .medium
            ),
            heicEncoderAvailable: false
        )

        let processedImage = try #require(outcome.processedImages.first)

        #expect(BatchImageProcessor.resolvedOutputFormat(for: .heic, heicEncoderAvailable: true) == .heic)
        #expect(BatchImageProcessor.resolvedOutputFormat(for: .heic, heicEncoderAvailable: false) == .jpeg)
        #expect(outcome.jpegFallbackCount == 1)
        #expect(processedImage.outputFormat == .jpeg)
        #expect(processedImage.usedJPEGFallback)
    }

    @Test
    func partial_failures_keep_successful_outputs() async throws {
        let validImage = try BatchImageTestFactory.makeImportedImage(
            format: .jpeg,
            size: .init(width: 1_000, height: 500),
            originalFilename: "valid.jpg",
            selectionIndex: 1
        )
        let missingImage = BatchImageTestFactory.makeMissingImportedImage(
            format: .jpeg,
            originalFilename: "missing.jpg",
            selectionIndex: 2
        )

        let outcome = await BatchImageProcessor.process(
            images: [validImage, missingImage],
            settings: .init(
                resizeMode: .longEdgePixels(400),
                compression: .medium
            ),
            heicEncoderAvailable: false
        )

        #expect(outcome.processedImages.count == 1)
        #expect(outcome.failureCount == 1)
    }
}

@MainActor
struct BatchImageHomeModelTests {
    @Test
    func changing_settings_invalidates_processed_results() throws {
        let model: BatchImageHomeModel = .init()
        model.resultModel = .init(
            outcome: .init(
                processedImages: [try BatchImageTestFactory.makeProcessedImage()],
                failureCount: 0,
                jpegFallbackCount: 0,
                ignoredCompressionCount: 0
            )
        )

        model.resizeLongEdgeText = "1200"
        #expect(model.resultModel == nil)

        model.resultModel = .init(
            outcome: .init(
                processedImages: [try BatchImageTestFactory.makeProcessedImage()],
                failureCount: 0,
                jpegFallbackCount: 0,
                ignoredCompressionCount: 0
            )
        )

        model.compression = .low
        #expect(model.resultModel == nil)
    }

    @Test
    func process_images_only_presents_results_when_processing_succeeds() async throws {
        let localization = BatchImageTestFactory.makeLocalization(
            localeIdentifier: "en"
        )
        let failedModel: BatchImageHomeModel = .init(
            localization: localization
        )
        failedModel.importedImages = [
            BatchImageTestFactory.makeMissingImportedImage(
                format: .jpeg,
                originalFilename: "missing.jpg",
                selectionIndex: 1
            )
        ]

        await failedModel.processImages()

        #expect(failedModel.resultModel == nil)
        #expect(
            failedModel.errorMessage == localization.processSelectionFailedMessage()
        )

        let successfulModel: BatchImageHomeModel = .init(
            localization: localization
        )
        successfulModel.importedImages = [
            try BatchImageTestFactory.makeImportedImage(
                format: .jpeg,
                size: .init(width: 1_000, height: 500),
                originalFilename: "success.jpg",
                selectionIndex: 1
            )
        ]

        await successfulModel.processImages()

        #expect(successfulModel.resultModel != nil)
        #expect(successfulModel.errorMessage == nil)
    }
}

private enum BatchImageTestFactory {
    static func makeLocalization(
        localeIdentifier: String
    ) -> BatchImageLocalization {
        .init(
            locale: .init(identifier: localeIdentifier),
            bundle: Bundle(for: BatchImageHomeModel.self)
        )
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
            throw BatchImageTestFactoryError.failedToCreateImageSource
        }

        guard let typeIdentifier = CGImageSourceGetType(imageSource) as String? else {
            throw BatchImageTestFactoryError.failedToReadTypeIdentifier
        }

        return typeIdentifier
    }

    static func makeUIImage(
        size: CGSize
    ) -> UIImage {
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
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
            guard let jpegData = image.jpegData(compressionQuality: 1.0) else {
                throw BatchImageTestFactoryError.failedToCreateImageData
            }

            data = jpegData
        case .png:
            guard let pngData = image.pngData() else {
                throw BatchImageTestFactoryError.failedToCreateImageData
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

private enum BatchImageTestFactoryError: Error {
    case failedToCreateImageData
    case failedToCreateImageSource
    case failedToReadTypeIdentifier
}
