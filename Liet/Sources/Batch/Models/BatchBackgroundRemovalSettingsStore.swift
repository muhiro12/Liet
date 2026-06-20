import Foundation
import LietLibrary
import MHPlatform

struct BatchBackgroundRemovalSettingsStore {
    private let loadHandler: () -> BatchBackgroundRemovalPreferences?
    private let saveHandler: (BatchBackgroundRemovalPreferences) -> Void

    init(
        loadHandler: @escaping () -> BatchBackgroundRemovalPreferences?,
        saveHandler: @escaping (BatchBackgroundRemovalPreferences) -> Void
    ) {
        self.loadHandler = loadHandler
        self.saveHandler = saveHandler
    }

    func load() -> BatchBackgroundRemovalPreferences? {
        loadHandler()
    }

    func save(
        _ preferences: BatchBackgroundRemovalPreferences
    ) {
        saveHandler(preferences)
    }
}

extension BatchBackgroundRemovalSettingsStore {
    static func live() -> Self {
        live(selection: AppGroup.preferencesDefaultsSelection)
    }

    static func live(
        selection: MHUserDefaultsSelection
    ) -> Self {
        let preferenceStore = MHPreferenceStore(
            userDefaults: selection.resolveUserDefaults()
        )
        let operations = BackgroundRemovalPreferencesOperations(
            preferenceStore: preferenceStore
        )

        return .init(
            loadHandler: {
                operations.loadPreferences()
            },
            saveHandler: { preferences in
                operations.savePreferences(preferences)
            }
        )
    }

    static func inMemory(
        initialValue: BatchBackgroundRemovalPreferences? = nil
    ) -> Self {
        final class StorageBox {
            var value: BatchBackgroundRemovalPreferences?

            init(
                value: BatchBackgroundRemovalPreferences?
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
