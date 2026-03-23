import CoreGraphics
import Foundation
@testable import Liet
import LietLibrary
import Testing

// swiftlint:disable no_magic_numbers
@MainActor
struct BatchImageHomeModelTests {
    private enum Metrics {
        static let importedSelectionIndex = 1
        static let sourceSize = CGSize(width: 1_000, height: 500)
    }

    @Test
    func changing_settings_invalidates_processed_results() throws {
        let model: BatchImageHomeModel = .init()
        model.resultModel = .init(
            outcome: .init(
                processedImages: [try BatchImageTestFactory.makeProcessedImage()],
                failureCount: 0,
                jpegFallbackCount: 0,
                ignoredCompressionCount: 0
            )
        )

        model.resizeModeSelection = .shortEdge
        #expect(model.resultModel == nil)

        model.resultModel = .init(
            outcome: .init(
                processedImages: [try BatchImageTestFactory.makeProcessedImage()],
                failureCount: 0,
                jpegFallbackCount: 0,
                ignoredCompressionCount: 0
            )
        )

        model.resizeShortEdgeText = "720"
        #expect(model.resultModel == nil)

        model.resultModel = .init(
            outcome: .init(
                processedImages: [try BatchImageTestFactory.makeProcessedImage()],
                failureCount: 0,
                jpegFallbackCount: 0,
                ignoredCompressionCount: 0
            )
        )
        model.resizeModeSelection = .exactSize
        model.exactResizeStrategy = .coverCrop
        #expect(model.resultModel == nil)

        model.resultModel = .init(
            outcome: .init(
                processedImages: [try BatchImageTestFactory.makeProcessedImage()],
                failureCount: 0,
                jpegFallbackCount: 0,
                ignoredCompressionCount: 0
            )
        )

        model.compression = .low
        #expect(model.resultModel == nil)
    }

    @Test
    func settings_follow_selected_resize_mode() {
        let model: BatchImageHomeModel = .init()

        #expect(model.settings?.resizeMode == .longEdgePixels(1_920))

        model.resizeModeSelection = .shortEdge
        model.resizeShortEdgeText = "320"
        #expect(model.settings?.resizeMode == .shortEdgePixels(320))

        model.resizeModeSelection = .exactSize
        model.resizeLongEdgeText = "180"
        model.resizeShortEdgeText = "180"
        model.exactResizeStrategy = .coverCrop
        #expect(
            model.settings?.resizeMode == .exactSize(
                longEdgePixels: 180,
                shortEdgePixels: 180,
                strategy: .coverCrop
            )
        )
    }

    @Test
    func process_images_only_presents_results_when_processing_succeeds() async throws {
        BatchImageTipSupport.resetTips()
        let localization = BatchImageLocalization(
            locale: .init(identifier: "en"),
            bundle: Bundle(for: BatchImageHomeModel.self)
        )

        let failedModel: BatchImageHomeModel = .init(
            localization: localization
        )
        failedModel.importedImages = [
            BatchImageTestFactory.makeMissingImportedImage(
                format: .jpeg,
                originalFilename: "missing.jpg",
                selectionIndex: Metrics.importedSelectionIndex
            )
        ]

        await failedModel.processImages()

        #expect(failedModel.resultModel == nil)
        #expect(
            failedModel.errorMessage ==
                localization.processSelectionFailedMessage()
        )
        #expect(BatchImageTipSupport.progressSnapshot().processCompleted == false)

        let successfulModel: BatchImageHomeModel = .init(
            localization: localization
        )
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
// swiftlint:enable no_magic_numbers
