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

    @Test
    func batch_image_preferences_descriptor_uses_stable_storage_key() {
        #expect(
            LietPreferenceDescriptors.BatchImage.preferences.storageKey ==
                LietUserDefaultsKeys.AppGroup.batchImagePreferences.rawValue
        )
    }

    @Test
    func batch_image_preferences_descriptor_uses_app_group_defaults_selection() {
        #expect(
            LietPreferenceDescriptors.BatchImage.preferences.defaultSelection ==
                AppGroup.preferencesDefaultsSelection
        )
    }

    @Test
    func batch_background_removal_preferences_descriptor_uses_stable_storage_key() {
        #expect(
            LietPreferenceDescriptors.BatchBackgroundRemoval.preferences.storageKey ==
                LietUserDefaultsKeys.AppGroup.batchBackgroundRemovalPreferences.rawValue
        )
    }

    @Test
    func batch_background_removal_preferences_descriptor_uses_app_group_defaults_selection() {
        #expect(
            LietPreferenceDescriptors.BatchBackgroundRemoval.preferences.defaultSelection ==
                AppGroup.preferencesDefaultsSelection
        )
    }
}
