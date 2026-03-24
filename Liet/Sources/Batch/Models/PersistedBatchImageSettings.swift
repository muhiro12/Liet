// swiftlint:disable type_contents_order
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

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        resizeMode = try container.decode(
            PersistedBatchResizeMode.self,
            forKey: .resizeMode
        )
        referenceDimension = try container.decode(
            BatchResizeReferenceDimension.self,
            forKey: .referenceDimension
        )
        referencePixels = try container.decode(
            Int.self,
            forKey: .referencePixels
        )
        exactWidthPixels = try container.decode(
            Int.self,
            forKey: .exactWidthPixels
        )
        exactHeightPixels = try container.decode(
            Int.self,
            forKey: .exactHeightPixels
        )
        exactResizeStrategy = try container.decode(
            BatchExactResizeStrategy.self,
            forKey: .exactResizeStrategy
        )
        compression = try container.decode(
            BatchImageCompression.self,
            forKey: .compression
        )
    }

    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(resizeMode, forKey: .resizeMode)
        try container.encode(referenceDimension, forKey: .referenceDimension)
        try container.encode(referencePixels, forKey: .referencePixels)
        try container.encode(exactWidthPixels, forKey: .exactWidthPixels)
        try container.encode(exactHeightPixels, forKey: .exactHeightPixels)
        try container.encode(exactResizeStrategy, forKey: .exactResizeStrategy)
        try container.encode(compression, forKey: .compression)
    }

    private enum CodingKeys: String, CodingKey {
        case resizeMode = "R7m2Kp4Q"
        case referenceDimension = "D4x8Nh1V"
        case referencePixels = "P6t3Lc9W"
        case exactWidthPixels = "W1q5Fs8J"
        case exactHeightPixels = "H9v2Tr6B"
        case exactResizeStrategy = "S3n7Yk5M"
        case compression = "C8p4Zd2X"
    }
}
// swiftlint:enable type_contents_order
