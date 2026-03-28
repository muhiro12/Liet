import Foundation
import MHPlatformCore

/// Loads and saves persisted batch-image preferences through `MHPreferenceStore`.
public struct BatchImagePreferencesStore {
    private enum StorageKeys {
        static let preferences = MHCodablePreferenceKey<PersistedBatchImagePreferences>(
            storageKey: "batch.image.preferences.v2"
        )
        static let lastUsedSettings = MHStringPreferenceKey(
            storageKey: "d9K2mQ7x"
        )
        static let userPresetSettings = MHStringPreferenceKey(
            storageKey: "P4v8T1nR"
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
    public func load() -> PersistedBatchImagePreferences? {
        if let preferences = preferenceStore.codable(
            for: StorageKeys.preferences
        ) {
            return preferences
        }

        return loadLegacyPreferences()
    }

    /// Persists the current preferences and removes legacy string slots.
    public func save(
        _ preferences: PersistedBatchImagePreferences
    ) {
        preferenceStore.setCodable(
            preferences,
            for: StorageKeys.preferences
        )
        removeLegacyPreferences()
    }
}

private extension BatchImagePreferencesStore {
    func loadLegacyPreferences() -> PersistedBatchImagePreferences? {
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
                PersistedBatchImageSettings.init(rawValue:)
            ),
            lastUsedSettings: lastUsedSettings.flatMap(
                PersistedBatchImageSettings.init(rawValue:)
            ) ?? .default
        )
    }

    func removeLegacyPreferences() {
        preferenceStore.remove(StorageKeys.lastUsedSettings)
        preferenceStore.remove(StorageKeys.userPresetSettings)
    }
}
