import CoreGraphics
@testable import Liet
import Testing

@MainActor
struct BatchImageHomeModelTests {
    private enum Metrics {
        static let updatedLongEdge = "1200"
        static let importedSelectionIndex = 1
        static let outcomeCount = 0
        static let sourceSize = CGSize(width: 1_000, height: 500)
    }

    @Test
    func changing_settings_invalidates_processed_results() throws {
        let model: BatchImageHomeModel = .init()
        model.resultModel = .init(
            outcome: .init(
                processedImages: [try BatchImageTestFactory.makeProcessedImage()],
                failureCount: Metrics.outcomeCount,
                jpegFallbackCount: Metrics.outcomeCount,
                ignoredCompressionCount: Metrics.outcomeCount
            )
        )

        model.resizeLongEdgeText = Metrics.updatedLongEdge
        #expect(model.resultModel == nil)

        model.resultModel = .init(
            outcome: .init(
                processedImages: [try BatchImageTestFactory.makeProcessedImage()],
                failureCount: Metrics.outcomeCount,
                jpegFallbackCount: Metrics.outcomeCount,
                ignoredCompressionCount: Metrics.outcomeCount
            )
        )

        model.compression = .low
        #expect(model.resultModel == nil)
    }

    @Test
    func process_images_only_presents_results_when_processing_succeeds() async throws {
        BatchImageTipSupport.resetTips()

        let failedModel: BatchImageHomeModel = .init()
        failedModel.importedImages = [
            BatchImageTestFactory.makeMissingImportedImage(
                format: .jpeg,
                originalFilename: "missing.jpg",
                selectionIndex: Metrics.importedSelectionIndex
            )
        ]

        await failedModel.processImages()

        #expect(failedModel.resultModel == nil)
        #expect(failedModel.errorMessage == "Couldn't process the selected images.")
        #expect(BatchImageTipSupport.progressSnapshot().processCompleted == false)

        let successfulModel: BatchImageHomeModel = .init()
        successfulModel.importedImages = [
            try BatchImageTestFactory.makeImportedImage(
                format: .jpeg,
                size: Metrics.sourceSize,
                originalFilename: "success.jpg",
                selectionIndex: Metrics.importedSelectionIndex
            )
        ]

        await successfulModel.processImages()

        #expect(successfulModel.resultModel != nil)
        #expect(successfulModel.errorMessage == nil)
        #expect(BatchImageTipSupport.progressSnapshot().processCompleted)
    }
}
