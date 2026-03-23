@testable import Liet
import LietLibrary
import Testing

@MainActor
struct LietAppSmokeTests {
    @Test
    func content_view_starts_with_batch_image_flow_defaults() {
        BatchImageTipSupport.configureIfNeeded()
        _ = ContentView()
        let model: BatchImageHomeModel = .init(
            settingsStore: .inMemory()
        )

        #expect(AppGroup.id == "group.com.muhiro12.Liet")
        #expect(BatchImageTipSupport.datastoreGroupIdentifier == AppGroup.id)
        #expect(model.resizeWidthPixels == 1_920)
        #expect(model.resizeHeightPixels == 1_080)
        #expect(model.keepsAspectRatio)
        #expect(model.compression == .off)
        #expect(model.resultModel == nil)
    }
}
