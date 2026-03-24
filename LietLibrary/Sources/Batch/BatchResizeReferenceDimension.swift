import Foundation

/// The image edge used as the reference when preserving aspect ratio.
public enum BatchResizeReferenceDimension: String, CaseIterable, Codable, Sendable {
    case width
    case height
}
