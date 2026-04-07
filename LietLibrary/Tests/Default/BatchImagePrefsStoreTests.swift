@testable import LietLibrary
import Testing

struct BatchImagePrefsStoreTests {
    @Test
    func returns_nil_when_no_preferences_have_been_saved() {
        let context = PreferenceStoreTestContext()
        defer {
            context.tearDown()
        }

        let store = makeStore(context)

        #expect(store.load() == nil)
    }

    @Test
    func saves_preferences_to_the_opaque_storage_key() {
        let context = PreferenceStoreTestContext()
        defer {
            context.tearDown()
        }

        let store = makeStore(context)
        let preferences = makePreferences()

        store.save(preferences)

        #expect(context.userDefaults.object(forKey: "B7q1N4xP") != nil)
        #expect(store.load() == preferences)
    }
}

private extension BatchImagePrefsStoreTests {
    enum Fixture {
        static let userPresetReferencePixels = 1_024
        static let userPresetExactWidthPixels = 640
        static let userPresetExactHeightPixels = 480
        static let lastUsedReferencePixels = 1_080
        static let lastUsedExactWidthPixels = 1_920
        static let lastUsedExactHeightPixels = 1_080
    }

    func makeStore(
        _ context: PreferenceStoreTestContext
    ) -> BatchImagePreferencesStore {
        .init(
            preferenceStore: context.preferenceStore
        )
    }

    func makePreferences() -> PersistedBatchImagePreferences {
        .init(
            userPresetSettings: .init(
                resizeMode: .exactSize,
                referenceDimension: .width,
                referencePixels: Fixture.userPresetReferencePixels,
                exactWidthPixels: Fixture.userPresetExactWidthPixels,
                exactHeightPixels: Fixture.userPresetExactHeightPixels,
                exactResizeStrategy: .contain,
                compression: .medium,
                naming: .init(
                    template: .custom,
                    customPrefix: "receipt",
                    numberingStyle: .plain
                )
            ),
            lastUsedSettings: .init(
                resizeMode: .aspectRatioPreserved,
                referenceDimension: .height,
                referencePixels: Fixture.lastUsedReferencePixels,
                exactWidthPixels: Fixture.lastUsedExactWidthPixels,
                exactHeightPixels: Fixture.lastUsedExactHeightPixels,
                exactResizeStrategy: .stretch,
                compression: .high,
                naming: .init(
                    template: .processed,
                    customPrefix: "",
                    numberingStyle: .zeroPaddedThreeDigits
                )
            )
        )
    }
}
