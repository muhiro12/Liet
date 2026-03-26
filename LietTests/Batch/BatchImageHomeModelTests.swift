import Foundation
@testable import Liet
import Testing

@MainActor
struct BatchImageHomeModelTests {
    @Test
    func changing_settings_invalidates_processed_results_and_switches_source_to_custom() throws {
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
        #expect(model.settingsSource == .custom)
    }
}
