@testable import LietLibrary
import Testing

struct BatchImagePreferencesStateTests {
    @Test
    func state_starts_from_last_used_settings_and_tracks_saved_preset() {
        let preferences = makePreferences(
            userPresetSettings: .init(
                resizeMode: .aspectRatioPreserved,
                referenceDimension: .width,
                referencePixels: 2_048,
                exactWidthPixels: 1_920,
                exactHeightPixels: 1_080,
                exactResizeStrategy: .stretch,
                compression: .high
            ),
            lastUsedSettings: .init(
                resizeMode: .exactSize,
                referenceDimension: .height,
                referencePixels: 720,
                exactWidthPixels: 320,
                exactHeightPixels: 180,
                exactResizeStrategy: .coverCrop,
                compression: .medium
            )
        )

        let state: BatchImagePreferencesState = .init(
            preferences: preferences
        )

        #expect(state.settingsSource == .lastUsed)
        #expect(state.hasUserPresetSettings)
        #expect(state.keepsAspectRatio == false)
        #expect(state.resizeWidthText == "320")
        #expect(state.resizeHeightText == "180")
        #expect(state.exactResizeStrategy == .coverCrop)
        #expect(state.compression == .medium)
    }

    @Test
    func selecting_saved_sources_updates_current_settings_without_overwriting_last_used() {
        let lastUsedSettings = PersistedBatchImageSettings(
            resizeMode: .aspectRatioPreserved,
            referenceDimension: .height,
            referencePixels: 1_080,
            exactWidthPixels: 1_920,
            exactHeightPixels: 1_080,
            exactResizeStrategy: .stretch,
            compression: .high
        )
        let userPresetSettings = PersistedBatchImageSettings(
            resizeMode: .exactSize,
            referenceDimension: .height,
            referencePixels: 640,
            exactWidthPixels: 320,
            exactHeightPixels: 180,
            exactResizeStrategy: .coverCrop,
            compression: .medium
        )
        var state: BatchImagePreferencesState = .init(
            preferences: makePreferences(
                userPresetSettings: userPresetSettings,
                lastUsedSettings: lastUsedSettings
            )
        )

        state.applyUserPresetSettings()

        #expect(state.settingsSource == .userPreset)
        #expect(state.keepsAspectRatio == false)
        #expect(state.resizeWidthText == "320")
        #expect(state.resizeHeightText == "180")
        #expect(state.exactResizeStrategy == .coverCrop)
        #expect(state.compression == .medium)
        assertSettings(
            state.lastUsedSettings,
            equalTo: lastUsedSettings
        )

        state.applyLastUsedSettings()

        #expect(state.settingsSource == .lastUsed)
        #expect(state.referenceDimension == .height)
        #expect(state.referencePixelsText == "1080")
        #expect(state.keepsAspectRatio)
        #expect(state.compression == .high)
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

        #expect(state.settingsSource == .custom)
        #expect(state.lastUsedSettings == .default)

        state.persistCurrentAsLastUsed()

        #expect(state.settingsSource == .lastUsed)
        #expect(state.lastUsedSettings.referenceDimension == .height)
        #expect(state.lastUsedSettings.referencePixels == 1_080)
        #expect(state.lastUsedSettings.compression == .high)
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
    }
}
