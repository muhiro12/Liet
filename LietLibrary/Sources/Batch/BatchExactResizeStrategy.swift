import Foundation

/// Strategy used when both the long edge and short edge are fixed.
public enum BatchExactResizeStrategy: String, CaseIterable, Codable, Sendable {
    case contain
    case coverCrop = "coverCrop"
}
