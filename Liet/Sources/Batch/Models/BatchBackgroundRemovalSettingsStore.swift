import Foundation
import LietLibrary
import MHPlatform

struct BatchBackgroundRemovalSettingsStore {
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
        appStorage(userDefaults: AppGroup.userDefaults())
    }

    static func appStorage(
        userDefaults: UserDefaults
    ) -> Self {
        let preferenceStore = MHPreferenceStore(
            userDefaults: userDefaults
        )
        let storage = BatchBackgroundRemovalPreferencesStore(
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
