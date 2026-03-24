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
    func live_store_removes_legacy_standard_key_and_persists_preferences() throws {
        let preferencesSuiteName = makeSuiteName("preferences")
        let legacySuiteName = makeSuiteName("legacy")
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

        let preferences = makePreferences()

        store.save(preferences)

        #expect(store.load() == preferences)
        #expect(
            preferencesDefaults.data(
                forKey: BatchImageSettingsStore.storageKey
            ) != nil
        )
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
            defaultSettings: .init(
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
