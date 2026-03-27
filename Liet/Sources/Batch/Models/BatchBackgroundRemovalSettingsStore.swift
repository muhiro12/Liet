import Foundation
import LietLibrary
import MHPreferences
import SwiftUI

struct BatchBackgroundRemovalSettingsStore {
    nonisolated static let appGroupIdentifier = AppGroup.id

    private let loadHandler: () -> PersistedBatchBackgroundRemovalPreferences?
    private let saveHandler: (PersistedBatchBackgroundRemovalPreferences) -> Void

    init(
        loadHandler: @escaping () -> PersistedBatchBackgroundRemovalPreferences?,
        saveHandler: @escaping (PersistedBatchBackgroundRemovalPreferences) -> Void
    ) {
        self.loadHandler = loadHandler
        self.saveHandler = saveHandler
    }

    func load() -> PersistedBatchBackgroundRemovalPreferences? {
        loadHandler()
    }

    func save(
        _ preferences: PersistedBatchBackgroundRemovalPreferences
    ) {
        saveHandler(preferences)
    }
}

extension BatchBackgroundRemovalSettingsStore {
    static func live() -> Self {
        guard let userDefaults = UserDefaults(
            suiteName: appGroupIdentifier
        ) else {
            preconditionFailure("Failed to resolve App Group user defaults.")
        }

        return appStorage(userDefaults: userDefaults)
    }

    static func appStorage(
        userDefaults: UserDefaults
    ) -> Self {
        let storageBox = AppStorageBox(userDefaults: userDefaults)

        return .init(
            loadHandler: {
                storageBox.loadPreferences()
            },
            saveHandler: { preferences in
                storageBox.savePreferences(preferences)
            }
        )
    }

    static func inMemory(
        initialValue: PersistedBatchBackgroundRemovalPreferences? = nil
    ) -> Self {
        final class StorageBox {
            var value: PersistedBatchBackgroundRemovalPreferences?

            init(
                value: PersistedBatchBackgroundRemovalPreferences?
            ) {
                self.value = value
            }
        }

        let storageBox = StorageBox(value: initialValue)

        return .init(
            loadHandler: {
                storageBox.value
            },
            saveHandler: { preferences in
                storageBox.value = preferences
            }
        )
    }
}

private extension BatchBackgroundRemovalSettingsStore {
    final class AppStorageBox {
        @AppStorage private var lastUsedSettings: PersistedBatchBackgroundRemovalSettings
        @AppStorage private var userPresetSettingsRawValue: String

        private let userDefaults: UserDefaults

        private var hasLastUsedSettings: Bool {
            userDefaults.string(
                forKey: BatchBackgroundRemovalAppStorageKey.lastUsedSettings.preferenceKey.storageKey
            ) != nil
        }

        private var hasUserPresetSettings: Bool {
            userDefaults.string(
                forKey: BatchBackgroundRemovalAppStorageKey.userPresetSettings.preferenceKey.storageKey
            ) != nil
        }

        private var hasStoredPreferences: Bool {
            hasLastUsedSettings || hasUserPresetSettings
        }

        init(
            userDefaults: UserDefaults
        ) {
            self.userDefaults = userDefaults
            _lastUsedSettings = AppStorage(
                BatchBackgroundRemovalAppStorageKey.lastUsedSettings,
                default: .default,
                store: userDefaults
            )
            _userPresetSettingsRawValue = AppStorage(
                BatchBackgroundRemovalAppStorageKey.userPresetSettings,
                default: "",
                store: userDefaults
            )
        }

        func loadPreferences() -> PersistedBatchBackgroundRemovalPreferences? {
            guard hasStoredPreferences else {
                return nil
            }

            return .init(
                userPresetSettings: hasUserPresetSettings
                    ? PersistedBatchBackgroundRemovalSettings(rawValue: userPresetSettingsRawValue)
                    : nil,
                lastUsedSettings: lastUsedSettings
            )
        }

        func savePreferences(
            _ preferences: PersistedBatchBackgroundRemovalPreferences
        ) {
            lastUsedSettings = preferences.lastUsedSettings
            guard let userPresetSettings = preferences.userPresetSettings else {
                userPresetSettingsRawValue = ""
                userDefaults.removeObject(
                    forKey: BatchBackgroundRemovalAppStorageKey.userPresetSettings.preferenceKey.storageKey
                )
                return
            }

            userPresetSettingsRawValue = userPresetSettings.rawValue
        }
    }
}
