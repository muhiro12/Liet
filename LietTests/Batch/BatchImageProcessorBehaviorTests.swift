import Foundation
@testable import Liet
import LietLibrary
import Testing

struct BatchImageProcessorBehaviorTests {
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
