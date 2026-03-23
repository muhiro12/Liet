import LietLibrary
@testable import Liet
import Testing

@MainActor
struct LietAppSmokeTests {
    @Test
    func content_view_starts_with_shared_library_scaffold() {
        _ = ContentView()

        #expect(AppGroup.id == "group.com.muhiro12.Liet")
    }
}
