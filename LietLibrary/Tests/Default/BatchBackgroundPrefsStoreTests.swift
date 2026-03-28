@testable import LietLibrary
import Testing

struct BatchBackgroundPrefsStoreTests {
    @Test
    func saves_preferences_to_v2_key_and_removes_legacy_keys() {
        let context = PreferenceStoreTestContext()
        defer {
            context.tearDown()
        }

        seedLegacyPreferences(in: context)

        let store = makeStore(context)
        let preferences = makePreferences()

        store.save(preferences)

        assertLegacyKeysRemoved(in: context)
        #expect(
            context.userDefaults.object(
                forKey: "batch.backgroundRemoval.preferences.v2"
            ) != nil
        )
        #expect(store.load() == preferences)
    }

    @Test
    func migrates_legacy_preferences_when_v2_payload_is_missing() {
        let context = PreferenceStoreTestContext()
        defer {
            context.tearDown()
        }

        let lastUsedSettings: PersistedBatchBackgroundRemovalSettings = .init(
            strength: 0.7,
            edgeSmoothing: 0.2,
            edgeExpansion: -0.1,
            naming: .init(
                template: .processed,
                customPrefix: "",
                numberingStyle: .plain
            )
        )
        let userPresetSettings: PersistedBatchBackgroundRemovalSettings = .init(
            strength: 0.9,
            edgeSmoothing: 0.4,
            edgeExpansion: 0.25,
            naming: .init(
                template: .custom,
                customPrefix: "subject",
                numberingStyle: .zeroPaddedThreeDigits
            )
        )

        context.userDefaults.set(
            lastUsedSettings.rawValue,
            forKey: "G7r2Lp5X"
        )
        context.userDefaults.set(
            userPresetSettings.rawValue,
            forKey: "U1m8Qv4N"
        )

        let store = makeStore(context)
        let loadedPreferences = store.load()

        #expect(
            loadedPreferences == .init(
                userPresetSettings: userPresetSettings,
                lastUsedSettings: lastUsedSettings
            )
        )
    }

    @Test
    func defaults_last_used_settings_when_only_legacy_user_preset_exists() {
        let context = PreferenceStoreTestContext()
        defer {
            context.tearDown()
        }

        let userPresetSettings: PersistedBatchBackgroundRemovalSettings = .init(
            strength: 0.8,
            edgeSmoothing: 0.25,
            edgeExpansion: 0.05,
            naming: .init(
                template: .custom,
                customPrefix: "portrait",
                numberingStyle: .plain
            )
        )
        context.userDefaults.set(
            userPresetSettings.rawValue,
            forKey: "U1m8Qv4N"
        )

        let store = makeStore(context)
        let loadedPreferences = store.load()

        #expect(
            loadedPreferences == .init(
                userPresetSettings: userPresetSettings,
                lastUsedSettings: .default
            )
        )
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

    func seedLegacyPreferences(
        in context: PreferenceStoreTestContext
    ) {
        context.userDefaults.set(
            PersistedBatchBackgroundRemovalSettings.default.rawValue,
            forKey: "G7r2Lp5X"
        )
        context.userDefaults.set(
            PersistedBatchBackgroundRemovalSettings.default.rawValue,
            forKey: "U1m8Qv4N"
        )
    }

    func assertLegacyKeysRemoved(
        in context: PreferenceStoreTestContext
    ) {
        #expect(context.userDefaults.object(forKey: "G7r2Lp5X") == nil)
        #expect(context.userDefaults.object(forKey: "U1m8Qv4N") == nil)
    }
}
