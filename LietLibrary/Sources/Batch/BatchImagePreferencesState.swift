import Foundation

/// Mutable batch-settings state shared between persistence rules and the app model.
public struct BatchImagePreferencesState: Equatable, Sendable {
    /// The selected reference edge when aspect ratio is preserved.
    public var referenceDimension: BatchResizeReferenceDimension
    /// The editable text value for the reference pixel field.
    public var referencePixelsText: String
    /// The editable text value for the exact-width field.
    public var resizeWidthText: String
    /// The editable text value for the exact-height field.
    public var resizeHeightText: String
    /// Whether the current resize mode preserves the source aspect ratio.
    public var keepsAspectRatio: Bool
    /// The optional persisted user preset slot.
    public var userPresetSettings: PersistedBatchImageSettings?
    /// The persisted last-used settings slot.
    public var lastUsedSettings: PersistedBatchImageSettings
    /// The saved source currently selected in the UI.
    public var settingsSource: BatchImageSettingsSource
    /// The exact-size render strategy currently selected.
    public var exactResizeStrategy: BatchExactResizeStrategy
    /// The compression preset currently selected.
    public var compression: BatchImageCompression
    /// The background-removal settings currently selected.
    public var backgroundRemoval: BatchBackgroundRemovalSettings
    /// The output naming template currently selected.
    public var namingTemplate: BatchImageNamingTemplate
    /// The editable custom naming prefix text.
    public var customNamingPrefixText: String
    /// The numbering style currently selected for generated filenames.
    public var numberingStyle: BatchImageNumberingStyle

    /// Creates a preferences state from explicit editable and persisted values.
    public init(
        referenceDimension: BatchResizeReferenceDimension,
        referencePixelsText: String,
        resizeWidthText: String,
        resizeHeightText: String,
        keepsAspectRatio: Bool,
        userPresetSettings: PersistedBatchImageSettings?,
        lastUsedSettings: PersistedBatchImageSettings,
        settingsSource: BatchImageSettingsSource,
        exactResizeStrategy: BatchExactResizeStrategy,
        compression: BatchImageCompression,
        backgroundRemoval: BatchBackgroundRemovalSettings,
        namingTemplate: BatchImageNamingTemplate,
        customNamingPrefixText: String,
        numberingStyle: BatchImageNumberingStyle
    ) {
        self.referenceDimension = referenceDimension
        self.referencePixelsText = referencePixelsText
        self.resizeWidthText = resizeWidthText
        self.resizeHeightText = resizeHeightText
        self.keepsAspectRatio = keepsAspectRatio
        self.userPresetSettings = userPresetSettings
        self.lastUsedSettings = lastUsedSettings
        self.settingsSource = settingsSource
        self.exactResizeStrategy = exactResizeStrategy
        self.compression = compression
        self.backgroundRemoval = backgroundRemoval
        self.namingTemplate = namingTemplate
        self.customNamingPrefixText = customNamingPrefixText
        self.numberingStyle = numberingStyle
    }

    /// Creates a preferences state from the persisted preference slots.
    public init(
        preferences: PersistedBatchImagePreferences = .default
    ) {
        let initialSettings = preferences.lastUsedSettings
        self.init(
            referenceDimension: initialSettings.referenceDimension,
            referencePixelsText: "\(initialSettings.referencePixels)",
            resizeWidthText: "\(initialSettings.exactWidthPixels)",
            resizeHeightText: "\(initialSettings.exactHeightPixels)",
            keepsAspectRatio: initialSettings.resizeMode == .aspectRatioPreserved,
            userPresetSettings: preferences.userPresetSettings,
            lastUsedSettings: preferences.lastUsedSettings,
            settingsSource: .lastUsed,
            exactResizeStrategy: initialSettings.exactResizeStrategy,
            compression: initialSettings.compression,
            backgroundRemoval: initialSettings.backgroundRemoval,
            namingTemplate: initialSettings.naming.template,
            customNamingPrefixText: initialSettings.naming.customPrefix,
            numberingStyle: initialSettings.naming.numberingStyle
        )
    }
}

public extension BatchImagePreferencesState {
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

    /// The validated reference pixel value when the input is a positive integer.
    var referencePixels: Int? {
        Self.positiveInteger(from: referencePixelsText)
    }

    /// The validated exact-width value when the input is a positive integer.
    var exactWidthPixels: Int? {
        Self.positiveInteger(from: resizeWidthText)
    }

    /// The validated exact-height value when the input is a positive integer.
    var exactHeightPixels: Int? {
        Self.positiveInteger(from: resizeHeightText)
    }

