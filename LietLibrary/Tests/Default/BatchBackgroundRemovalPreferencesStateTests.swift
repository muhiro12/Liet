@testable import LietLibrary
import Testing

// swiftlint:disable type_name
struct BatchBackgroundRemovalPreferencesStateTests {
    @Test
    func state_starts_from_last_used_settings_and_tracks_saved_preset() {
        let userPresetSettings = makeSettings(
            strength: 0.8,
            edgeSmoothing: 0.25,
            edgeExpansion: 0.15,
            naming: .init(
                template: .custom,
                customPrefix: "receipt",
                numberingStyle: .plain
            )
        )
        let lastUsedSettings = makeSettings(
            strength: 0.6,
            edgeSmoothing: 0.2,
            edgeExpansion: -0.1,
            naming: .init(
                template: .processed,
                numberingStyle: .zeroPaddedThreeDigits
            )
        )
        let preferences = makePreferences(
            userPresetSettings: userPresetSettings,
            lastUsedSettings: lastUsedSettings
        )

        let state: BatchBackgroundRemovalPreferencesState = .init(
            preferences: preferences
        )

        #expect(state.settingsSource == .lastUsed)
        #expect(state.hasUserPresetSettings)
        #expect(state.strength == 0.6)
        #expect(state.edgeSmoothing == 0.2)
        #expect(state.edgeExpansion == -0.1)
        #expect(state.namingTemplate == .processed)
        #expect(state.numberingStyle == .zeroPaddedThreeDigits)
    }

    @Test
    func selecting_saved_sources_updates_current_settings_without_overwriting_last_used() {
        let lastUsedSettings = makeSettings(
            strength: 0.55,
            edgeSmoothing: 0.1,
            edgeExpansion: 0,
            naming: .init(
                template: .processed,
                numberingStyle: .plain
            )
        )
        let userPresetSettings = makeSettings(
            strength: 0.85,
            edgeSmoothing: 0.3,
            edgeExpansion: 0.2,
            naming: .init(
                template: .custom,
                customPrefix: "receipt",
                numberingStyle: .zeroPaddedThreeDigits
            )
        )
        var state: BatchBackgroundRemovalPreferencesState = .init(
            preferences: makePreferences(
                userPresetSettings: userPresetSettings,
                lastUsedSettings: lastUsedSettings
            )
        )

        state.applyUserPresetSettings()

        #expect(state.settingsSource == .userPreset)
        #expect(state.strength == 0.85)
        #expect(state.edgeSmoothing == 0.3)
        #expect(state.edgeExpansion == 0.2)
        #expect(state.namingTemplate == .custom)
        #expect(state.customNamingPrefixText == "receipt")

        state.applyLastUsedSettings()

        #expect(state.settingsSource == .lastUsed)
        #expect(state.strength == 0.55)
        #expect(state.edgeSmoothing == 0.1)
        #expect(state.edgeExpansion == 0)
        #expect(state.namingTemplate == .processed)
        #expect(state.numberingStyle == .plain)
    }

    @Test
    func saving_current_settings_as_user_preset_only_updates_the_preset_slot() throws {
        var state: BatchBackgroundRemovalPreferencesState = .init(
            preferences: .default
        )

        state.setStrength(0.8)
        state.setEdgeSmoothing(0.25)
        state.setEdgeExpansion(0.15)
        state.setNamingTemplate(.custom)
        state.setCustomNamingPrefixText("receipt")
        state.setNamingNumberingStyle(.plain)
        state.saveCurrentAsUserPreset()

        let expectedPreset = try #require(
            state.currentPersistedSettings
        )
        let savedUserPreset = try #require(
            state.userPresetSettings
        )

        #expect(state.settingsSource == .userPreset)
        #expect(savedUserPreset == expectedPreset)
        #expect(state.lastUsedSettings == .default)
        #expect(state.canSaveCurrentAsUserPreset == false)
    }

    @Test
    func persisting_last_used_settings_updates_saved_preferences_after_editing() {
        var state: BatchBackgroundRemovalPreferencesState = .init(
            preferences: .default
        )

        state.setStrength(0.8)
        state.setEdgeSmoothing(0.3)
        state.setEdgeExpansion(-0.2)
        state.setNamingTemplate(.processed)
        state.setNamingNumberingStyle(.plain)

        #expect(state.settingsSource == .custom)
        #expect(state.lastUsedSettings == .default)

        state.persistCurrentAsLastUsed()

        #expect(state.settingsSource == .lastUsed)
        #expect(state.lastUsedSettings.strength == 0.8)
        #expect(state.lastUsedSettings.edgeSmoothing == 0.3)
        #expect(state.lastUsedSettings.edgeExpansion == -0.2)
        #expect(state.lastUsedSettings.naming.template == .processed)
        #expect(state.lastUsedSettings.naming.numberingStyle == .plain)
        #expect(state.preferences.lastUsedSettings == state.lastUsedSettings)
    }

    @Test
    func blank_custom_prefix_disables_preset_saving() {
        var state: BatchBackgroundRemovalPreferencesState = .init(
            preferences: .default
        )

        state.setNamingTemplate(.custom)
        state.setCustomNamingPrefixText("   ")

        #expect(state.naming == nil)
        #expect(state.currentPersistedSettings == nil)
        #expect(state.canSaveCurrentAsUserPreset == false)
    }
}
// swiftlint:enable type_name

private extension BatchBackgroundRemovalPreferencesStateTests {
    func makePreferences(
        userPresetSettings: PersistedBatchBackgroundRemovalSettings?,
        lastUsedSettings: PersistedBatchBackgroundRemovalSettings
    ) -> PersistedBatchBackgroundRemovalPreferences {
        .init(
            userPresetSettings: userPresetSettings,
            lastUsedSettings: lastUsedSettings
        )
    }

    func makeSettings(
        strength: Double = BatchBackgroundRemovalSettings.default.strength,
        edgeSmoothing: Double = BatchBackgroundRemovalSettings.default.edgeSmoothing,
        edgeExpansion: Double = BatchBackgroundRemovalSettings.default.edgeExpansion,
        naming: BatchImageNaming = .default
    ) -> PersistedBatchBackgroundRemovalSettings {
        .init(
            strength: strength,
            edgeSmoothing: edgeSmoothing,
            edgeExpansion: edgeExpansion,
            naming: naming
        )
    }
}
