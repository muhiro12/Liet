import Foundation

/// Persisted batch settings encoded for app storage.
public struct PersistedBatchImageSettings: Codable, Equatable, RawRepresentable, Sendable {
    /// The default stored settings used when no preferences are persisted yet.
    public static let `default`: Self = .init(
        resizeMode: .aspectRatioPreserved,
        referenceDimension: BatchResizeMode.defaultReferenceDimension,
        referencePixels: BatchResizeMode.defaultReferencePixels,
        exactWidthPixels: BatchResizeMode.defaultWidthPixels,
        exactHeightPixels: BatchResizeMode.defaultHeightPixels,
        exactResizeStrategy: .stretch,
        compression: .off,
        naming: .default
    )

    /// The persisted resize-mode selection.
    public var resizeMode: PersistedBatchResizeMode
    /// The persisted reference dimension for aspect-ratio-preserving resizing.
    public var referenceDimension: BatchResizeReferenceDimension
    /// The persisted reference pixel value for aspect-ratio-preserving resizing.
    public var referencePixels: Int
    /// The persisted exact-width value.
    public var exactWidthPixels: Int
    /// The persisted exact-height value.
    public var exactHeightPixels: Int
    /// The persisted exact-size rendering strategy.
    public var exactResizeStrategy: BatchExactResizeStrategy
    /// The persisted compression preset.
    public var compression: BatchImageCompression
    /// The persisted output naming settings.
    public var naming: BatchImageNaming

    /// The serialized representation stored in app preferences.
    public var rawValue: String {
        guard let data = try? JSONEncoder().encode(self),
              let string = String(data: data, encoding: .utf8) else {
            return ""
        }

        return string
    }

    /// Creates a persisted settings payload from explicit field values.
    public init(
        resizeMode: PersistedBatchResizeMode,
        referenceDimension: BatchResizeReferenceDimension,
        referencePixels: Int,
        exactWidthPixels: Int,
        exactHeightPixels: Int,
        exactResizeStrategy: BatchExactResizeStrategy,
        compression: BatchImageCompression,
        naming: BatchImageNaming = .default
    ) {
        self.resizeMode = resizeMode
        self.referenceDimension = referenceDimension
        self.referencePixels = referencePixels
        self.exactWidthPixels = exactWidthPixels
        self.exactHeightPixels = exactHeightPixels
        self.exactResizeStrategy = exactResizeStrategy
        self.compression = compression
        self.naming = naming
    }

    /// Restores a persisted settings payload from its serialized representation.
    public init?(rawValue: String) {
        guard let data = rawValue.data(using: .utf8),
              let value = try? JSONDecoder().decode(Self.self, from: data) else {
            return nil
        }

        self = value
    }

    /// Decodes stored settings from the app preference payload.
    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: PersistedBatchImageSettingsCodingKeys.self)
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
        naming = try container.decodeIfPresent(
            BatchImageNaming.self,
            forKey: .naming
        ) ?? .default
    }

    /// Encodes stored settings into the app preference payload.
    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: PersistedBatchImageSettingsCodingKeys.self)
        try container.encode(resizeMode, forKey: .resizeMode)
        try container.encode(referenceDimension, forKey: .referenceDimension)
        try container.encode(referencePixels, forKey: .referencePixels)
        try container.encode(exactWidthPixels, forKey: .exactWidthPixels)
        try container.encode(exactHeightPixels, forKey: .exactHeightPixels)
        try container.encode(exactResizeStrategy, forKey: .exactResizeStrategy)
        try container.encode(compression, forKey: .compression)
        try container.encode(naming, forKey: .naming)
    }
}
