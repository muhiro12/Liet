import CoreGraphics
import Foundation
@testable import Liet
import LietLibrary
import Testing

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
                resizeMode: .fitWithin(
                    referenceDimension: .width,
                    pixels: 500
                ),
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
                resizeMode: .fitWithin(
                    referenceDimension: .width,
                    pixels: 300
                ),
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
    func height_reference_resizes_from_the_selected_edge() async throws {
        let importedImage = try BatchImageTestFactory.makeImportedImage(
            format: .jpeg,
            size: .init(width: 1_000, height: 2_000),
            originalFilename: "portrait.jpg",
            selectionIndex: 1
        )

        let outcome = await BatchImageProcessor.process(
            images: [importedImage],
            settings: .init(
                resizeMode: .fitWithin(
                    referenceDimension: .height,
                    pixels: 500
                ),
                compression: .medium
            ),
            heicEncoderAvailable: false
        )

        let processedImage = try #require(outcome.processedImages.first)

        #expect(Int(processedImage.pixelSize.width) == 250)
        #expect(Int(processedImage.pixelSize.height) == 500)
    }

    @Test
    func exact_size_contain_preserves_png_format_and_source_alpha() async throws {
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
                    widthPixels: 180,
                    heightPixels: 180,
                    strategy: .contain
                ),
                compression: .medium
            ),
            heicEncoderAvailable: false
        )

        let processedImage = try #require(outcome.processedImages.first)
        let transparentContentPixel = try BatchImageTestFactory.pixelSample(
            from: processedImage.outputURL,
            sampleX: 10,
            sampleY: 50
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
        #expect(transparentContentPixel.isTransparent)
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
                    widthPixels: 100,
                    heightPixels: 100,
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
    func fit_within_uses_bounding_box_without_upscaling() async throws {
        let largeImage = try BatchImageTestFactory.makeImportedImage(
            format: .jpeg,
            size: .init(width: 1_200, height: 800),
            originalFilename: "large.jpg",
            selectionIndex: 1
        )
        let largeOutcome = await BatchImageProcessor.process(
            images: [largeImage],
            settings: .init(
                resizeMode: .fitWithin(
                    referenceDimension: .width,
                    pixels: 300
                ),
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
                resizeMode: .fitWithin(
                    referenceDimension: .width,
                    pixels: 320
                ),
                compression: .medium
            ),
            heicEncoderAvailable: false
        )
        let smallProcessedImage = try #require(smallOutcome.processedImages.first)

        #expect(Int(smallProcessedImage.pixelSize.width) == 200)
        #expect(Int(smallProcessedImage.pixelSize.height) == 100)
    }

    @Test
    func exact_size_stretch_matches_target_canvas_without_cropping() async throws {
        let importedImage = try BatchImageTestFactory.makeImportedImage(
            format: .png,
            size: .init(width: 400, height: 200),
            originalFilename: "stretch.png",
            selectionIndex: 1,
            image: BatchImageTestFactory.makeEdgeStripedUIImage(
                size: .init(width: 400, height: 200)
            )
        )

        let outcome = await BatchImageProcessor.process(
            images: [importedImage],
            settings: .init(
                resizeMode: .exactSize(
                    widthPixels: 100,
                    heightPixels: 100,
                    strategy: .stretch
                ),
                compression: .off
            ),
            heicEncoderAvailable: false
        )

        let processedImage = try #require(outcome.processedImages.first)
        let leftEdge = try BatchImageTestFactory.pixelSample(
            from: processedImage.outputURL,
            sampleX: 5,
            sampleY: 50
        )
        let rightEdge = try BatchImageTestFactory.pixelSample(
            from: processedImage.outputURL,
            sampleX: 95,
            sampleY: 50
        )

        #expect(Int(processedImage.pixelSize.width) == 100)
        #expect(Int(processedImage.pixelSize.height) == 100)
        #expect(leftEdge.isMostlyRed)
        #expect(rightEdge.isMostlyBlue)
    }
}
