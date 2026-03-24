import Foundation
import LietLibrary

struct PersistedBatchImageSettings: Codable, Equatable, RawRepresentable {
    static let `default`: Self = .init(
        resizeMode: .aspectRatioPreserved,
        referenceDimension: BatchResizeMode.defaultReferenceDimension,
        referencePixels: BatchResizeMode.defaultReferencePixels,
        exactWidthPixels: BatchResizeMode.defaultWidthPixels,
        exactHeightPixels: BatchResizeMode.defaultHeightPixels,
        exactResizeStrategy: .stretch,
        compression: .off
    )

    var resizeMode: PersistedBatchResizeMode
    var referenceDimension: BatchResizeReferenceDimension
    var referencePixels: Int
    var exactWidthPixels: Int
    var exactHeightPixels: Int
    var exactResizeStrategy: BatchExactResizeStrategy
    var compression: BatchImageCompression
    var rawValue: String {
        guard let data = try? JSONEncoder().encode(self),
              let string = String(data: data, encoding: .utf8) else {
            return ""
        }

        return string
    }

    init(
        resizeMode: PersistedBatchResizeMode,
        referenceDimension: BatchResizeReferenceDimension,
        referencePixels: Int,
        exactWidthPixels: Int,
        exactHeightPixels: Int,
        exactResizeStrategy: BatchExactResizeStrategy,
        compression: BatchImageCompression
    ) {
        self.resizeMode = resizeMode
        self.referenceDimension = referenceDimension
        self.referencePixels = referencePixels
        self.exactWidthPixels = exactWidthPixels
        self.exactHeightPixels = exactHeightPixels
        self.exactResizeStrategy = exactResizeStrategy
        self.compression = compression
    }

    init() {
        self = .default
    }

    init?(rawValue: String) {
        guard let data = rawValue.data(using: .utf8),
              let value = try? JSONDecoder().decode(Self.self, from: data) else {
            return nil
        }

        self = value
    }
}
