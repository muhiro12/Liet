import CoreGraphics
import Foundation
@testable import Liet
import LietLibrary
import Testing

@MainActor
struct BatchImageHomeModelPersistenceTests {
    @Test
    func clear_selection_resets_import_state_and_processed_results() throws {
        let model: BatchImageHomeModel = .init(
            settingsStore: .inMemory()
        )
        model.importedImages = [
            try BatchImageTestFactory.makeImportedImage(
                format: .jpeg,
                size: .init(width: 1_000, height: 500),
                originalFilename: "selected.jpg",
                selectionIndex: 1
            )
        ]
        model.resultModel = .init(
            outcome: .init(
                processedImages: [try BatchImageTestFactory.makeProcessedImage()],
                failureCount: 0,
                jpegFallbackCount: 0,
                ignoredCompressionCount: 0
            )
        )
        model.importFailureCount = 2
        model.activeAlert = .processSelectionFailed
        model.isImporting = true

        model.clearSelection()

        #expect(model.importedImages.isEmpty)
        #expect(model.resultModel == nil)
        #expect(model.importFailureCount == nil)
        #expect(model.activeAlert == nil)
        #expect(model.isImporting == false)
    }
}
