import Foundation
import LietLibrary
import MHPlatform

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
