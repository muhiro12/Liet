import MHPlatformCore

/// Background-removal preference use cases called by delivery surfaces.
public struct BackgroundRemovalPreferencesOperations {
    private let store: BatchBackgroundRemovalPreferencesStore

    /// Creates preference operations backed by the supplied typed preference store.
    public init(
        preferenceStore: MHPreferenceStore
    ) {
        store = .init(
            preferenceStore: preferenceStore
        )
    }

    /// Returns the current persisted preferences when available.
    public func loadPreferences() -> PersistedBatchBackgroundRemovalPreferences? {
        store.load()
    }

    /// Persists the current preferences to the opaque storage slot.
    public func savePreferences(
        _ preferences: PersistedBatchBackgroundRemovalPreferences
    ) {
        store.save(
            preferences
        )
    }
}
