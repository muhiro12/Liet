import Foundation
import MHPlatformCore

/// Loads and saves persisted background-removal preferences through `MHPreferenceStore`.
public struct BatchBackgroundRemovalPreferencesStore {
    private enum StorageKeys {
        static let preferences = MHCodablePreferenceKey<PersistedBatchBackgroundRemovalPreferences>(
            storageKey: "batch.backgroundRemoval.preferences.v2"
        )
        static let lastUsedSettings = MHStringPreferenceKey(
            storageKey: "G7r2Lp5X"
        )
        static let userPresetSettings = MHStringPreferenceKey(
            storageKey: "U1m8Qv4N"
        )
    }

    private let preferenceStore: MHPreferenceStore

    /// Creates a store backed by the supplied typed preference store.
    public init(
        preferenceStore: MHPreferenceStore
    ) {
        self.preferenceStore = preferenceStore
    }

    /// Returns the current persisted preferences, including legacy-key migration.
    public func load() -> PersistedBatchBackgroundRemovalPreferences? {
        if let preferences = preferenceStore.codable(
            for: StorageKeys.preferences
        ) {
            return preferences
        }

        return loadLegacyPreferences()
    }

    /// Persists the current preferences and removes legacy string slots.
    public func save(
        _ preferences: PersistedBatchBackgroundRemovalPreferences
    ) {
        preferenceStore.setCodable(
            preferences,
            for: StorageKeys.preferences
        )
        removeLegacyPreferences()
    }
}

private extension BatchBackgroundRemovalPreferencesStore {
    func loadLegacyPreferences() -> PersistedBatchBackgroundRemovalPreferences? {
        let lastUsedSettings = preferenceStore.string(
            for: StorageKeys.lastUsedSettings
        )
        let userPresetSettings = preferenceStore.string(
            for: StorageKeys.userPresetSettings
        )

        guard lastUsedSettings != nil || userPresetSettings != nil else {
            return nil
        }

        return .init(
            userPresetSettings: userPresetSettings.flatMap(
                PersistedBatchBackgroundRemovalSettings.init(rawValue:)
            ),
            lastUsedSettings: lastUsedSettings.flatMap(
                PersistedBatchBackgroundRemovalSettings.init(rawValue:)
            ) ?? .default
        )
    }

    func removeLegacyPreferences() {
        preferenceStore.remove(StorageKeys.lastUsedSettings)
        preferenceStore.remove(StorageKeys.userPresetSettings)
    }
}
