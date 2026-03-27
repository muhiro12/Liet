import Foundation

/// Mutable background-removal state shared between persistence rules and the app model.
public struct BatchBackgroundRemovalPreferencesState: Equatable, Sendable {
    /// The optional persisted user preset slot.
    public var userPresetSettings: PersistedBatchBackgroundRemovalSettings?
    /// The persisted last-used settings slot.
    public var lastUsedSettings: PersistedBatchBackgroundRemovalSettings
    /// The saved source currently selected in the UI.
    public var settingsSource: BatchImageSettingsSource
    /// The foreground-preservation strength currently selected.
    public var strength: Double
    /// The mask-smoothing amount currently selected.
    public var edgeSmoothing: Double
    /// The edge expansion amount currently selected.
    public var edgeExpansion: Double
    /// The output naming template currently selected.
    public var namingTemplate: BatchImageNamingTemplate
    /// The editable custom naming prefix text.
    public var customNamingPrefixText: String
    /// The numbering style currently selected for generated filenames.
    public var numberingStyle: BatchImageNumberingStyle

    /// Creates a preferences state from explicit editable and persisted values.
    public init(
        userPresetSettings: PersistedBatchBackgroundRemovalSettings?,
        lastUsedSettings: PersistedBatchBackgroundRemovalSettings,
        settingsSource: BatchImageSettingsSource,
        strength: Double,
        edgeSmoothing: Double,
        edgeExpansion: Double,
        namingTemplate: BatchImageNamingTemplate,
        customNamingPrefixText: String,
        numberingStyle: BatchImageNumberingStyle
    ) {
        self.userPresetSettings = userPresetSettings
        self.lastUsedSettings = lastUsedSettings
        self.settingsSource = settingsSource
        self.strength = strength
        self.edgeSmoothing = edgeSmoothing
        self.edgeExpansion = edgeExpansion
        self.namingTemplate = namingTemplate
        self.customNamingPrefixText = customNamingPrefixText
        self.numberingStyle = numberingStyle
    }

    /// Creates a preferences state from the persisted preference slots.
    public init(
        preferences: PersistedBatchBackgroundRemovalPreferences = .default
    ) {
        let initialSettings = preferences.lastUsedSettings
        self.init(
            userPresetSettings: preferences.userPresetSettings,
            lastUsedSettings: preferences.lastUsedSettings,
            settingsSource: .lastUsed,
            strength: initialSettings.strength,
            edgeSmoothing: initialSettings.edgeSmoothing,
            edgeExpansion: initialSettings.edgeExpansion,
            namingTemplate: initialSettings.naming.template,
            customNamingPrefixText: initialSettings.naming.customPrefix,
            numberingStyle: initialSettings.naming.numberingStyle
        )
    }
}

public extension BatchBackgroundRemovalPreferencesState {
    /// Whether a user preset is currently stored.
    var hasUserPresetSettings: Bool {
        userPresetSettings != nil
    }

    /// Whether the current valid settings differ from the saved preset slot.
    var canSaveCurrentAsUserPreset: Bool {
        guard let currentPersistedSettings else {
            return false
        }

        return currentPersistedSettings != userPresetSettings
    }

    /// The validated output naming settings.
    var naming: BatchImageNaming? {
        validatedNaming
    }

    /// The resolved background-removal settings for processing.
    var settings: BatchBackgroundRemovalSettings {
        .init(
            strength: strength,
            edgeSmoothing: edgeSmoothing,
            edgeExpansion: edgeExpansion
        )
    }

    /// The persisted settings payload for the current editable values when valid.
    var currentPersistedSettings: PersistedBatchBackgroundRemovalSettings? {
        guard let validatedNaming else {
            return nil
        }

        return .init(
            strength: strength,
            edgeSmoothing: edgeSmoothing,
            edgeExpansion: edgeExpansion,
            naming: validatedNaming
        )
    }

    /// The persisted preference slots represented by the current state.
    var preferences: PersistedBatchBackgroundRemovalPreferences {
        .init(
            userPresetSettings: userPresetSettings,
            lastUsedSettings: lastUsedSettings
        )
    }

