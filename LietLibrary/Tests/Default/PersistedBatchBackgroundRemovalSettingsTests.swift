import Foundation
@testable import LietLibrary
import Testing

// swiftlint:disable type_name
struct PersistedBatchBackgroundRemovalSettingsTests {
    @Test
    func settings_round_trip_through_raw_value() throws {
        let settings = PersistedBatchBackgroundRemovalSettings(
            strength: 0.8,
            edgeSmoothing: 0.25,
            edgeExpansion: 0.15,
            naming: .init(
                template: .custom,
                customPrefix: "receipt",
                numberingStyle: .plain
            )
        )

        let restoredSettings = try #require(
            PersistedBatchBackgroundRemovalSettings(rawValue: settings.rawValue)
        )

        #expect(restoredSettings == settings)
    }

    @Test
    func default_preferences_keep_last_used_defaults_and_no_user_preset() {
        let defaultSettings = PersistedBatchBackgroundRemovalSettings.default

        #expect(PersistedBatchBackgroundRemovalPreferences.default.userPresetSettings == nil)
        #expect(
            PersistedBatchBackgroundRemovalPreferences.default.lastUsedSettings ==
                defaultSettings
        )
        #expect(defaultSettings.naming == .default)
    }

    @Test
    func missing_naming_payload_defaults_during_restore() throws {
        let currentSettings = PersistedBatchBackgroundRemovalSettings(
            strength: 0.8,
            edgeSmoothing: 0.25,
            edgeExpansion: 0.15,
            naming: .init(
                template: .custom,
                customPrefix: "receipt",
                numberingStyle: .plain
            )
        )
        let rawData = try #require(
            currentSettings.rawValue.data(using: .utf8)
        )
        var payload = try #require(
            JSONSerialization.jsonObject(with: rawData) as? [String: Any]
        )
        payload.removeValue(
            forKey: PersistedBatchBackgroundRemovalSettingsCodingKeys.naming.rawValue
        )
        let legacyData = try JSONSerialization.data(
            withJSONObject: payload,
            options: JSONSerialization.WritingOptions.sortedKeys
        )
        let legacyRawValue = try #require(
            String(data: legacyData, encoding: .utf8)
        )

        let restoredSettings = try #require(
            PersistedBatchBackgroundRemovalSettings(rawValue: legacyRawValue)
        )

        #expect(restoredSettings.naming == .default)
    }
}
// swiftlint:enable type_name
