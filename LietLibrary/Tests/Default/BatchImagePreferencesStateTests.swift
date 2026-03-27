@testable import LietLibrary
import Testing

struct BatchImagePreferencesStateTests {
    @Test
    func state_starts_from_last_used_settings_and_tracks_saved_preset() {
        let userPresetSettings = makeSettings(
            referenceDimension: .width,
            referencePixels: 2_048,
            compression: .high,
            backgroundRemoval: .init(
                isEnabled: true,
                strength: 0.7,
                edgeSmoothing: 0.2,
                edgeExpansion: 0.15
            ),
            naming: .init(
                template: .custom,
                customPrefix: "receipt",
                numberingStyle: .plain
            )
        )
        let lastUsedSettings = makeSettings(
            resizeMode: .exactSize,
            referenceDimension: .height,
            referencePixels: 720,
            exactWidthPixels: 320,
            exactHeightPixels: 180,
            exactResizeStrategy: .coverCrop,
            compression: .medium,
            backgroundRemoval: .init(
                isEnabled: false,
                strength: 0.4,
                edgeSmoothing: 0.1,
                edgeExpansion: -0.1
            ),
            naming: .init(
                template: .processed,
                numberingStyle: .zeroPaddedThreeDigits
            )
        )
        let preferences = makePreferences(
            userPresetSettings: userPresetSettings,
            lastUsedSettings: lastUsedSettings
        )

        let state: BatchImagePreferencesState = .init(
            preferences: preferences
        )

        assertStartupState(state)
    }

    @Test
    func selecting_saved_sources_updates_current_settings_without_overwriting_last_used() {
        let lastUsedSettings = makeSettings(
            referenceDimension: .height,
            referencePixels: 1_080,
            compression: .high,
            naming: .init(
                template: .img,
                numberingStyle: .zeroPaddedThreeDigits
            )
        )
        let userPresetSettings = makeSettings(
            resizeMode: .exactSize,
            referenceDimension: .height,
            referencePixels: 640,
            exactWidthPixels: 320,
            exactHeightPixels: 180,
            exactResizeStrategy: .coverCrop,
            compression: .medium,
            naming: .init(
                template: .custom,
                customPrefix: "receipt",
                numberingStyle: .plain
            )
        )
        var state: BatchImagePreferencesState = .init(
            preferences: makePreferences(
                userPresetSettings: userPresetSettings,
                lastUsedSettings: lastUsedSettings
            )
        )

        state.applyUserPresetSettings()

        assertUserPresetSelectionState(state)
        assertSettings(
            state.lastUsedSettings,
            equalTo: lastUsedSettings
        )

        state.applyLastUsedSettings()

        assertLastUsedSelectionState(state)
    }

    @Test
    func saving_current_settings_as_user_preset_only_updates_the_preset_slot() throws {
        var state: BatchImagePreferencesState = .init(
            preferences: .default
        )

        state.setKeepsAspectRatio(false)
        state.setResizeWidthText("320")
        state.setResizeHeightText("180")
        state.setExactResizeStrategy(.coverCrop)
        state.setCompression(.medium)
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
        assertSettings(
            savedUserPreset,
            equalTo: expectedPreset
        )
        assertSettings(
            state.lastUsedSettings,
            equalTo: PersistedBatchImageSettings.default
        )
        #expect(state.canSaveCurrentAsUserPreset == false)
    }

    @Test
    func persisting_last_used_settings_updates_saved_preferences_after_editing() {
        var state: BatchImagePreferencesState = .init(
            preferences: .default
        )

        state.setReferenceDimension(.height)
        state.setReferencePixelsText("1080")
        state.setCompression(.high)
        state.setBackgroundRemovalEnabled(true)
        state.setBackgroundRemovalStrength(0.8)
        state.setBackgroundRemovalEdgeSmoothing(0.3)
        state.setBackgroundRemovalEdgeExpansion(-0.2)
        state.setNamingTemplate(.processed)
        state.setNamingNumberingStyle(.plain)

        #expect(state.settingsSource == .custom)
        #expect(state.lastUsedSettings == .default)

        state.persistCurrentAsLastUsed()

        #expect(state.settingsSource == .lastUsed)
        #expect(state.lastUsedSettings.referenceDimension == .height)
        #expect(state.lastUsedSettings.referencePixels == 1_080)
        #expect(state.lastUsedSettings.compression == .high)
        #expect(state.lastUsedSettings.backgroundRemoval.isEnabled)
        #expect(state.lastUsedSettings.backgroundRemoval.strength == 0.8)
        #expect(state.lastUsedSettings.backgroundRemoval.edgeSmoothing == 0.3)
        #expect(state.lastUsedSettings.backgroundRemoval.edgeExpansion == -0.2)
        #expect(state.lastUsedSettings.naming.template == .processed)
        #expect(state.lastUsedSettings.naming.numberingStyle == .plain)
        #expect(state.preferences.lastUsedSettings == state.lastUsedSettings)
    }

