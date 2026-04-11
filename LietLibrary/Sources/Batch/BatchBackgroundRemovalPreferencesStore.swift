import MHPlatformCore

/// Loads and saves persisted background-removal preferences through `MHPreferenceStore`.
public struct BatchBackgroundRemovalPreferencesStore {
    private let preferenceStore: MHPreferenceStore

    /// Creates a store backed by the supplied typed preference store.
    public init(
        preferenceStore: MHPreferenceStore
    ) {
        self.preferenceStore = preferenceStore
    }

    /// Returns the current persisted preferences when available.
    public func load() -> PersistedBatchBackgroundRemovalPreferences? {
        preferenceStore.codable(
            for: LietPreferenceKeys.BatchBackgroundRemoval.preferences
        )
    }

    /// Persists the current preferences to the opaque storage slot.
    public func save(
        _ preferences: PersistedBatchBackgroundRemovalPreferences
    ) {
        preferenceStore.setCodable(
            preferences,
            for: LietPreferenceKeys.BatchBackgroundRemoval.preferences
        )
    }
}
