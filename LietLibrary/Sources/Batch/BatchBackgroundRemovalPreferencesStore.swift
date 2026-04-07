import Foundation
import MHPlatformCore

/// Loads and saves persisted background-removal preferences through `MHPreferenceStore`.
public struct BatchBackgroundRemovalPreferencesStore {
    private enum StorageKeys {
        static let preferences = MHCodablePreferenceKey<PersistedBatchBackgroundRemovalPreferences>(
            storageKey: "H3m8R2vK"
        )
    }

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
            for: StorageKeys.preferences
        )
    }

    /// Persists the current preferences to the opaque storage slot.
    public func save(
        _ preferences: PersistedBatchBackgroundRemovalPreferences
    ) {
        preferenceStore.setCodable(
            preferences,
            for: StorageKeys.preferences
        )
    }
}
