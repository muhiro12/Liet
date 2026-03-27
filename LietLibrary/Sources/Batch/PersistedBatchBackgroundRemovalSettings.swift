import Foundation

/// Persisted background-removal settings encoded for app storage.
public struct PersistedBatchBackgroundRemovalSettings: Codable, Equatable, RawRepresentable, Sendable {
    /// The default stored settings used when no preferences are persisted yet.
    public static let `default`: Self = .init(
        strength: BatchBackgroundRemovalSettings.default.strength,
        edgeSmoothing: BatchBackgroundRemovalSettings.default.edgeSmoothing,
        edgeExpansion: BatchBackgroundRemovalSettings.default.edgeExpansion,
        naming: .default
    )

    /// The persisted foreground-preservation strength.
    public var strength: Double
    /// The persisted mask-smoothing amount.
    public var edgeSmoothing: Double
    /// The persisted edge expansion amount.
    public var edgeExpansion: Double
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
        strength: Double,
        edgeSmoothing: Double,
        edgeExpansion: Double,
        naming: BatchImageNaming = .default
    ) {
        self.strength = strength
        self.edgeSmoothing = edgeSmoothing
        self.edgeExpansion = edgeExpansion
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
        let container = try decoder.container(
            keyedBy: PersistedBatchBackgroundRemovalSettingsCodingKeys.self
        )
        strength = try container.decode(
            Double.self,
            forKey: .strength
        )
        edgeSmoothing = try container.decode(
            Double.self,
            forKey: .edgeSmoothing
        )
        edgeExpansion = try container.decode(
            Double.self,
            forKey: .edgeExpansion
        )
        naming = try container.decodeIfPresent(
            BatchImageNaming.self,
            forKey: .naming
        ) ?? .default
    }

    /// Encodes stored settings into the app preference payload.
    public func encode(
        to encoder: any Encoder
    ) throws {
        var container = encoder.container(
            keyedBy: PersistedBatchBackgroundRemovalSettingsCodingKeys.self
        )
        try container.encode(strength, forKey: .strength)
        try container.encode(edgeSmoothing, forKey: .edgeSmoothing)
        try container.encode(edgeExpansion, forKey: .edgeExpansion)
        try container.encode(naming, forKey: .naming)
    }
}

public extension PersistedBatchBackgroundRemovalSettings {
    /// Restores the processing settings used by the background-removal feature.
    var backgroundRemovalSettings: BatchBackgroundRemovalSettings {
        .init(
            strength: strength,
            edgeSmoothing: edgeSmoothing,
            edgeExpansion: edgeExpansion
        )
    }
}
