import CoreGraphics
import Foundation
@testable import Liet
import LietLibrary
import Testing

@MainActor
struct BatchImageHomeModelTests {
    private enum Metrics {
        static let importedSelectionIndex = 1
        static let sourceSize = CGSize(width: 1_000, height: 500)
    }

    @Test
    func changing_settings_invalidates_processed_results() throws {
        let model: BatchImageHomeModel = .init(
            settingsStore: .inMemory()
        )
        model.resultModel = .init(
            outcome: .init(
                processedImages: [try BatchImageTestFactory.makeProcessedImage()],
                failureCount: 0,
                jpegFallbackCount: 0,
                ignoredCompressionCount: 0
            )
        )

        model.setReferencePixelsText("1280")
        #expect(model.resultModel == nil)

        model.resultModel = .init(
            outcome: .init(
                processedImages: [try BatchImageTestFactory.makeProcessedImage()],
                failureCount: 0,
                jpegFallbackCount: 0,
                ignoredCompressionCount: 0
            )
        )

        model.setKeepsAspectRatio(false)
        #expect(model.resultModel == nil)

        model.resultModel = .init(
            outcome: .init(
                processedImages: [try BatchImageTestFactory.makeProcessedImage()],
                failureCount: 0,
                jpegFallbackCount: 0,
                ignoredCompressionCount: 0
            )
        )
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
    func settings_follow_current_resize_configuration() {
        let model: BatchImageHomeModel = .init(
            settingsStore: .inMemory()
        )

        #expect(
            model.settings?.resizeMode == .fitWithin(
                referenceDimension: .width,
                pixels: 1_920
            )
        )

        model.setReferenceDimension(.height)
        model.setReferencePixelsText("720")
        #expect(
            model.settings?.resizeMode == .fitWithin(
                referenceDimension: .height,
                pixels: 720
            )
        )

        model.setKeepsAspectRatio(false)
        model.setResizeWidthText("320")
        model.setResizeHeightText("180")
        model.exactResizeStrategy = .coverCrop
        #expect(
            model.settings?.resizeMode == .exactSize(
                widthPixels: 320,
                heightPixels: 180,
                strategy: .coverCrop
            )
        )
    }

    @Test
    func reference_edge_selection_persists_settings() {
        let settingsStore = BatchImageSettingsStore.inMemory()
        let firstModel: BatchImageHomeModel = .init(
            settingsStore: settingsStore
        )

        firstModel.setReferenceDimension(.height)
        firstModel.setReferencePixelsText("1080")
        firstModel.compression = .high

        let secondModel: BatchImageHomeModel = .init(
            settingsStore: settingsStore
        )

        #expect(secondModel.referenceDimension == .height)
        #expect(secondModel.referencePixelsText == "1080")
        #expect(secondModel.keepsAspectRatio)
        #expect(secondModel.compression == .high)
    }

    @Test
    func unlocked_size_allows_independent_edits_and_hides_png_only_compression() throws {
        let model: BatchImageHomeModel = .init(
            settingsStore: .inMemory()
        )

        model.setKeepsAspectRatio(false)
        model.setResizeWidthText("300")
        model.setResizeHeightText("120")

        #expect(model.resizeWidthText == "300")
        #expect(model.resizeHeightText == "120")

        model.importedImages = [
            try BatchImageTestFactory.makeImportedImage(
                format: .png,
                size: Metrics.sourceSize,
                originalFilename: "diagram.png",
                selectionIndex: Metrics.importedSelectionIndex
            )
        ]

        #expect(model.showsCompressionSection == false)
        #expect(model.showsMixedCompressionHint == false)

        model.importedImages.append(
            try BatchImageTestFactory.makeImportedImage(
                format: .jpeg,
                size: Metrics.sourceSize,
                originalFilename: "photo.jpg",
                selectionIndex: Metrics.importedSelectionIndex + 1
            )
        )

        #expect(model.showsCompressionSection)
        #expect(model.showsMixedCompressionHint)
    }

    @Test
    func process_images_only_presents_results_when_processing_succeeds() throws {
        BatchImageTipSupport.resetTips()
        let failedModel: BatchImageHomeModel = .init(
            settingsStore: .inMemory()
        )
        failedModel.importedImages = [
            BatchImageTestFactory.makeMissingImportedImage(
                format: .jpeg,
                originalFilename: "missing.jpg",
                selectionIndex: Metrics.importedSelectionIndex
            )
        ]

        failedModel.processImages()

        #expect(failedModel.resultModel == nil)
        #expect(failedModel.activeAlert == .processSelectionFailed)
        #expect(BatchImageTipSupport.progressSnapshot().processCompleted == false)

        let successfulModel: BatchImageHomeModel = .init(
            settingsStore: .inMemory()
        )
        successfulModel.importedImages = [
            try BatchImageTestFactory.makeImportedImage(
                format: .jpeg,
                size: Metrics.sourceSize,
                originalFilename: "success.jpg",
                selectionIndex: Metrics.importedSelectionIndex
            )
        ]

        successfulModel.processImages()

        #expect(successfulModel.resultModel != nil)
        #expect(successfulModel.activeAlert == nil)
        #expect(BatchImageTipSupport.progressSnapshot().processCompleted)
    }
}
