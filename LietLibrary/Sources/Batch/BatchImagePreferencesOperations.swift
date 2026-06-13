import MHPlatformCore

/// Batch-image preference use cases called by delivery surfaces.
public struct BatchImagePreferencesOperations {
    private let store: BatchImagePreferencesStore

    /// Creates preference operations backed by the supplied typed preference store.
    public init(
        preferenceStore: MHPreferenceStore
    ) {
        store = .init(
            preferenceStore: preferenceStore
        )
    }

    /// Returns the current persisted preferences when available.
    public func loadPreferences() -> PersistedBatchImagePreferences? {
        store.load()
    }

    /// Persists the current preferences to the opaque storage slot.
    public func savePreferences(
        _ preferences: PersistedBatchImagePreferences
    ) {
        store.save(
            preferences
        )
    }
}
