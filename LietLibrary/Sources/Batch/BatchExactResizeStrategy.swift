import Foundation

/// Strategy used when both the long edge and short edge are fixed.
public enum BatchExactResizeStrategy: String, CaseIterable, Codable, Sendable {
    case contain
    // swiftlint:disable:next redundant_string_enum_value
    case coverCrop = "coverCrop"
}
