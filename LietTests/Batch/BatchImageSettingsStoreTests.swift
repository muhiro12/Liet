import Foundation
@testable import Liet
import LietLibrary
import Testing

struct BatchImageSettingsStoreTests {
    @Test
    func live_store_removes_legacy_standard_key_and_persists_preferences() throws {
        let preferencesSuiteName = "BatchImageSettingsStoreTests.preferences.\(UUID().uuidString)"
        let legacySuiteName = "BatchImageSettingsStoreTests.legacy.\(UUID().uuidString)"
        let preferencesDefaults = try #require(
            UserDefaults(suiteName: preferencesSuiteName)
        )
        let legacyDefaults = try #require(
            UserDefaults(suiteName: legacySuiteName)
        )

        defer {
            preferencesDefaults.removePersistentDomain(
                forName: preferencesSuiteName
            )
            legacyDefaults.removePersistentDomain(
                forName: legacySuiteName
            )
        }

        legacyDefaults.set(
            Data("legacy".utf8),
            forKey: BatchImageSettingsStore.legacyStorageKey
        )

        let store = BatchImageSettingsStore.live(
            userDefaults: preferencesDefaults,
            legacyUserDefaults: legacyDefaults
        )

        #expect(
            legacyDefaults.object(
                forKey: BatchImageSettingsStore.legacyStorageKey
            ) == nil
        )

        let preferences: PersistedBatchImagePreferences = .init(
            defaultSettings: .init(
                resizeMode: .aspectRatioPreserved,
                referenceDimension: .width,
                referencePixels: 180,
                exactWidthPixels: 180,
                exactHeightPixels: 180,
                exactResizeStrategy: .stretch,
                compression: .off
            ),
            lastUsedSettings: .init(
                resizeMode: .exactSize,
                referenceDimension: .height,
                referencePixels: 512,
                exactWidthPixels: 320,
                exactHeightPixels: 180,
                exactResizeStrategy: .coverCrop,
                compression: .medium
            )
        )

        store.save(preferences)

        #expect(store.load() == preferences)
        #expect(
            preferencesDefaults.data(
                forKey: BatchImageSettingsStore.storageKey
            ) != nil
        )
    }
}
