@testable import Liet
import LietLibrary
import Testing

@MainActor
struct LietAppSmokeTests {
    @Test
    func content_view_starts_with_batch_image_flow_defaults() {
        _ = ContentView()
        let model: BatchImageHomeModel = .init()

        #expect(AppGroup.id == "group.com.muhiro12.Liet")
        #expect(model.resizeLongEdgePixels == 1_920)
        #expect(model.compression == .medium)
        #expect(model.resultModel == nil)
    }
}