    /// The resolved batch settings when the current inputs are valid.
    var settings: BatchImageSettings? {
        guard let validatedNaming else {
            return nil
        }

        if keepsAspectRatio {
            guard let referencePixels else {
                return nil
            }

            return .init(
                resizeMode: .fitWithin(
                    referenceDimension: referenceDimension,
                    pixels: referencePixels
                ),
                compression: compression,
                backgroundRemoval: backgroundRemoval,
                naming: validatedNaming
            )
        }

        guard let exactWidthPixels,
              let exactHeightPixels else {
            return nil
        }

        return .init(
            resizeMode: .exactSize(
                widthPixels: exactWidthPixels,
                heightPixels: exactHeightPixels,
                strategy: exactResizeStrategy
            ),
            compression: compression,
            backgroundRemoval: backgroundRemoval,
            naming: validatedNaming
        )
    }

    /// The persisted settings payload for the current editable values when valid.
    var currentPersistedSettings: PersistedBatchImageSettings? {
        guard let validatedNaming else {
            return nil
        }

        let persistedResizeMode: PersistedBatchResizeMode = keepsAspectRatio
            ? .aspectRatioPreserved
            : .exactSize
        let storedReferencePixels: Int

        if keepsAspectRatio {
            guard let referencePixels else {
                return nil
            }

            storedReferencePixels = referencePixels
        } else {
            storedReferencePixels = referencePixels ?? BatchResizeMode.defaultReferencePixels
        }

        let storedExactWidthPixels: Int
        let storedExactHeightPixels: Int

        if keepsAspectRatio {
            storedExactWidthPixels = exactWidthPixels ?? BatchResizeMode.defaultWidthPixels
            storedExactHeightPixels = exactHeightPixels ?? BatchResizeMode.defaultHeightPixels
        } else {
            guard let exactWidthPixels,
                  let exactHeightPixels else {
                return nil
            }

            storedExactWidthPixels = exactWidthPixels
            storedExactHeightPixels = exactHeightPixels
        }

        return .init(
            resizeMode: persistedResizeMode,
            referenceDimension: referenceDimension,
            referencePixels: storedReferencePixels,
            exactWidthPixels: storedExactWidthPixels,
            exactHeightPixels: storedExactHeightPixels,
            exactResizeStrategy: exactResizeStrategy,
            compression: compression,
            backgroundRemoval: backgroundRemoval,
            naming: validatedNaming
        )
    }

    /// The persisted preference slots represented by the current state.
    var preferences: PersistedBatchImagePreferences {
        .init(
            userPresetSettings: userPresetSettings,
            lastUsedSettings: lastUsedSettings
        )
    }

    /// Selects a different aspect-ratio reference edge.
    mutating func setReferenceDimension(
        _ newValue: BatchResizeReferenceDimension
    ) {
        guard referenceDimension != newValue else {
            return
        }

        referenceDimension = newValue
        settingsSource = .custom
    }

    /// Updates the editable reference pixel text.
    mutating func setReferencePixelsText(
        _ newValue: String
    ) {
        referencePixelsText = newValue
        settingsSource = .custom
    }

    /// Updates the editable exact-width text.
    mutating func setResizeWidthText(
        _ newValue: String
    ) {
        resizeWidthText = newValue
        settingsSource = .custom
    }

    /// Updates the editable exact-height text.
    mutating func setResizeHeightText(
        _ newValue: String
    ) {
        resizeHeightText = newValue
        settingsSource = .custom
    }

    /// Switches between aspect-ratio-preserving and exact-size modes.
    mutating func setKeepsAspectRatio(
        _ newValue: Bool
    ) {
        guard keepsAspectRatio != newValue else {
            return
        }

        keepsAspectRatio = newValue
        settingsSource = .custom
    }

    /// Updates the exact-size render strategy.
    mutating func setExactResizeStrategy(
        _ newValue: BatchExactResizeStrategy
    ) {
        guard exactResizeStrategy != newValue else {
            return
        }

        exactResizeStrategy = newValue
        settingsSource = .custom
    }

    /// Updates the compression preset.
    mutating func setCompression(
        _ newValue: BatchImageCompression
    ) {
        guard compression != newValue else {
            return
        }

        compression = newValue
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
        _ settings: PersistedBatchImageSettings
    ) {
        lastUsedSettings = settings

        if settingsSource == .custom {
            settingsSource = .lastUsed
        }
    }
}

private extension BatchImagePreferencesState {
    static func positiveInteger(
        from text: String
    ) -> Int? {
        guard let value = Int(text),
              value > 0 else {
            return nil
        }

        return value
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
        with settings: PersistedBatchImageSettings
    ) {
        referenceDimension = settings.referenceDimension
        referencePixelsText = "\(settings.referencePixels)"
        resizeWidthText = "\(settings.exactWidthPixels)"
        resizeHeightText = "\(settings.exactHeightPixels)"
        keepsAspectRatio = settings.resizeMode == .aspectRatioPreserved
        exactResizeStrategy = settings.exactResizeStrategy
        compression = settings.compression
        backgroundRemoval = settings.backgroundRemoval
        namingTemplate = settings.naming.template
        customNamingPrefixText = settings.naming.customPrefix
        numberingStyle = settings.naming.numberingStyle
    }
}
