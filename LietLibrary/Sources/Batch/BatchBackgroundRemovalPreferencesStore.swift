import MHPlatformCore

/// Loads and saves persisted background-removal preferences through `MHPreferenceStore`.
struct BatchBackgroundRemovalPreferencesStore {
    private let preferenceStore: MHPreferenceStore

    /// Creates a store backed by the supplied typed preference store.
    init(
        preferenceStore: MHPreferenceStore
    ) {
        self.preferenceStore = preferenceStore
    }

    /// Returns the current persisted preferences when available.
    func load() -> BatchBackgroundRemovalPreferences? {
        preferenceStore.codable(
            for: LietPreferenceDescriptors.BatchBackgroundRemoval.preferences
        )
    }

    /// Persists the current preferences to the opaque storage slot.
    func save(
        _ preferences: BatchBackgroundRemovalPreferences
    ) {
        preferenceStore.setCodable(
            preferences,
            for: LietPreferenceDescriptors.BatchBackgroundRemoval.preferences
        )
    }
}