    @Test
    func invalid_exact_size_values_disable_settings_and_preset_saving() {
        var state: BatchImagePreferencesState = .init(
            preferences: .default
        )

        state.setKeepsAspectRatio(false)
        state.setResizeWidthText("320")
        state.setResizeHeightText("0")

        #expect(state.settings == nil)
        #expect(state.currentPersistedSettings == nil)
        #expect(state.canSaveCurrentAsUserPreset == false)
    }

    @Test
    func blank_custom_prefix_disables_settings_and_preset_saving() {
        var state: BatchImagePreferencesState = .init(
            preferences: .default
        )

        state.setNamingTemplate(.custom)
        state.setCustomNamingPrefixText("   ")

        #expect(state.settings == nil)
        #expect(state.currentPersistedSettings == nil)
        #expect(state.canSaveCurrentAsUserPreset == false)
    }
}

private extension BatchImagePreferencesStateTests {
    func makePreferences(
        userPresetSettings: PersistedBatchImageSettings?,
        lastUsedSettings: PersistedBatchImageSettings
    ) -> PersistedBatchImagePreferences {
        .init(
            userPresetSettings: userPresetSettings,
            lastUsedSettings: lastUsedSettings
        )
    }

    func makeSettings(
        resizeMode: PersistedBatchResizeMode = .aspectRatioPreserved,
        referenceDimension: BatchResizeReferenceDimension = .width,
        referencePixels: Int = 1_920,
        exactWidthPixels: Int = 1_920,
        exactHeightPixels: Int = 1_080,
        exactResizeStrategy: BatchExactResizeStrategy = .stretch,
        compression: BatchImageCompression = .off,
        backgroundRemoval: BatchBackgroundRemovalSettings = .default,
        naming: BatchImageNaming = .default
    ) -> PersistedBatchImageSettings {
        .init(
            resizeMode: resizeMode,
            referenceDimension: referenceDimension,
            referencePixels: referencePixels,
            exactWidthPixels: exactWidthPixels,
            exactHeightPixels: exactHeightPixels,
            exactResizeStrategy: exactResizeStrategy,
            compression: compression,
            backgroundRemoval: backgroundRemoval,
            naming: naming
        )
    }

    func assertSettings(
        _ lhs: PersistedBatchImageSettings,
        equalTo rhs: PersistedBatchImageSettings
    ) {
        #expect(lhs.resizeMode == rhs.resizeMode)
        #expect(lhs.referenceDimension == rhs.referenceDimension)
        #expect(lhs.referencePixels == rhs.referencePixels)
        #expect(lhs.exactWidthPixels == rhs.exactWidthPixels)
        #expect(lhs.exactHeightPixels == rhs.exactHeightPixels)
        #expect(lhs.exactResizeStrategy == rhs.exactResizeStrategy)
        #expect(lhs.compression == rhs.compression)
        #expect(lhs.backgroundRemoval == rhs.backgroundRemoval)
        #expect(lhs.naming == rhs.naming)
    }

    func assertStartupState(
        _ state: BatchImagePreferencesState
    ) {
        #expect(state.settingsSource == .lastUsed)
        #expect(state.hasUserPresetSettings)
        #expect(state.keepsAspectRatio == false)
        #expect(state.resizeWidthText == "320")
        #expect(state.resizeHeightText == "180")
        #expect(state.exactResizeStrategy == .coverCrop)
        #expect(state.compression == .medium)
        #expect(state.backgroundRemoval.isEnabled == false)
        #expect(state.namingTemplate == .processed)
        #expect(state.customNamingPrefixText.isEmpty)
        #expect(state.numberingStyle == .zeroPaddedThreeDigits)
    }

    func assertUserPresetSelectionState(
        _ state: BatchImagePreferencesState
    ) {
        #expect(state.settingsSource == .userPreset)
        #expect(state.keepsAspectRatio == false)
        #expect(state.resizeWidthText == "320")
        #expect(state.resizeHeightText == "180")
        #expect(state.exactResizeStrategy == .coverCrop)
        #expect(state.compression == .medium)
        #expect(state.namingTemplate == .custom)
        #expect(state.customNamingPrefixText == "receipt")
        #expect(state.numberingStyle == .plain)
    }

    func assertLastUsedSelectionState(
        _ state: BatchImagePreferencesState
    ) {
        #expect(state.settingsSource == .lastUsed)
        #expect(state.referenceDimension == .height)
        #expect(state.referencePixelsText == "1080")
        #expect(state.keepsAspectRatio)
        #expect(state.compression == .high)
        #expect(state.namingTemplate == .img)
        #expect(state.numberingStyle == .zeroPaddedThreeDigits)
    }
}
