import Foundation
@testable import Liet
import LietLibrary
import Testing

struct BatchImageProcessorBehaviorTests {
    @Test
    func partial_failures_keep_successful_outputs() throws {
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

        let outcome = BatchImageProcessor.process(
            images: [validImage, missingImage],
            settings: .init(
                resizeMode: .fitWithin(
                    referenceDimension: .width,
                    pixels: 400
                ),
                compression: .medium
            ),
            heicEncoderAvailable: false
        )

        #expect(outcome.processedImages.count == 1)
        #expect(outcome.failureCount == 1)
    }

    @Test
    func no_compression_copies_the_original_file_when_processing_is_skipped() throws {
        let importedImage = try BatchImageTestFactory.makeImportedImage(
            format: .jpeg,
            size: .init(width: 320, height: 180),
            originalFilename: "poster.jpg",
            selectionIndex: 1
        )

        let outcome = BatchImageProcessor.process(
            images: [importedImage],
            settings: .init(
                resizeMode: .fitWithin(
                    referenceDimension: .width,
                    pixels: 1_920
                ),
                compression: .off
            ),
            heicEncoderAvailable: false
        )

        let processedImage = try #require(outcome.processedImages.first)
        let originalData = try Data(contentsOf: importedImage.sourceURL)
        let processedData = try Data(contentsOf: processedImage.outputURL)

        #expect(processedImage.outputFilename == "poster-Liet.jpg")
        #expect(processedData == originalData)
        #expect(processedImage.outputURL != importedImage.sourceURL)
    }
}
