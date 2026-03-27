@testable import LietLibrary
import Testing

struct BatchImageValueTests {
    @Test
    func compression_quality_mapping_matches_mvp_values() {
        #expect(BatchImageCompression.off.quality == 1.0)
        #expect(BatchImageCompression.high.quality == 0.9)
        #expect(BatchImageCompression.medium.quality == 0.7)
        #expect(BatchImageCompression.low.quality == 0.5)
    }

    @Test
    func settings_default_to_fit_within_and_disable_compression() {
        let settings: BatchImageSettings = .init()

        #expect(settings.referenceDimension == .width)
        #expect(settings.referencePixels == 1_920)
        #expect(settings.exactWidthPixels == nil)
        #expect(settings.exactHeightPixels == nil)
        #expect(settings.exactResizeStrategy == nil)
        #expect(settings.keepsAspectRatio)
        #expect(settings.compression == .off)
        #expect(settings.naming == .default)
    }

    @Test
    func background_removal_settings_default_to_adjustable_values() {
        let settings: BatchBackgroundRemovalSettings = .default

        #expect(settings.strength == 0.5)
        #expect(settings.edgeSmoothing == 0.15)
        #expect(settings.edgeExpansion == 0)
    }

    @Test
    func resize_modes_expose_expected_dimensions_and_strategy() {
        let fitWithinResizeMode = BatchResizeMode.fitWithin(
            referenceDimension: .height,
            pixels: 320
        )
        #expect(fitWithinResizeMode.referenceDimension == .height)
        #expect(fitWithinResizeMode.referencePixels == 320)
        #expect(fitWithinResizeMode.exactWidthPixels == nil)
        #expect(fitWithinResizeMode.exactHeightPixels == nil)
        #expect(fitWithinResizeMode.exactResizeStrategy == nil)
        #expect(fitWithinResizeMode.keepsAspectRatio)

        let exactResizeMode = BatchResizeMode.exactSize(
            widthPixels: 180,
            heightPixels: 120,
            strategy: .stretch
        )
        #expect(exactResizeMode.referenceDimension == nil)
        #expect(exactResizeMode.referencePixels == nil)
        #expect(exactResizeMode.exactWidthPixels == 180)
        #expect(exactResizeMode.exactHeightPixels == 120)
        #expect(exactResizeMode.exactResizeStrategy == .stretch)
        #expect(exactResizeMode.keepsAspectRatio == false)
    }

    @Test
    func format_resolution_handles_supported_and_fallback_types() {
        #expect(ImageFileFormat(typeIdentifier: "public.jpeg") == .jpeg)
        #expect(ImageFileFormat(typeIdentifier: "public.png") == .png)
        #expect(ImageFileFormat(typeIdentifier: "public.heic") == .heic)
        #expect(ImageFileFormat(typeIdentifier: "public.webp") == .other)
        #expect(ImageFileFormat(typeIdentifier: nil) == .other)
        #expect(ImageFileFormat(typeIdentifier: "public.webp").preferredOutputFormat == .jpeg)
    }

    @Test
    func naming_templates_generate_expected_stems() throws {
        let firstStem = try #require(
            BatchImageNaming.default.filenameStem(for: 1)
        )
        let processedStem = try #require(
            BatchImageNaming(
                template: .processed,
                numberingStyle: .plain
            ).filenameStem(for: 2)
        )
        let customStem = try #require(
            BatchImageNaming(
                template: .custom,
                customPrefix: " receipt.png ",
                numberingStyle: .zeroPaddedThreeDigits
            ).filenameStem(for: 3)
        )
        let normalizedStemFilename = ProcessedImageNaming.makeFilename(
            stem: "receipt.png",
            outputFormat: .jpeg
        )
        let blankStemFilename = ProcessedImageNaming.makeFilename(
            stem: "",
            outputFormat: .jpeg
        )
        let invalidCustomNaming = BatchImageNaming(
            template: .custom,
            customPrefix: "   ",
            numberingStyle: .plain
        )

        #expect(firstStem == "IMG_001")
        #expect(processedStem == "processed_2")
        #expect(customStem == "receipt_003")
        #expect(invalidCustomNaming.isValid == false)
    }

    @Test
    func processed_image_naming_normalizes_stems_and_deduplicates_filenames() {
        let firstFilename = ProcessedImageNaming.makeFilename(
            stem: "IMG_001",
            outputFormat: .png
        )
        let secondFilename = ProcessedImageNaming.makeFilename(
            stem: "IMG_001",
            outputFormat: .png,
            existingFilenames: [firstFilename]
        )
        let normalizedStemFilename = ProcessedImageNaming.makeFilename(
            stem: "receipt.png",
            outputFormat: .jpeg
        )
        let blankStemFilename = ProcessedImageNaming.makeFilename(
            stem: "",
            outputFormat: .jpeg
        )
        let duplicateExtensionFilename = ProcessedImageNaming.makeFilename(
            stem: "receipt.png.jpeg",
            outputFormat: .jpeg
        )
        let dottedStemFilename = ProcessedImageNaming.makeFilename(
            stem: "report.v2",
            outputFormat: .jpeg
        )

        #expect(firstFilename == "IMG_001.png")
        #expect(secondFilename == "IMG_001-2.png")
        #expect(normalizedStemFilename == "receipt.jpeg")
        #expect(blankStemFilename == "image.jpeg")
        #expect(duplicateExtensionFilename == "receipt.jpeg")
        #expect(dottedStemFilename == "report.v2.jpeg")
    }
}
