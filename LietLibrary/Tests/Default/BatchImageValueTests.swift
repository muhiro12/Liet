@testable import LietLibrary
import Testing

struct BatchImageValueTests {
    @Test
    func compression_quality_mapping_matches_mvp_values() {
        #expect(BatchImageCompression.high.quality == 0.9)
        #expect(BatchImageCompression.medium.quality == 0.7)
        #expect(BatchImageCompression.low.quality == 0.5)
    }

    @Test
    func settings_default_to_manual_long_edge_and_medium_quality() {
        let settings: BatchImageSettings = .init()

        #expect(settings.longEdgePixels == 1_920)
        #expect(settings.shortEdgePixels == nil)
        #expect(settings.exactResizeStrategy == nil)
        #expect(settings.compression == .medium)
    }

    @Test
    func resize_modes_expose_expected_edges_and_strategy() {
        let shortEdgeResizeMode = BatchResizeMode.shortEdgePixels(320)
        #expect(shortEdgeResizeMode.longEdgePixels == nil)
        #expect(shortEdgeResizeMode.shortEdgePixels == 320)
        #expect(shortEdgeResizeMode.exactResizeStrategy == nil)

        let exactResizeMode = BatchResizeMode.exactSize(
            longEdgePixels: 180,
            shortEdgePixels: 120,
            strategy: .contain
        )
        #expect(exactResizeMode.longEdgePixels == 180)
        #expect(exactResizeMode.shortEdgePixels == 120)
        #expect(exactResizeMode.exactResizeStrategy == .contain)
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
    func naming_appends_processed_suffix_and_avoids_duplicates() {
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

        #expect(firstFilename == "receipt-processed.png")
        #expect(secondFilename == "receipt-processed-2.png")
        #expect(fallbackFilename == "image-003.jpg")
    }
}
