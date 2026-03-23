import Foundation
import LietLibrary

struct PersistedBatchImageSettings: Codable, Equatable {
    var widthPixels: Int
    var heightPixels: Int
    var keepsAspectRatio: Bool
    var exactResizeStrategy: BatchExactResizeStrategy
    var compression: BatchImageCompression

    static let `default`: Self = .init(
        widthPixels: BatchResizeMode.defaultWidthPixels,
        heightPixels: BatchResizeMode.defaultHeightPixels,
        keepsAspectRatio: true,
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
