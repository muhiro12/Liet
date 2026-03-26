@testable import LietLibrary
import Testing

struct PersistedBatchImageSettingsTests {
    @Test
    func settings_round_trip_through_raw_value() throws {
        let settings = PersistedBatchImageSettings(
            resizeMode: .exactSize,
            referenceDimension: .height,
            referencePixels: 512,
            exactWidthPixels: 320,
            exactHeightPixels: 180,
            exactResizeStrategy: .coverCrop,
            compression: .medium
        )

        let restoredSettings = try #require(
            PersistedBatchImageSettings(rawValue: settings.rawValue)
        )

        #expect(restoredSettings == settings)
    }

    @Test
    func default_preferences_keep_last_used_defaults_and_no_user_preset() {
        let defaultSettings = PersistedBatchImageSettings.default

        #expect(PersistedBatchImagePreferences.default.userPresetSettings == nil)
        #expect(
            PersistedBatchImagePreferences.default.lastUsedSettings.resizeMode ==
                defaultSettings.resizeMode
        )
        #expect(
            PersistedBatchImagePreferences.default.lastUsedSettings.referenceDimension ==
                defaultSettings.referenceDimension
        )
        #expect(
            PersistedBatchImagePreferences.default.lastUsedSettings.referencePixels ==
                defaultSettings.referencePixels
        )
        #expect(
            PersistedBatchImagePreferences.default.lastUsedSettings.exactWidthPixels ==
                defaultSettings.exactWidthPixels
        )
        #expect(
            PersistedBatchImagePreferences.default.lastUsedSettings.exactHeightPixels ==
                defaultSettings.exactHeightPixels
        )
        #expect(
            PersistedBatchImagePreferences.default.lastUsedSettings.exactResizeStrategy ==
                defaultSettings.exactResizeStrategy
        )
        #expect(
            PersistedBatchImagePreferences.default.lastUsedSettings.compression ==
                defaultSettings.compression
        )
        #expect(defaultSettings.resizeMode == .aspectRatioPreserved)
        #expect(defaultSettings.referencePixels == 1_920)
        #expect(defaultSettings.exactWidthPixels == 1_920)
        #expect(defaultSettings.exactHeightPixels == 1_080)
    }
}
