import CoreGraphics
import ImageIO
@testable import Liet
import LietLibrary
import Testing

struct BatchImageProcessorTests {
    private enum Metrics {
        static let jpegSourceSize = CGSize(width: 2_000, height: 1_000)
        static let jpegLongEdge = 500
        static let jpegExpectedSize = CGSize(width: 500, height: 250)

        static let pngSourceSize = CGSize(width: 1_200, height: 800)
        static let pngLongEdge = 300
        static let pngExpectedSize = CGSize(width: 300, height: 200)

        static let smallSourceSize = CGSize(width: 200, height: 100)
        static let untouchedLongEdge = 1_920

        static let heicSourceSize = CGSize(width: 1_600, height: 900)
        static let heicLongEdge = 800

        static let partialSourceSize = CGSize(width: 1_000, height: 500)
        static let partialLongEdge = 400

        static let singleSuccessCount = 1
        static let noFailures = 0
        static let oneFailure = 1
        static let oneIgnoredCompression = 1
        static let oneJPEGFallback = 1
    }

    @Test
    func jpeg_input_stays_jpeg_and_resizes_with_aspect_ratio() async throws {
        let importedImage = try BatchImageTestFactory.makeImportedImage(
            format: .jpeg,
            size: Metrics.jpegSourceSize,
            originalFilename: "sample.jpg",
            selectionIndex: Metrics.singleSuccessCount
        )

        let outcome = await BatchImageProcessor.process(
            images: [importedImage],
            settings: .init(
                resizeMode: .longEdgePixels(Metrics.jpegLongEdge),
                compression: .high
            ),
            heicEncoderAvailable: false
        )

        let processedImage = try #require(outcome.processedImages.first)

        #expect(outcome.failureCount == Metrics.noFailures)
        #expect(processedImage.outputFormat == .jpeg)
        #expect(Int(processedImage.pixelSize.width) == Int(Metrics.jpegExpectedSize.width))
        #expect(Int(processedImage.pixelSize.height) == Int(Metrics.jpegExpectedSize.height))
        #expect(
            try BatchImageTestFactory.detectedTypeIdentifier(for: processedImage.outputURL) ==
                ImageFileFormat.jpeg.sourceTypeIdentifier
        )
    }

    @Test
    func png_input_preserves_png_and_ignores_quality_setting() async throws {
        let importedImage = try BatchImageTestFactory.makeImportedImage(
            format: .png,
            size: Metrics.pngSourceSize,
            originalFilename: "diagram.png",
            selectionIndex: Metrics.singleSuccessCount
        )

        let outcome = await BatchImageProcessor.process(
            images: [importedImage],
            settings: .init(
                resizeMode: .longEdgePixels(Metrics.pngLongEdge),
                compression: .low
            ),
            heicEncoderAvailable: false
        )

        let processedImage = try #require(outcome.processedImages.first)

        #expect(outcome.failureCount == Metrics.noFailures)
        #expect(outcome.ignoredCompressionCount == Metrics.oneIgnoredCompression)
        #expect(processedImage.outputFormat == .png)
        #expect(processedImage.ignoredCompressionSetting)
        #expect(Int(processedImage.pixelSize.width) == Int(Metrics.pngExpectedSize.width))
        #expect(Int(processedImage.pixelSize.height) == Int(Metrics.pngExpectedSize.height))
        #expect(
            try BatchImageTestFactory.detectedTypeIdentifier(for: processedImage.outputURL) ==
                ImageFileFormat.png.sourceTypeIdentifier
        )
    }

    @Test
    func small_images_are_not_upscaled() async throws {
        let importedImage = try BatchImageTestFactory.makeImportedImage(
            format: .jpeg,
            size: Metrics.smallSourceSize,
            originalFilename: "tiny.jpg",
            selectionIndex: Metrics.singleSuccessCount
        )

        let outcome = await BatchImageProcessor.process(
            images: [importedImage],
            settings: .init(
                resizeMode: .longEdgePixels(Metrics.untouchedLongEdge),
                compression: .medium
            ),
            heicEncoderAvailable: false
        )

        let processedImage = try #require(outcome.processedImages.first)

        #expect(outcome.failureCount == Metrics.noFailures)
        #expect(Int(processedImage.pixelSize.width) == Int(Metrics.smallSourceSize.width))
        #expect(Int(processedImage.pixelSize.height) == Int(Metrics.smallSourceSize.height))
    }

    @Test
    func heic_format_falls_back_to_jpeg_when_encoder_is_unavailable() async throws {
        let importedImage = try BatchImageTestFactory.makeImportedImage(
            format: .heic,
            size: Metrics.heicSourceSize,
            originalFilename: "capture.heic",
            selectionIndex: Metrics.singleSuccessCount
        )

        let outcome = await BatchImageProcessor.process(
            images: [importedImage],
            settings: .init(
                resizeMode: .longEdgePixels(Metrics.heicLongEdge),
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
        #expect(outcome.jpegFallbackCount == Metrics.oneJPEGFallback)
        #expect(processedImage.outputFormat == .jpeg)
        #expect(processedImage.usedJPEGFallback)
    }

    @Test
    func partial_failures_keep_successful_outputs() async throws {
        let validImage = try BatchImageTestFactory.makeImportedImage(
            format: .jpeg,
            size: Metrics.partialSourceSize,
            originalFilename: "valid.jpg",
            selectionIndex: Metrics.singleSuccessCount
        )
        let missingImage = BatchImageTestFactory.makeMissingImportedImage(
            format: .jpeg,
            originalFilename: "missing.jpg",
            selectionIndex: Metrics.oneFailure + Metrics.singleSuccessCount
        )

        let outcome = await BatchImageProcessor.process(
            images: [validImage, missingImage],
            settings: .init(
                resizeMode: .longEdgePixels(Metrics.partialLongEdge),
                compression: .medium
            ),
            heicEncoderAvailable: false
        )

        #expect(outcome.processedImages.count == Metrics.singleSuccessCount)
        #expect(outcome.failureCount == Metrics.oneFailure)
    }
}
