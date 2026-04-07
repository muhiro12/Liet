@testable import LietLibrary
import Testing

struct BatchBackgroundPrefsStoreTests {
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

        #expect(
            context.userDefaults.object(
                forKey: "H3m8R2vK"
            ) != nil
        )
        #expect(store.load() == preferences)
    }
}

private extension BatchBackgroundPrefsStoreTests {
    enum Fixture {
        static let userPresetStrength = 0.85
        static let userPresetEdgeSmoothing = 0.3
        static let userPresetEdgeExpansion = 0.1
        static let lastUsedStrength = 0.6
        static let lastUsedEdgeSmoothing = 0.15
        static let lastUsedEdgeExpansion = -0.05
    }

    func makeStore(
        _ context: PreferenceStoreTestContext
    ) -> BatchBackgroundRemovalPreferencesStore {
        .init(
            preferenceStore: context.preferenceStore
        )
    }

    func makePreferences() -> PersistedBatchBackgroundRemovalPreferences {
        .init(
            userPresetSettings: .init(
                strength: Fixture.userPresetStrength,
                edgeSmoothing: Fixture.userPresetEdgeSmoothing,
                edgeExpansion: Fixture.userPresetEdgeExpansion,
                naming: .init(
                    template: .custom,
                    customPrefix: "cutout",
                    numberingStyle: .plain
                )
            ),
            lastUsedSettings: .init(
                strength: Fixture.lastUsedStrength,
                edgeSmoothing: Fixture.lastUsedEdgeSmoothing,
                edgeExpansion: Fixture.lastUsedEdgeExpansion,
                naming: .init(
                    template: .processed,
                    customPrefix: "",
                    numberingStyle: .zeroPaddedThreeDigits
                )
            )
        )
    }
}
