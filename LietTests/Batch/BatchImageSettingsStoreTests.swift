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
    func live_store_persists_preferences_in_specified_user_defaults() throws {
        let preferencesSuiteName = makeSuiteName("preferences")
        let preferencesDefaults = try #require(
            UserDefaults(suiteName: preferencesSuiteName)
        )

        defer {
            preferencesDefaults.removePersistentDomain(
                forName: preferencesSuiteName
            )
        }

        let store = BatchImageSettingsStore.live(
            userDefaults: preferencesDefaults
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
