import MHPreferences

enum BatchImageAppStorageKey: String, MHStringPreferenceKeyRepresentable {
    case lastUsedSettings = "d9K2mQ7x"
    case userPresetSettings = "P4v8T1nR"

    var preferenceKey: MHStringPreferenceKey {
        .init(storageKey: rawValue)
    }
}
