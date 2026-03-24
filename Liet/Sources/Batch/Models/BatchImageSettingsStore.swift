import Foundation
import LietLibrary
import MHPreferences
import SwiftUI

struct BatchImageSettingsStore {
    nonisolated static let appGroupIdentifier = AppGroup.id

    private let loadHandler: () -> PersistedBatchImagePreferences?
    private let saveHandler: (PersistedBatchImagePreferences) -> Void

    init(
        loadHandler: @escaping () -> PersistedBatchImagePreferences?,
        saveHandler: @escaping (PersistedBatchImagePreferences) -> Void
    ) {
        self.loadHandler = loadHandler
        self.saveHandler = saveHandler
    }

    func load() -> PersistedBatchImagePreferences? {
        loadHandler()
    }

    func save(
        _ preferences: PersistedBatchImagePreferences
    ) {
        saveHandler(preferences)
    }
}

extension BatchImageSettingsStore {
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
        initialValue: PersistedBatchImagePreferences? = nil
    ) -> Self {
        final class StorageBox {
            var value: PersistedBatchImagePreferences?

            init(
                value: PersistedBatchImagePreferences?
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

private extension BatchImageSettingsStore {
    final class AppStorageBox {
        @AppStorage private var lastUsedSettings: PersistedBatchImageSettings
        @AppStorage private var userPresetSettingsRawValue: String

        private let userDefaults: UserDefaults
        private var hasLastUsedSettings: Bool {
            userDefaults.string(
                forKey: BatchImageAppStorageKey.lastUsedSettings.preferenceKey.storageKey
            ) != nil
        }

        private var hasUserPresetSettings: Bool {
            userDefaults.string(
                forKey: BatchImageAppStorageKey.userPresetSettings.preferenceKey.storageKey
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
                BatchImageAppStorageKey.lastUsedSettings,
                default: .default,
                store: userDefaults
            )
            _userPresetSettingsRawValue = AppStorage(
                BatchImageAppStorageKey.userPresetSettings,
                default: "",
                store: userDefaults
            )
        }

        func loadPreferences() -> PersistedBatchImagePreferences? {
            guard hasStoredPreferences else {
                return nil
            }

            return .init(
                userPresetSettings: hasUserPresetSettings
                    ? PersistedBatchImageSettings(rawValue: userPresetSettingsRawValue)
                    : nil,
                lastUsedSettings: lastUsedSettings
            )
        }

        func savePreferences(
            _ preferences: PersistedBatchImagePreferences
        ) {
            lastUsedSettings = preferences.lastUsedSettings
            guard let userPresetSettings = preferences.userPresetSettings else {
                userPresetSettingsRawValue = ""
                userDefaults.removeObject(
                    forKey: BatchImageAppStorageKey.userPresetSettings.preferenceKey.storageKey
                )
                return
            }

            userPresetSettingsRawValue = userPresetSettings.rawValue
        }
    }
}
