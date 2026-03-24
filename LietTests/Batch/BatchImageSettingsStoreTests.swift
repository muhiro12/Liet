import Foundation
@testable import Liet
import LietLibrary
import Testing

struct BatchImageSettingsStoreTests {
    private enum Constants {
        static let defaultExactHeight = 180
        static let defaultExactWidth = 180
        static let defaultReferencePixels = 180
        static let lastUsedExactHeight = 180
        static let lastUsedExactWidth = 320
        static let lastUsedReferencePixels = 512
    }

    @Test
    func app_storage_store_persists_preferences_in_specified_user_defaults() throws {
        let preferencesSuiteName = makeSuiteName("preferences")
        let preferencesDefaults = try #require(
            UserDefaults(suiteName: preferencesSuiteName)
        )

        defer {
            preferencesDefaults.removePersistentDomain(
                forName: preferencesSuiteName
            )
        }

        let store = BatchImageSettingsStore.appStorage(
            userDefaults: preferencesDefaults
        )

        let preferences = makePreferences()

        store.save(preferences)

        #expect(store.load() == preferences)
        #expect(
            preferencesDefaults.string(
                forKey: BatchImageAppStorageKey.lastUsedSettings.rawValue
            ) != nil
        )
        #expect(
            preferencesDefaults.string(
                forKey: BatchImageAppStorageKey.userPresetSettings.rawValue
            ) != nil
        )
    }

    @Test
    func app_storage_store_keeps_user_preset_absent_until_saved() throws {
        let preferencesSuiteName = makeSuiteName("empty-user-preset")
        let preferencesDefaults = try #require(
            UserDefaults(suiteName: preferencesSuiteName)
        )

        defer {
            preferencesDefaults.removePersistentDomain(
                forName: preferencesSuiteName
            )
        }

        let store = BatchImageSettingsStore.appStorage(
            userDefaults: preferencesDefaults
        )

        let preferences = PersistedBatchImagePreferences(
            userPresetSettings: nil,
            lastUsedSettings: .default
        )

        store.save(preferences)

        #expect(store.load() == preferences)
        #expect(
            preferencesDefaults.string(
                forKey: BatchImageAppStorageKey.lastUsedSettings.rawValue
            ) != nil
        )
        #expect(
            preferencesDefaults.string(
                forKey: BatchImageAppStorageKey.userPresetSettings.rawValue
            ) == nil
        )
    }

    @Test
    func persisted_batch_image_settings_round_trip_through_raw_value() throws {
        let settings = PersistedBatchImageSettings(
            resizeMode: .exactSize,
            referenceDimension: .height,
            referencePixels: Constants.lastUsedReferencePixels,
            exactWidthPixels: Constants.lastUsedExactWidth,
            exactHeightPixels: Constants.lastUsedExactHeight,
            exactResizeStrategy: .coverCrop,
            compression: .medium
        )

        let restoredSettings = try #require(
            PersistedBatchImageSettings(rawValue: settings.rawValue)
        )

        #expect(restoredSettings == settings)
    }
}

private extension BatchImageSettingsStoreTests {
    func makeSuiteName(
        _ suffix: String
    ) -> String {
        "BatchImageSettingsStoreTests.\(suffix).\(UUID().uuidString)"
    }

    func makePreferences() -> PersistedBatchImagePreferences {
        .init(
            userPresetSettings: .init(
                resizeMode: .aspectRatioPreserved,
                referenceDimension: .width,
                referencePixels: Constants.defaultReferencePixels,
                exactWidthPixels: Constants.defaultExactWidth,
                exactHeightPixels: Constants.defaultExactHeight,
                exactResizeStrategy: .stretch,
                compression: .off
            ),
            lastUsedSettings: .init(
                resizeMode: .exactSize,
                referenceDimension: .height,
                referencePixels: Constants.lastUsedReferencePixels,
                exactWidthPixels: Constants.lastUsedExactWidth,
                exactHeightPixels: Constants.lastUsedExactHeight,
                exactResizeStrategy: .coverCrop,
                compression: .medium
            )
        )
    }
}
