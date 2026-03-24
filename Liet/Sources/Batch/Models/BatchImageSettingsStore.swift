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

struct BatchImageSettingsStore {
    private static let storageKey = "batch.image.settings"

    private let loadHandler: () -> PersistedBatchImageSettings?
    private let saveHandler: (PersistedBatchImageSettings) -> Void

    init(
        loadHandler: @escaping () -> PersistedBatchImageSettings?,
        saveHandler: @escaping (PersistedBatchImageSettings) -> Void
    ) {
        self.loadHandler = loadHandler
        self.saveHandler = saveHandler
    }

    func load() -> PersistedBatchImageSettings? {
        loadHandler()
    }

    func save(
        _ settings: PersistedBatchImageSettings
    ) {
        saveHandler(settings)
    }
}

extension BatchImageSettingsStore {
    static func live(
        userDefaults: UserDefaults = .standard
    ) -> Self {
        .init(
            loadHandler: {
                guard let data = userDefaults.data(forKey: storageKey) else {
                    return nil
                }

                return try? JSONDecoder().decode(
                    PersistedBatchImageSettings.self,
                    from: data
                )
            },
            saveHandler: { settings in
                guard let data = try? JSONEncoder().encode(settings) else {
                    return
                }

                userDefaults.set(
                    data,
                    forKey: storageKey
                )
            }
        )
    }

    static func inMemory(
        initialValue: PersistedBatchImageSettings? = nil
    ) -> Self {
        final class StorageBox {
            var value: PersistedBatchImageSettings?

            init(
                value: PersistedBatchImageSettings?
            ) {
                self.value = value
            }
        }

        let storageBox = StorageBox(value: initialValue)

        return .init(
            loadHandler: {
                storageBox.value
            },
            saveHandler: { settings in
                storageBox.value = settings
            }
        )
    }
}
