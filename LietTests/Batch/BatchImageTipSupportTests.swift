import Foundation
@testable import Liet
import Testing

@MainActor
struct BatchImageTipSupportTests {
    private enum Metrics {
        static let noFailures = 0
        static let exportedURL = URL(fileURLWithPath: "/tmp/output.jpg")
        static let testErrorCode = 1
    }

    @Test
    func configuration_uses_the_app_group_identifier() {
        #expect(BatchImageTipSupport.datastoreGroupIdentifier == AppGroup.id)
    }

    @Test
    func replay_resets_tip_progress_flags() {
        BatchImageTipSupport.resetTips()

        BatchImageTipSupport.donateImportSuccess()
        BatchImageTipSupport.donateProcessSuccess()
        BatchImageTipSupport.donateSaveToFilesSuccess()
        BatchImageTipSupport.donateSaveToPhotosSuccess()
        BatchImageTipSupport.markExactResizeMethodConfigured()
        BatchImageTipSupport.markUserPresetSaved()

        let progressedSnapshot = BatchImageTipSupport.progressSnapshot()
        #expect(progressedSnapshot.importCompleted)
        #expect(progressedSnapshot.processCompleted)
        #expect(progressedSnapshot.saveToFilesCompleted)
        #expect(progressedSnapshot.saveToPhotosCompleted)
        #expect(progressedSnapshot.exactResizeMethodConfigured)
        #expect(progressedSnapshot.userPresetSaved)

        BatchImageTipSupport.resetTips()

        let resetSnapshot = BatchImageTipSupport.progressSnapshot()
        #expect(resetSnapshot.importCompleted == false)
        #expect(resetSnapshot.processCompleted == false)
        #expect(resetSnapshot.saveToFilesCompleted == false)
        #expect(resetSnapshot.saveToPhotosCompleted == false)
        #expect(resetSnapshot.exactResizeMethodConfigured == false)
        #expect(resetSnapshot.userPresetSaved == false)
    }

    @Test
    func file_export_success_donates_only_on_success() async throws {
        BatchImageTipSupport.resetTips()
        let model: BatchImageResultModel = .init(
            outcome: .init(
                processedImages: [try BatchImageTestFactory.makeProcessedImage()],
                failureCount: Metrics.noFailures,
                jpegFallbackCount: Metrics.noFailures,
                ignoredCompressionCount: Metrics.noFailures
            )
        )

        model.handleFileExportCompletion(
            .failure(
                NSError(
                    domain: "Test",
                    code: Metrics.testErrorCode
                )
            )
        )
        #expect(BatchImageTipSupport.progressSnapshot().saveToFilesCompleted == false)

        model.handleFileExportCompletion(.success([Metrics.exportedURL]))
        await Task.yield()
        #expect(BatchImageTipSupport.progressSnapshot().saveToFilesCompleted)
    }
}
