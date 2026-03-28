@testable import LietLibrary
import Testing

struct BatchImagePrefsStoreTests {
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
        #expect(context.userDefaults.object(forKey: "batch.image.preferences.v2") != nil)
        #expect(store.load() == preferences)
    }

    @Test
    func migrates_legacy_preferences_when_v2_payload_is_missing() {
        let context = PreferenceStoreTestContext()
        defer {
            context.tearDown()
        }

        let lastUsedSettings: PersistedBatchImageSettings = .init(
            resizeMode: .exactSize,
            referenceDimension: .width,
            referencePixels: 1_200,
            exactWidthPixels: 800,
            exactHeightPixels: 600,
            exactResizeStrategy: .coverCrop,
            compression: .off,
            naming: .init(
                template: .processed,
                customPrefix: "",
                numberingStyle: .plain
            )
        )
        let userPresetSettings: PersistedBatchImageSettings = .init(
            resizeMode: .aspectRatioPreserved,
            referenceDimension: .height,
            referencePixels: 900,
            exactWidthPixels: 900,
            exactHeightPixels: 900,
            exactResizeStrategy: .stretch,
            compression: .low,
            naming: .init(
                template: .img,
                customPrefix: "",
                numberingStyle: .zeroPaddedThreeDigits
            )
        )

        context.userDefaults.set(
            lastUsedSettings.rawValue,
            forKey: "d9K2mQ7x"
        )
        context.userDefaults.set(
            userPresetSettings.rawValue,
            forKey: "P4v8T1nR"
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

        let userPresetSettings: PersistedBatchImageSettings = .init(
            resizeMode: .exactSize,
            referenceDimension: .width,
            referencePixels: 1_024,
            exactWidthPixels: 512,
            exactHeightPixels: 512,
            exactResizeStrategy: .contain,
            compression: .medium,
            naming: .init(
                template: .custom,
                customPrefix: "scan",
                numberingStyle: .plain
            )
        )
        context.userDefaults.set(
            userPresetSettings.rawValue,
            forKey: "P4v8T1nR"
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

    func seedLegacyPreferences(
        in context: PreferenceStoreTestContext
    ) {
        context.userDefaults.set(
            PersistedBatchImageSettings.default.rawValue,
            forKey: "d9K2mQ7x"
        )
        context.userDefaults.set(
            PersistedBatchImageSettings.default.rawValue,
            forKey: "P4v8T1nR"
        )
    }

    func assertLegacyKeysRemoved(
        in context: PreferenceStoreTestContext
    ) {
        #expect(context.userDefaults.object(forKey: "d9K2mQ7x") == nil)
        #expect(context.userDefaults.object(forKey: "P4v8T1nR") == nil)
    }
}
