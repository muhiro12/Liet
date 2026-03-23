import Foundation

/// Strategy used when an image is rendered into an exact pixel canvas.
public enum BatchExactResizeStrategy: String, CaseIterable, Codable, Sendable {
    case stretch
    case contain
    // swiftlint:disable:next redundant_string_enum_value
    case coverCrop = "coverCrop"
}
