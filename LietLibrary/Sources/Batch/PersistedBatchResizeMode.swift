import Foundation

/// Stored resize mode identifiers used by persisted batch preferences.
public enum PersistedBatchResizeMode: String, Codable, Equatable, Sendable {
    /// Aspect-ratio-preserving resize using one reference dimension.
    case aspectRatioPreserved = "aspect_ratio_preserved"
    /// Exact canvas resize using explicit width and height values.
    case exactSize = "exact_size"
}
