import MHPlatformCore

/// Loads and saves persisted batch-image preferences through `MHPreferenceStore`.
public struct BatchImagePreferencesStore {
    private let preferenceStore: MHPreferenceStore

    /// Creates a store backed by the supplied typed preference store.
    public init(
        preferenceStore: MHPreferenceStore
    ) {
        self.preferenceStore = preferenceStore
    }

    /// Returns the current persisted preferences when available.
    public func load() -> PersistedBatchImagePreferences? {
        preferenceStore.codable(
            for: LietPreferenceKeys.BatchImage.preferences
        )
    }

    /// Persists the current preferences to the opaque storage slot.
    public func save(
        _ preferences: PersistedBatchImagePreferences
    ) {
        preferenceStore.setCodable(
            preferences,
            for: LietPreferenceKeys.BatchImage.preferences
        )
    }
}
