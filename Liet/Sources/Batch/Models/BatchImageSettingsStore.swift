import Foundation
import LietLibrary

enum PersistedBatchResizeMode: String, Codable, Equatable {
    case aspectRatioPreserved
    case exactSize
}

struct PersistedBatchImageSettings: Codable, Equatable {
    var resizeMode: PersistedBatchResizeMode
    var referenceDimension: BatchResizeReferenceDimension
    var referencePixels: Int
    var exactWidthPixels: Int
    var exactHeightPixels: Int
    var exactResizeStrategy: BatchExactResizeStrategy
    var compression: BatchImageCompression

    static let `default`: Self = .init(
        resizeMode: .aspectRatioPreserved,
        referenceDimension: BatchResizeMode.defaultReferenceDimension,
        referencePixels: BatchResizeMode.defaultReferencePixels,
        exactWidthPixels: BatchResizeMode.defaultWidthPixels,
        exactHeightPixels: BatchResizeMode.defaultHeightPixels,
        exactResizeStrategy: .stretch,
        compression: .off
    )
}

struct PersistedBatchImagePreferences: Codable, Equatable {
    var defaultSettings: PersistedBatchImageSettings
    var lastUsedSettings: PersistedBatchImageSettings

    static let `default`: Self = .init(
        defaultSettings: .default,
        lastUsedSettings: .default
    )
}

struct BatchImageSettingsStore {
    nonisolated static let appGroupIdentifier = AppGroup.id
    nonisolated static let storageKey = "batch.image.preferences"
    nonisolated static let legacyStorageKey = "batch.image.settings"

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
    static func live(
        userDefaults: UserDefaults? = nil,
        legacyUserDefaults: UserDefaults = .standard
    ) -> Self {
        let resolvedUserDefaults: UserDefaults

        if let userDefaults {
            resolvedUserDefaults = userDefaults
        } else if let appGroupUserDefaults = UserDefaults(
            suiteName: appGroupIdentifier
        ) {
            resolvedUserDefaults = appGroupUserDefaults
        } else {
            preconditionFailure("Failed to resolve App Group user defaults.")
        }

        legacyUserDefaults.removeObject(forKey: legacyStorageKey)

        return .init(
            loadHandler: {
                guard let data = resolvedUserDefaults.data(
                    forKey: storageKey
                ) else {
                    return nil
                }

                return try? JSONDecoder().decode(
                    PersistedBatchImagePreferences.self,
                    from: data
                )
            },
            saveHandler: { preferences in
                guard let data = try? JSONEncoder().encode(preferences) else {
                    return
                }

                resolvedUserDefaults.set(
                    data,
                    forKey: storageKey
                )
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
