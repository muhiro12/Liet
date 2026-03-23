import CoreGraphics
import Foundation
@testable import Liet
import LietLibrary
import Testing

// swiftlint:disable no_magic_numbers
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
        #expect(
            try BatchImageTestFactory.detectedTypeIdentifier(
                for: processedImage.outputURL
            ) == ImageFileFormat.jpeg.sourceTypeIdentifier
        )
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
        #expect(
            try BatchImageTestFactory.detectedTypeIdentifier(
                for: processedImage.outputURL
            ) == ImageFileFormat.png.sourceTypeIdentifier
        )
    }

    @Test
    func exact_size_contain_preserves_png_transparency() async throws {
        let size = CGSize(
            width: 916,
            height: 797
        )
        let importedImage = try BatchImageTestFactory.makeImportedImage(
            format: .png,
            size: size,
            originalFilename: "badge.png",
            selectionIndex: 1,
            image: BatchImageTestFactory.makeTransparentUIImage(size: size)
        )

        let outcome = await BatchImageProcessor.process(
            images: [importedImage],
            settings: .init(
                resizeMode: .exactSize(
                    longEdgePixels: 180,
                    shortEdgePixels: 180,
                    strategy: .contain
                ),
                compression: .medium
            ),
            heicEncoderAvailable: false
        )

        let processedImage = try #require(outcome.processedImages.first)
        let topLeft = try BatchImageTestFactory.pixelSample(
            from: processedImage.outputURL,
            sampleX: 0,
            sampleY: 0
        )
        let center = try BatchImageTestFactory.pixelSample(
            from: processedImage.outputURL,
            sampleX: 90,
            sampleY: 90
        )

        #expect(processedImage.outputFormat == .png)
        #expect(Int(processedImage.pixelSize.width) == 180)
        #expect(Int(processedImage.pixelSize.height) == 180)
        #expect(
            try BatchImageTestFactory.detectedTypeIdentifier(
                for: processedImage.outputURL
            ) == ImageFileFormat.png.sourceTypeIdentifier
        )
        #expect(topLeft.isTransparent)
        #expect(center.isMostlyRed)
    }

    @Test
    func exact_size_cover_crop_fills_canvas_without_padding() async throws {
        let size = CGSize(
            width: 400,
            height: 200
        )
        let importedImage = try BatchImageTestFactory.makeImportedImage(
            format: .png,
            size: size,
            originalFilename: "banner.png",
            selectionIndex: 1,
            image: BatchImageTestFactory.makeEdgeStripedUIImage(size: size)
        )

        let outcome = await BatchImageProcessor.process(
            images: [importedImage],
            settings: .init(
                resizeMode: .exactSize(
                    longEdgePixels: 100,
                    shortEdgePixels: 100,
                    strategy: .coverCrop
                ),
                compression: .medium
            ),
            heicEncoderAvailable: false
        )

        let processedImage = try #require(outcome.processedImages.first)
        let leftEdge = try BatchImageTestFactory.pixelSample(
            from: processedImage.outputURL,
            sampleX: 10,
            sampleY: 50
        )
        let rightEdge = try BatchImageTestFactory.pixelSample(
            from: processedImage.outputURL,
            sampleX: 90,
            sampleY: 50
        )

        #expect(Int(processedImage.pixelSize.width) == 100)
        #expect(Int(processedImage.pixelSize.height) == 100)
        #expect(leftEdge.isMostlyGreen)
        #expect(rightEdge.isMostlyGreen)
    }

    @Test
    func short_edge_resize_uses_shorter_dimension_without_upscaling() async throws {
        let largeImage = try BatchImageTestFactory.makeImportedImage(
            format: .jpeg,
            size: .init(width: 1_200, height: 800),
            originalFilename: "large.jpg",
            selectionIndex: 1
        )
        let largeOutcome = await BatchImageProcessor.process(
            images: [largeImage],
            settings: .init(
                resizeMode: .shortEdgePixels(200),
                compression: .medium
            ),
            heicEncoderAvailable: false
        )
        let largeProcessedImage = try #require(largeOutcome.processedImages.first)

        #expect(Int(largeProcessedImage.pixelSize.width) == 300)
        #expect(Int(largeProcessedImage.pixelSize.height) == 200)

        let smallImage = try BatchImageTestFactory.makeImportedImage(
            format: .jpeg,
            size: .init(width: 200, height: 100),
            originalFilename: "small.jpg",
            selectionIndex: 1
        )
        let smallOutcome = await BatchImageProcessor.process(
            images: [smallImage],
            settings: .init(
                resizeMode: .shortEdgePixels(180),
                compression: .medium
            ),
            heicEncoderAvailable: false
        )
        let smallProcessedImage = try #require(smallOutcome.processedImages.first)

        #expect(Int(smallProcessedImage.pixelSize.width) == 200)
        #expect(Int(smallProcessedImage.pixelSize.height) == 100)
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

        #expect(
            BatchImageProcessor.resolvedOutputFormat(
                for: .heic,
                heicEncoderAvailable: true
            ) == .heic
        )
        #expect(
            BatchImageProcessor.resolvedOutputFormat(
                for: .heic,
                heicEncoderAvailable: false
            ) == .jpeg
        )
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
// swiftlint:enable no_magic_numbers
