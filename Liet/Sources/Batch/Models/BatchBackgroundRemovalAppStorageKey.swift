import MHPreferences

enum BatchBackgroundRemovalAppStorageKey: String, MHStringPreferenceKeyRepresentable {
    case lastUsedSettings = "G7r2Lp5X"
    case userPresetSettings = "U1m8Qv4N"

    var preferenceKey: MHStringPreferenceKey {
        .init(storageKey: rawValue)
    }
}
