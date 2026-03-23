import Foundation
@testable import Liet
import LietLibrary
import Testing
import UIKit

@MainActor
struct BatchImageResultModelTests {
    @Test
    func result_state_reflects_processor_outcome() {
        let firstImage = makeProcessedImage(filename: "first.jpg")
        let secondImage = makeProcessedImage(filename: "second.jpg")
        let model = BatchImageResultModel(
            outcome: .init(
                processedImages: [firstImage, secondImage],
                failureCount: 3,
                jpegFallbackCount: 1,
                ignoredCompressionCount: 2
            )
        )

        #expect(model.processedImages.count == 2)
        #expect(model.failureCount == 3)
        #expect(model.jpegFallbackCount == 1)
        #expect(model.ignoredCompressionCount == 2)
        #expect(model.saveFeedback == nil)
        #expect(model.activeError == nil)

        model.handleFileExportCompletion(
            .success([firstImage.outputURL, secondImage.outputURL])
        )

        #expect(model.saveFeedback == .exportedFiles(count: 2))
    }

    func makeProcessedImage(
        filename: String
    ) -> ProcessedBatchImage {
        .init(
            sourceID: .init(),
            outputURL: FileManager.default.temporaryDirectory
                .appendingPathComponent(UUID().uuidString)
                .appendingPathComponent(filename),
            outputFilename: filename,
            outputFormat: .jpeg,
            originalFormat: .jpeg,
            pixelSize: .init(width: 200, height: 100),
            previewImage: UIImage(),
            usedJPEGFallback: false,
            ignoredCompressionSetting: false
        )
    }
}
