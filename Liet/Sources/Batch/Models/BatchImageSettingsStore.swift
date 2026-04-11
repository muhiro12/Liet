import Foundation
import LietLibrary
import MHPlatform

struct BatchImageSettingsStore {
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
        appStorage(userDefaults: AppGroup.userDefaults())
    }

    static func appStorage(
        userDefaults: UserDefaults
    ) -> Self {
        let preferenceStore = MHPreferenceStore(
            userDefaults: userDefaults
        )
        let storage = BatchImagePreferencesStore(
            preferenceStore: preferenceStore
        )

        return .init(
            loadHandler: {
                storage.load()
            },
            saveHandler: { preferences in
                storage.save(preferences)
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
