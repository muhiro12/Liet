import Foundation

/// Shared background-removal settings applied to every processed image.
public struct BatchBackgroundRemovalSettings: Equatable, Codable, Sendable {
    private enum Defaults {
        static let strength = 0.5
        static let edgeSmoothing = 0.15
    }

    /// Repository defaults for background removal.
    public static let `default`: Self = .init(
        strength: Defaults.strength,
        edgeSmoothing: Defaults.edgeSmoothing,
        edgeExpansion: 0
    )

    /// The foreground-preservation strength from 0.0 to 1.0.
    public var strength: Double
    /// The mask-smoothing amount from 0.0 to 1.0.
    public var edgeSmoothing: Double
    /// The mask expansion amount from -1.0 to 1.0.
    public var edgeExpansion: Double

    /// Creates background-removal settings with repository defaults.
    public init(
        strength: Double = Self.default.strength,
        edgeSmoothing: Double = Self.default.edgeSmoothing,
        edgeExpansion: Double = Self.default.edgeExpansion
    ) {
        self.strength = strength
        self.edgeSmoothing = edgeSmoothing
        self.edgeExpansion = edgeExpansion
    }
}
