import Foundation
@testable import Liet
import LietLibrary
import Testing
import UIKit

@MainActor
struct BatchImageResultModelTests {
    @Test
    func result_state_reflects_processor_outcome_and_successful_export_feedback() {
        let firstImage = makeProcessedImage(filename: "first-Liet.jpg")
        let secondImage = makeProcessedImage(filename: "second-Liet.jpg")
        let model = BatchImageResultModel(
            outcome: .init(
                processedImages: [firstImage, secondImage],
                failureCount: 3,
                jpegFallbackCount: 1,
                ignoredCompressionCount: 2
            )
        )

        model.handleFileExportCompletion(
            .success([firstImage.outputURL, secondImage.outputURL])
        )

        #expect(model.processedImages.count == 2)
        #expect(model.failureCount == 3)
        #expect(model.jpegFallbackCount == 1)
        #expect(model.ignoredCompressionCount == 2)
        #expect(model.saveFeedback == .exportedFiles(count: 2))
        #expect(model.activeError == nil)
    }

    @Test
    func failed_export_records_the_error_without_success_feedback() {
        let image = makeProcessedImage(filename: "first-Liet.jpg")
        let model = BatchImageResultModel(
            outcome: .init(
                processedImages: [image],
                failureCount: 0,
                jpegFallbackCount: 0,
                ignoredCompressionCount: 0
            )
        )
        let error = NSError(
            domain: "BatchImageResultModelTests",
            code: 1
        )

        model.handleFileExportCompletion(.failure(error))

        #expect(model.saveFeedback == nil)
        #expect(model.activeError as NSError? == error)
    }

    private func makeProcessedImage(
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
