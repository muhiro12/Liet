@testable import LietLibrary
import Testing

struct LietLibraryTests {
    @Test
    func app_group_uses_liet_identifier() {
        #expect(AppGroup.id == "group.com.muhiro12.Liet")
    }

    @Test
    func app_group_preferences_defaults_selection_uses_liet_suite() {
        #expect(
            AppGroup.preferencesDefaultsSelection == .suite(AppGroup.id)
        )
    }
}