    /// Updates the foreground-preservation strength.
    mutating func setStrength(
        _ newValue: Double
    ) {
        guard strength != newValue else {
            return
        }

        strength = newValue
        settingsSource = .custom
    }

    /// Updates the mask-smoothing amount.
    mutating func setEdgeSmoothing(
        _ newValue: Double
    ) {
        guard edgeSmoothing != newValue else {
            return
        }

        edgeSmoothing = newValue
        settingsSource = .custom
    }

    /// Updates the edge expansion amount.
    mutating func setEdgeExpansion(
        _ newValue: Double
    ) {
        guard edgeExpansion != newValue else {
            return
        }

        edgeExpansion = newValue
        settingsSource = .custom
    }

    /// Updates the selected naming template.
    mutating func setNamingTemplate(
        _ newValue: BatchImageNamingTemplate
    ) {
        guard namingTemplate != newValue else {
            return
        }

        namingTemplate = newValue
        settingsSource = .custom
    }

    /// Updates the editable custom prefix text.
    mutating func setCustomNamingPrefixText(
        _ newValue: String
    ) {
        customNamingPrefixText = newValue
        settingsSource = .custom
    }

    /// Updates the selected numbering style.
    mutating func setNamingNumberingStyle(
        _ newValue: BatchImageNumberingStyle
    ) {
        guard numberingStyle != newValue else {
            return
        }

        numberingStyle = newValue
        settingsSource = .custom
    }

    /// Selects which saved settings source should populate the editable fields.
    mutating func setSettingsSource(
        _ newValue: BatchImageSettingsSource
    ) {
        guard settingsSource != newValue else {
            return
        }

        settingsSource = newValue
        didSelectSettingsSource()
    }

    /// Applies the user preset slot when available.
    mutating func applyUserPresetSettings() {
        guard hasUserPresetSettings else {
            return
        }

        setSettingsSource(.userPreset)
    }

    /// Applies the last-used settings slot.
    mutating func applyLastUsedSettings() {
        setSettingsSource(.lastUsed)
    }

    /// Saves the current valid settings into the user preset slot.
    mutating func saveCurrentAsUserPreset() {
        guard let currentPersistedSettings else {
            return
        }

        userPresetSettings = currentPersistedSettings
        settingsSource = .userPreset
    }

    /// Persists the current valid settings into the last-used slot.
    mutating func persistCurrentAsLastUsed() {
        guard let currentPersistedSettings else {
            return
        }

        persistLastUsedSettings(currentPersistedSettings)
    }

    /// Persists an explicit settings payload into the last-used slot.
    mutating func persistLastUsedSettings(
        _ settings: PersistedBatchBackgroundRemovalSettings
    ) {
        lastUsedSettings = settings

        if settingsSource == .custom {
            settingsSource = .lastUsed
        }
    }
}

private extension BatchBackgroundRemovalPreferencesState {
    var validatedNaming: BatchImageNaming? {
        let naming: BatchImageNaming = .init(
            template: namingTemplate,
            customPrefix: customNamingPrefixText,
            numberingStyle: numberingStyle
        )

        guard naming.isValid else {
            return nil
        }

        return naming
    }

    mutating func didSelectSettingsSource() {
        switch settingsSource {
        case .lastUsed:
            replaceCurrentSettings(with: lastUsedSettings)
        case .userPreset:
            guard let userPresetSettings else {
                settingsSource = .lastUsed
                return
            }

            replaceCurrentSettings(with: userPresetSettings)
        case .custom:
            break
        }
    }

    mutating func replaceCurrentSettings(
        with settings: PersistedBatchBackgroundRemovalSettings
    ) {
        strength = settings.strength
        edgeSmoothing = settings.edgeSmoothing
        edgeExpansion = settings.edgeExpansion
        namingTemplate = settings.naming.template
        customNamingPrefixText = settings.naming.customPrefix
        numberingStyle = settings.naming.numberingStyle
    }
}
