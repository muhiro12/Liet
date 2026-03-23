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

        #expect(settings.widthPixels == 1_920)
        #expect(settings.heightPixels == 1_080)
        #expect(settings.exactResizeStrategy == nil)
        #expect(settings.keepsAspectRatio)
        #expect(settings.compression == .off)
    }

    @Test
    func resize_modes_expose_expected_dimensions_and_strategy() {
        let fitWithinResizeMode = BatchResizeMode.fitWithin(
            widthPixels: 320,
            heightPixels: 180
        )
        #expect(fitWithinResizeMode.widthPixels == 320)
        #expect(fitWithinResizeMode.heightPixels == 180)
        #expect(fitWithinResizeMode.exactResizeStrategy == nil)
        #expect(fitWithinResizeMode.keepsAspectRatio)

        let exactResizeMode = BatchResizeMode.exactSize(
            widthPixels: 180,
            heightPixels: 120,
            strategy: .stretch
        )
        #expect(exactResizeMode.widthPixels == 180)
        #expect(exactResizeMode.heightPixels == 120)
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

        #expect(firstFilename == "receipt-Liet.png")
        #expect(secondFilename == "receipt-Liet-2.png")
        #expect(fallbackFilename == "image-003-Liet.jpg")
    }
}
