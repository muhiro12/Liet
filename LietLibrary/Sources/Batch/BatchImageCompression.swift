import Foundation

/// Compression presets used for lossy image output formats.
public enum BatchImageCompression: String, CaseIterable, Codable, Sendable {
    /// Preserves lossy sources when possible and otherwise uses maximum quality.
    case off
    /// Prioritizes image fidelity with light compression.
    case high
    /// Balances quality and file size for general batch output.
    case medium
    /// Favors smaller files with stronger compression.
    case low
}

public extension BatchImageCompression {
    private enum Quality {
        static let off = 1.0
        static let high = 0.9
        static let medium = 0.7
        static let low = 0.5
    }

    /// Compression quality mapped to Core Graphics lossy encoders.
    var quality: Double {
        switch self {
        case .off:
            Quality.off
        case .high:
            Quality.high
        case .medium:
            Quality.medium
        case .low:
            Quality.low
        }
    }
}
