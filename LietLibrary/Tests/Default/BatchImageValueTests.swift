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
    func naming_appends_liet_suffix_and_avoids_duplicates() {
        let firstFilename = ProcessedImageNaming.makeFilename(
            originalFilename: "receipt.png",
            fallbackIndex: 1,
            outputFormat: .png
        )
        let secondFilename = ProcessedImageNaming.makeFilename(
            originalFilename: "receipt.png",
            fallbackIndex: 1,
            outputFormat: .png,
            existingFilenames: [firstFilename]
        )
        let fallbackFilename = ProcessedImageNaming.makeFilename(
            originalFilename: nil,
            fallbackIndex: 3,
            outputFormat: .jpeg
        )
        let normalizedStemFilename = ProcessedImageNaming.makeFilename(
            stem: "receipt.png",
            outputFormat: .jpeg
        )
        let duplicatedExtensionFilename = ProcessedImageNaming.makeFilename(
            originalFilename: "receipt.png.jpeg",
            fallbackIndex: 2,
            outputFormat: .jpeg
        )
        let dottedStemFilename = ProcessedImageNaming.makeFilename(
            stem: "report.v2",
            outputFormat: .jpeg
        )

        #expect(firstFilename == "receipt-Liet.png")
        #expect(secondFilename == "receipt-Liet-2.png")
        #expect(fallbackFilename == "image-003-Liet.jpeg")
        #expect(normalizedStemFilename == "receipt.jpeg")
        #expect(duplicatedExtensionFilename == "receipt-Liet.jpeg")
        #expect(dottedStemFilename == "report.v2.jpeg")
    }
}
