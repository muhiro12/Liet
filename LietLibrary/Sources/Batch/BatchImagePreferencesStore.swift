import MHPlatformCore

/// Loads and saves persisted batch-image preferences through `MHPreferenceStore`.
struct BatchImagePreferencesStore {
    private let preferenceStore: MHPreferenceStore

    /// Creates a store backed by the supplied typed preference store.
    init(
        preferenceStore: MHPreferenceStore
    ) {
        self.preferenceStore = preferenceStore
    }

    /// Returns the current persisted preferences when available.
    func load() -> PersistedBatchImagePreferences? {
        preferenceStore.codable(
            for: LietPreferenceDescriptors.BatchImage.preferences
        )
    }

    /// Persists the current preferences to the opaque storage slot.
    func save(
        _ preferences: PersistedBatchImagePreferences
    ) {
        preferenceStore.setCodable(
            preferences,
            for: LietPreferenceDescriptors.BatchImage.preferences
        )
    }
}
